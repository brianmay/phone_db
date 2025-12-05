{
  description = "Phone Database";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-25.05";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    devenv = {
      url = "github:cachix/devenv";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-utils,
      devenv,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        inherit (pkgs.lib) optional optionals;
        pkgs = nixpkgs.legacyPackages.${system};

        elixir = pkgs.beam.packages.erlang_26.elixir_1_18;
        beamPackages = pkgs.beam.packagesWith pkgs.beam.interpreters.erlang_26;

        src = ./.;
        version = "0.0.0";
        pname = "phone_db";

        mixFodDeps = beamPackages.fetchMixDeps {
          TOP_SRC = src;
          pname = "${pname}-mix-deps";
          inherit src version;
          hash = "sha256-56/lcAj8lt9TEOiOwWzwmzwVDECzhWl3AuXv48799l0=";
          # hash = pkgs.lib.fakeHash;
        };

        nodejs = pkgs.nodejs;

        nodePackages = pkgs.buildNpmPackage {
          name = "phone_db_assets";
          src = ./assets;
          npmDepsHash = "sha256-LGkPqC3K3JLZwybAKU3JrzLJTetU5YcHRLmlYsTZs7g=";
          # npmDepsHash = pkgs.lib.fakeHash;
          dontNpmBuild = true;
          inherit nodejs;

          nativeBuildInputs = [
            (pkgs.python3.withPackages (ps: [ ps.setuptools ])) # Used by gyp
          ];

          installPhase = ''
            mkdir $out
            cp -r node_modules $out
            ln -s $out/node_modules/.bin $out/bin

            rm $out/node_modules/phoenix
            ln -s ${mixFodDeps}/phoenix $out/node_modules

            rm $out/node_modules/phoenix_html
            ln -s ${mixFodDeps}/phoenix_html $out/node_modules

            rm $out/node_modules/phoenix_live_view
            ln -s ${mixFodDeps}/phoenix_live_view $out/node_modules
          '';
        };

        pkg = beamPackages.mixRelease {
          TOP_SRC = src;
          inherit
            pname
            version
            elixir
            src
            mixFodDeps
            ;

          postBuild = ''
            ln -sf ${mixFodDeps}/deps deps
            ln -sf ${nodePackages}/node_modules assets/node_modules
            export PATH="${nodePackages}/bin:$PATH"
            ${nodejs}/bin/npm run deploy --prefix ./assets

            # for external task you need a workaround for the no deps check flag
            # https://github.com/phoenixframework/phoenix/issues/2690
            mix do deps.loadpaths --no-deps-check, phx.digest
            mix phx.digest --no-deps-check
          '';
        };

        psql = pkgs.writeShellScriptBin "pd_psql" ''
          exec "${pkgs.postgresql}/bin/psql" "$DATABASE_URL" "$@"
        '';
        port = 4000;
        postgres_port = 6101;
        ldap_port = 6102;

        ldap_dir = ".devenv/state/ldap";
        ldap_url = "ldap://localhost:${toString ldap_port}/";

        phone_username = "phone";
        phone_password = "password";

        ldap_schemas = pkgs.stdenv.mkDerivation {
          name = "ldap_schemas";
          src = ./ldap_schemas;
          installPhase = ''
            mkdir $out
            cp -a * $out
          '';
        };
        dn_suffix = "dc=python-ldap,dc=org";
        root_dn = "cn=root,${dn_suffix}";

        slapd_config = pkgs.writeTextFile {
          name = "slapd.conf";
          text = ''
            include ${ldap_schemas}/00-core.schema
            include ${ldap_schemas}/10-cosine.schema
            include ${ldap_schemas}/50-inetorgperson.schema
            include ${ldap_schemas}/70-eduperson.schema
            include ${ldap_schemas}/90-aueduperson.schema
            include ${ldap_schemas}/90-schac.schema
            include ${ldap_schemas}/nis.schema
            allow bind_v2

            # Database
            moduleload back_mdb
            moduleload ppolicy

            database mdb
            directory ${ldap_dir}

            suffix ${dn_suffix}
            overlay ppolicy
            ppolicy_default cn=default,${dn_suffix}

            access to dn.sub=${dn_suffix} attrs=userPassword
               by anonymous auth

            access to dn.sub=${dn_suffix}
               by dn.exact=${root_dn} write
          '';
        };

        admin_ldif = pkgs.writeTextFile {
          name = "admin.ldif";
          text = ''
            dn: ${dn_suffix}
            o: Test Org
            objectClass: dcObject
            objectClass: organization

            dn: ${root_dn}
            cn: ${root_dn}
            objectClass: simpleSecurityObject
            objectClass: organizationalRole
            userPassword: your_secure_password_here

            dn: cn=default,${dn_suffix}
            objectClass: top
            objectClass: device
            objectClass: pwdPolicy
            pwdAttribute: userPassword
            pwdLockout: TRUE

            dn: ou=People,${dn_suffix}
            objectClass: top
            objectClass: OrganizationalUnit
            ou: People

            dn: ou=Groups,${dn_suffix}
            objectClass: top
            objectClass: OrganizationalUnit
          '';
        };

        pd_ldapsearch = pkgs.writeShellScriptBin "pd_ldapsearch" ''
          exec ldapsearch -H "${ldap_url}" -D "${root_dn}" -b "${dn_suffix}" -w your_secure_password_here
        '';

        start_ldap = pkgs.writeShellScriptBin "start_ldap" ''
          set -e
          set -x
          if ! test -d "${ldap_dir}"; then
            mkdir "${ldap_dir}"
            cat "${admin_ldif}"
            "${pkgs.openldap}/bin/slapadd" -n 1 -f "${slapd_config}" -l "${admin_ldif}"
          fi
          "${pkgs.openldap}/libexec/slapd" -f "${slapd_config}" -h "${ldap_url}"  -d 1
        '';

        test_phone_call = pkgs.writeShellScriptBin "test_phone_call" ''
          curl --json '{"phone_number":"1", "destination_number":"2"}' --user "${phone_username}:${phone_password}" "http://localhost:${toString port}/api/incoming_call/"
        '';

        devShell = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            {
              enterShell = ''
                export HTTP_URL="http://localhost:${toString port}"
                export PORT="${toString port}"
                export RELEASE_TMP=/tmp

                export DATABASE_URL_TEST="postgres://phone_db:your_secure_password_here@localhost:${toString postgres_port}/phone_db_test"
                export DATABASE_URL="postgres://phone_db:your_secure_password_here@localhost:${toString postgres_port}/phone_db"

                export LDAP_SERVER="localhost"
                export LDAP_PORT="${toString ldap_port}"
                export LDAP_BASE_DN="${dn_suffix}"
                export LDAP_USERNAME="root"
                export LDAP_USER_PASSWORD="your_secure_password_here"

                export PHONE_USERNAME="${phone_username}"
                export PHONE_PASSWORD="${phone_password}"
              '';
              packages =
                with pkgs;
                [
                  psql
                  openldap
                  start_ldap
                  pd_ldapsearch
                  test_phone_call
                  elixir
                  elixir_ls
                  glibcLocales
                  node2nix
                  nodejs
                  pkgs.prefetch-npm-deps
                ]
                ++ optional stdenv.isLinux inotify-tools
                ++ optional stdenv.isDarwin terminal-notifier
                ++ optionals stdenv.isDarwin (
                  with darwin.apple_sdk.frameworks;
                  [
                    CoreFoundation
                    CoreServices
                  ]
                );
              processes.slapd = {
                exec = "${start_ldap}/bin/start_ldap";
                process-compose = {
                  readiness_probe = {
                    exec.command = "${pd_ldapsearch}/bin/pd_ldapsearch";
                    initial_delay_seconds = 2;
                    period_seconds = 10;
                    timeout_seconds = 1;
                    success_threshold = 1;
                    failure_threshold = 3;
                  };
                };
              };
              services.postgres = {
                enable = true;
                package = pkgs.postgresql_15;
                listen_addresses = "127.0.0.1";
                port = postgres_port;
                initialDatabases = [ { name = "phone_db"; } ];
                initialScript = ''
                  \c phone_db;
                  CREATE USER phone_db with encrypted password 'your_secure_password_here';
                  GRANT ALL PRIVILEGES ON DATABASE phone_db TO phone_db;
                '';
              };
            }
          ];
        };

        test = pkgs.nixosTest {
          name = "phone_db";
          nodes.machine =
            { ... }:
            {
              imports = [
                self.nixosModules.default
              ];
              services.phone_db = {
                enable = true;
                http_url = "http://localhost:4000";
                port = 4000;
                secrets = pkgs.writeText "secrets.txt" ''
                  export RELEASE_COOKIE="12345678901234567890123456789012345678901234567890123456"
                  export DATABASE_URL="postgres://phone_db:your_secure_password_here@localhost/phone_db"
                  export GUARDIAN_SECRET="1234567890123456789012345678901234567890123456789012345678901234"
                  export SECRET_KEY_BASE="1234567890123456789012345678901234567890123456789012345678901234"
                  export SIGNING_SALT="12345678901234567890123456789012"
                  export OIDC_DISCOVERY_URL="http://localhost"
                  export OIDC_CLIENT_ID="photos"
                  export OIDC_CLIENT_SECRET="12345678901234567890123456789012"
                  export OIDC_AUTH_SCOPE="openid profile groups"

                  export DATABASE_URL_TEST="postgres://phone_db:your_secure_password_here@localhost:${toString postgres_port}/phone_db_test"
                  export DATABASE_URL="postgres://phone_db:your_secure_password_here@localhost:${toString postgres_port}/phone_db"

                  export LDAP_SERVER="localhost"
                  export LDAP_PORT="${toString ldap_port}"
                  export LDAP_BASE_DN="${dn_suffix}"
                  export LDAP_USERNAME="root"
                  export LDAP_USER_PASSWORD="your_secure_password_here"

                  export PHONE_USERNAME="${phone_username}"
                  export PHONE_PASSWORD="${phone_password}"
                '';
              };
              system.stateVersion = "24.05";

              services.postgresql = {
                enable = true;
                package = pkgs.postgresql_15;
                settings.port = postgres_port;
                initialScript = pkgs.writeText "init.psql" ''
                  CREATE DATABASE phone_db;
                  CREATE USER phone_db with encrypted password 'your_secure_password_here';
                  ALTER DATABASE phone_db OWNER TO phone_db;
                '';
              };

              services.openldap = {
                enable = true;

                # enable plain and secure connections
                urlList = [ ldap_url ];

                settings = {
                  attrs = {
                    olcLogLevel = "conns config";
                  };

                  children = {
                    "cn=schema".includes = [
                      "${pkgs.openldap}/etc/schema/core.ldif"
                      "${pkgs.openldap}/etc/schema/cosine.ldif"
                      "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
                    ];

                    "olcDatabase={1}mdb" = {
                      attrs = {
                        objectClass = [
                          "olcDatabaseConfig"
                          "olcMdbConfig"
                        ];

                        olcDatabase = "{1}mdb";
                        olcDbDirectory = "/var/lib/openldap/test";

                        olcSuffix = dn_suffix;

                        # your admin account, do not use writeText on a production system
                        olcRootDN = root_dn;
                        olcRootPW.path = pkgs.writeText "olcRootPW" "your_secure_password_here";

                        olcAccess = [
                          # custom access rules for userPassword attributes
                          ''
                            {0}to attrs=userPassword
                              by self write
                              by anonymous auth
                              by * none
                          ''

                          # allow read on anything else
                          ''
                            {1}to *
                              by * read
                          ''
                        ];
                      };
                      children = {
                        "olcOverlay={2}ppolicy".attrs = {
                          objectClass = [
                            "olcOverlayConfig"
                            "olcPPolicyConfig"
                            "top"
                          ];
                          olcOverlay = "{2}ppolicy";
                          olcPPolicyHashCleartext = "TRUE";
                        };
                        "olcOverlay={3}memberof".attrs = {
                          objectClass = [
                            "olcOverlayConfig"
                            "olcMemberOf"
                            "top"
                          ];
                          olcOverlay = "{3}memberof";
                          olcMemberOfRefInt = "TRUE";
                          olcMemberOfDangling = "ignore";
                          olcMemberOfGroupOC = "groupOfNames";
                          olcMemberOfMemberAD = "member";
                          olcMemberOfMemberOfAD = "memberOf";
                        };
                        "olcOverlay={4}refint".attrs = {
                          objectClass = [
                            "olcOverlayConfig"
                            "olcRefintConfig"
                            "top"
                          ];
                          olcOverlay = "{4}refint";
                          olcRefintAttribute = [
                            "memberof"
                            "member"
                            "manager"
                            "owner"
                          ];
                        };
                      };
                    };
                  };
                };
              };
            };

          testScript = ''
            machine.wait_for_unit("phone_db.service")
            machine.wait_for_open_port(4000)
            machine.succeed("${pkgs.curl}/bin/curl --fail -v http://localhost:4000/_health")
            machine.succeed("${test_phone_call}/bin/test_phone_call")
          '';
        };
      in
      {
        checks.nixosModules = test;
        packages = {
          devenv-up = devShell.config.procfileScript;
          default = pkg;
        };
        inherit devShell;
      }
    )
    // {
      nixosModules.default = import ./module.nix { inherit self; };
    };
}

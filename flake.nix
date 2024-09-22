{
  description = "Phone Database";

  inputs = {
    nixpkgs = {url = "github:NixOS/nixpkgs/nixos-24.05";};
    flake-utils = {url = "github:numtide/flake-utils";};
    devenv = {url = "github:cachix/devenv";};
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    devenv,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      inherit (pkgs.lib) optional optionals;
      pkgs = nixpkgs.legacyPackages.${system};

      elixir = pkgs.beam.packages.erlang.elixir;
      beamPackages = pkgs.beam.packagesWith pkgs.beam.interpreters.erlang;

      src = ./.;
      version = "0.0.0";
      pname = "phone_db";

      mixFodDeps = beamPackages.fetchMixDeps {
        TOP_SRC = src;
        pname = "${pname}-mix-deps";
        inherit src version;
        hash = "sha256-gLe1JR29hyIIRRyLF6rfoagL02YJfXMKfnkRXF5R1gY=";
        # hash = pkgs.lib.fakeHash;
      };

      nodejs = pkgs.nodejs;
      nodePackages =
        import assets/default.nix {inherit pkgs system nodejs;};

      pkg = beamPackages.mixRelease {
        TOP_SRC = src;
        inherit pname version elixir src mixFodDeps;

        postBuild = ''
          ln -sf ${mixFodDeps}/deps deps
          ln -sf ${nodePackages.nodeDependencies}/lib/node_modules assets/node_modules
          export PATH="${nodePackages.nodeDependencies}/bin:$PATH"
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
        curl --json '{"phone_number":"1", "destination_number":"2"}' --user "${phone_username}:${phone_password}" "http://localhost:${
          toString port
        }/api/incoming_call/"
      '';

      devShell = devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [
          {
            enterShell = ''
              export HTTP_URL="http://localhost:${toString port}"
              export PORT="${toString port}"
              export RELEASE_TMP=/tmp

              export DATABASE_URL_TEST="postgres://phone_db:your_secure_password_here@localhost:${
                toString postgres_port
              }/phone_db_test"
              export DATABASE_URL="postgres://phone_db:your_secure_password_here@localhost:${
                toString postgres_port
              }/phone_db"
              export IMAGE_DIR="/tmp/images"

              export LDAP_SERVER="localhost"
              export LDAP_PORT="${toString ldap_port}"
              export LDAP_BASE_DN="${dn_suffix}"
              export LDAP_USERNAME="root"
              export LDAP_USER_PASSWORD="your_secure_password_here"

              export PHONE_USERNAME="${phone_username}"
              export PHONE_PASSWORD="${phone_password}"
            '';
            packages = with pkgs;
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
              ]
              ++ optional stdenv.isLinux inotify-tools
              ++ optional stdenv.isDarwin terminal-notifier
              ++ optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
                CoreFoundation
                CoreServices
              ]);
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
              package = pkgs.postgresql_15.withPackages (ps: [ps.postgis]);
              listen_addresses = "127.0.0.1";
              port = postgres_port;
              initialDatabases = [{name = "phone_db";}];
              initialScript = ''
                \c phone_db;
                CREATE USER phone_db with encrypted password 'your_secure_password_here';
                GRANT ALL PRIVILEGES ON DATABASE phone_db TO phone_db;
                ALTER USER phone_db WITH SUPERUSER;
              '';
            };
          }
        ];
      };
    in {
      packages = {
        devenv-up = devShell.config.procfileScript;
        default = pkg;
      };
      inherit devShell;
    })
    // {
      nixosModules.default = import ./module.nix {inherit self;};
    };
}

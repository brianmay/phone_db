{ self }:
{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.services.phone_db;

  system = pkgs.stdenv.system;
  phone_db_pkg = self.packages.${system}.default;

  wrapper = pkgs.writeShellScriptBin "phone_db" ''
    export PATH="$PATH:${pkgs.gawk}/bin"
    export RELEASE_TMP="${cfg.data_dir}/tmp"
    export HTTP_URL="${cfg.http_url}"
    export PORT="${toString (cfg.port)}"
    . "${cfg.secrets}"

    mkdir -p "${cfg.data_dir}"
    mkdir -p "${cfg.data_dir}/tmp"
    exec "${phone_db_pkg}/bin/phone_db" "$@"
  '';

in {
  options.services.phone_db = {
    enable = mkEnableOption "phone_db service";
    secrets = mkOption { type = types.path; };
    http_url = mkOption { type = types.str; };
    port = mkOption { type = types.int; };
    data_dir = mkOption {
      type = types.str;
      default = "/var/lib/phone_db";
    };
  };

  config = mkIf cfg.enable {
    users.users.phone_db = {
      isSystemUser = true;
      description = "PhoneDB user";
      group = "phone_db";
      createHome = true;
      home = "${cfg.data_dir}";
    };

    users.groups.phone_db = { };

    systemd.services.phone_db = {
      wantedBy = ["multi-user.target"];
      after = ["network.target" "postgresql.service" "openldap.service"];
      serviceConfig = {
        User = "phone_db";
        ExecStart = "${wrapper}/bin/phone_db start";
        ExecStop = "${wrapper}/bin/phone_db stop";
        ExecReload = "${wrapper}/bin/phone_db reload";
      };
    };
  };
}

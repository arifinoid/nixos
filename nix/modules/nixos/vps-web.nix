{ pkgs, ... }: {
  # Docker
  virtualisation.docker.enable = true;

  # Nginx + reverse proxy ke personal web (python http.server di 127.0.0.1:3000)
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    virtualHosts."arifinoid.web.id" = {
      serverName = "arifinoid.web.id";
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };

    virtualHosts."jobhooker.arifinoid.web.id" = {
      serverName = "jobhooker.arifinoid.web.id";
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };
  };

  # Let's Encrypt via NixOS native ACME
  security.acme = {
    acceptTerms = true;
    certs."arifinoid.web.id" = {
      email = "rohmadarifin007@gmail.com";
      domain = "arifinoid.web.id";
    };

    certs."jobhooker.arifinoid.web.id" = {
      email = "rohmadarifin007@gmail.com";
      domain = "jobhooker.arifinoid.web.id";
    };
  };

  # Direktori web personal
  systemd.tmpfiles.rules = [
    "d /Documents/personal-web 0755 root root -"
    "d /root/Documents/personal-web 0755 root root -"
  ];

  # Serve personal web via Python http.server (root, port 3000)
  systemd.services.personal-web = {
    description = "Personal web (python http.server)";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      WorkingDirectory = "/root/Documents/personal-web/out";
      ExecStart =
        "${pkgs.python3}/bin/python3 -m http.server 3000 --bind 127.0.0.1 --directory /root/Documents/personal-web/out";
      Restart = "always";
      RestartSec = 3;
    };
  };
}

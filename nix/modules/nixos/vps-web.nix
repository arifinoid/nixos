{ pkgs, ... }:
let
  # CI uploads every commit to releases/<sha> and flips the current symlink.
  siteRoot = "/var/www/arifinoid";
in
{
  # Docker
  virtualisation.docker.enable = true;

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;

    # Static site served straight from disk: no app server, no proxy hop.
    virtualHosts."arifinoid.web.id" = {
      serverName = "arifinoid.web.id";
      forceSSL = true;
      enableACME = true;
      root = "${siteRoot}/current";
      extraConfig = ''
        error_page 404 /404.html;
        add_header Cache-Control "no-cache" always;
      '';
      locations."/" = {
        # The static export writes route/index.html, so /explore resolves to
        # /explore/index.html instead of a directory listing.
        tryFiles = "$uri $uri/index.html =404";
      };
      locations."/_next/static/".extraConfig = ''
        add_header Cache-Control "public, max-age=31536000, immutable" always;
      '';
      locations."= /404.html".extraConfig = ''
        internal;
      '';
    };

    virtualHosts."jobhooker.arifinoid.web.id" = {
      serverName = "jobhooker.arifinoid.web.id";
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
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

  # Release directories written by the personal-web deploy job over ssh.
  systemd.tmpfiles.rules = [
    "d ${siteRoot} 0755 root root -"
    "d ${siteRoot}/releases 0755 root root -"
  ];

  environment.systemPackages = [ pkgs.rsync ];
}

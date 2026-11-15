{ config, pkgs, ... }:
let
  # Deploy job (aksaraku) uploads each commit to releases/<sha> and flips the
  # `current` symlink, same as personal-web. nginx serves the static build
  # straight from disk: the app is a client-side PWA with no API server.
  aksarakuRoot = "/var/www/aksaraku";

  appHost = "aksaraku.arifinoid.web.id";
  statsHost = "stats.arifinoid.web.id";

  # GoatCounter keeps everything in one SQLite file under its StateDirectory.
  goatcounterDb = "/var/lib/goatcounter/goatcounter.sqlite3";

  # Mirrors public/_headers in the aksaraku repo. nginx drops parent add_header
  # directives as soon as a location defines its own, so every location that
  # sets a Cache-Control header repeats these.
  securityHeaders = ''
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' https://${statsHost}; style-src 'self' 'unsafe-inline'; img-src 'self' data: blob: https://${statsHost}; media-src 'self' data: blob:; font-src 'self' data:; connect-src 'self' https://${statsHost}; worker-src 'self'; manifest-src 'self'; base-uri 'self'; form-action 'self'; frame-ancestors 'none'" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Permissions-Policy "accelerometer=(), camera=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), payment=(), usb=()" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Robots-Tag "index, follow" always;
  '';
in
{
  # Admin login for the GoatCounter dashboard. Read through a systemd
  # credential so the service can stay DynamicUser and never see a secret file
  # it is not allowed to read.
  sops.secrets.goatcounter_admin_password = {
    mode = "0400";
  };

  services.goatcounter = {
    enable = true;
    address = "127.0.0.1";
    port = 8081;
    # TLS terminates at nginx; GoatCounter trusts X-Forwarded-* from it.
    proxy = true;
    extraArgs = [
      "-db"
      "sqlite+${goatcounterDb}"
      "-automigrate"
    ];
  };

  # Create the site once, before the server starts. Safe to re-run: the check
  # only looks for the vhost in the database. The dashboard lives on
  # statsHost; the app posts counts to it cross-origin from appHost.
  systemd.services.goatcounter.preStart = ''
    DB=${pkgs.lib.escapeShellArg "sqlite+${goatcounterDb}"}

    if ! ${pkgs.goatcounter}/bin/goatcounter db show site -find ${statsHost} -db "$DB" >/dev/null 2>&1; then
      ${pkgs.goatcounter}/bin/goatcounter db create site -createdb \
        -db "$DB" \
        -vhost ${statsHost} \
        -user.email rohmadarifin007@gmail.com \
        -user.password "$(cat "$CREDENTIALS_DIRECTORY/goatcounter-admin")"
    fi
  '';
  systemd.services.goatcounter.serviceConfig.LoadCredential =
    "goatcounter-admin:${config.sops.secrets.goatcounter_admin_password.path}";

  services.nginx.virtualHosts.${appHost} = {
    serverName = appHost;
    forceSSL = true;
    enableACME = true;
    root = "${aksarakuRoot}/current";

    # Static files 404 by default; only the landing page and the app shell have
    # explicit entries. That matches the Cloudflare Pages _redirects behaviour.
    extraConfig = securityHeaders + ''
      add_header Cache-Control "no-cache" always;
    '';

    # Landing page is the front door at `/`; the app lives under `/app/`.
    locations."= /" = {
      tryFiles = "/landing.html =404";
    };

    # `/app` redirects to `/app/`, which nginx serves as a directory index.
    # Unknown sub-paths fall back to the shell for in-memory routing.
    locations."/app/" = {
      tryFiles = "$uri $uri/ /app/index.html";
    };

    # The service worker controls update delivery; never cache it.
    locations."= /sw.js" = {
      extraConfig = securityHeaders + ''
        add_header Cache-Control "public, max-age=0, must-revalidate" always;
      '';
    };

    locations."= /manifest.webmanifest" = {
      extraConfig = securityHeaders + ''
        add_header Cache-Control "public, max-age=3600" always;
      '';
    };

    # Bun emits content-hashed assets, so they can be cached forever.
    locations."~* \\.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$" = {
      extraConfig = securityHeaders + ''
        add_header Cache-Control "public, max-age=31536000, immutable" always;
      '';
    };
  };

  # GoatCounter dashboard + count endpoint. The script on appHost posts here.
  services.nginx.virtualHosts.${statsHost} = {
    serverName = statsHost;
    forceSSL = true;
    enableACME = true;

    locations."/" = {
      proxyPass = "http://127.0.0.1:8081";
      extraConfig = ''
        add_header X-Frame-Options "DENY" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy "strict-origin-when-cross-origin" always;
      '';
    };
  };

  security.acme.certs.${appHost} = {
    email = "rohmadarifin007@gmail.com";
    domain = appHost;
  };
  security.acme.certs.${statsHost} = {
    email = "rohmadarifin007@gmail.com";
    domain = statsHost;
  };

  # Release directories written by the aksaraku deploy job over ssh.
  systemd.tmpfiles.rules = [
    "d ${aksarakuRoot} 0755 root root -"
    "d ${aksarakuRoot}/releases 0755 root root -"
  ];
}

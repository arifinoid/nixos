{ ... }:
{
  # The backup script itself is uploaded by the job-hooker deploy workflow to
  # /root/bin/jobhooker-backup (outside the release tree, so pruning releases
  # never deletes it). This unit only schedules it.
  #
  # Runs as root: it needs /etc/jobhooker.env, the PII key and write access to
  # /var/backups. The script reads DATABASE_URL and keeps 14 daily dumps.
  systemd.services.jobhooker-backup = {
    description = "Dump the job-hooker Neon database and copy the PII key";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    unitConfig.ConditionPathExists = "/root/bin/jobhooker-backup";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/root/bin/jobhooker-backup";
      Environment = "PATH=/run/current-system/sw/bin";
    };
  };

  systemd.timers.jobhooker-backup = {
    description = "Daily job-hooker backup";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 03:15:00 UTC";
      RandomizedDelaySec = "15m";
      # Catch up after downtime instead of skipping the day.
      Persistent = true;
    };
  };
}

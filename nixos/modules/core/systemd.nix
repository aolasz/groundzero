{ ... }:

{
  systemd.settings.Manager = {
    DefaultTimeoutStartSec = "20s";
    DefaultTimeoutStopSec = "10s";
  };
}

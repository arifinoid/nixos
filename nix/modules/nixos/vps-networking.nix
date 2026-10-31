{ ... }: {
  networking = {
    hostName = "vps";
    usePredictableInterfaceNames = false;
    useDHCP = false;
    useNetworkd = true;
    defaultGateway = {
      address = "10.11.24.1";
      interface = "eth0";
    };
    nameservers = [ "183.60.82.98" "8.8.8.8" ];
    interfaces.eth0 = {
      ipv4.addresses = [{
        address = "10.11.26.201";
        prefixLength = 22;
      }];
    };
    firewall.allowedTCPPorts = [ 22 80 443 ];
  };
}

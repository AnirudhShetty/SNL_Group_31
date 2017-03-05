configuration ltRadioC {
  provides interface ltRadio;
  provides interface ltRadioDebug;
}

implementation {
  components ltRadioP;
  components IPStackC;
  components IPDispatchC;
	components UdpC;
  components UDPShellC;
	components RPLRoutingC;
	components StaticIPAddressTosIdC;
	
	components new UdpSocketC() as multicastSend;
	ltRadioP.multicastSend -> multicastSend;

	components new UdpSocketC() as unicastSend;
	ltRadioP.unicastSend -> unicastSend;
	
	components new ShellCommandC("debug") as debugCmd;
	ltRadioP.debugCmd -> debugCmd;

	ltRadioP.RadioControl -> IPStackC;

	ltRadio = ltRadioP;
	ltRadioDebug = ltRadioP;
}

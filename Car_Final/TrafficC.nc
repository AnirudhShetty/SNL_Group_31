configuration TrafficC {
} implementation {
	components MainC, LedsC, TrafficP;
	TrafficP.Boot -> MainC;
	TrafficP.Leds -> LedsC;

	components IPStackC;
	components RPLRoutingC;
	components StaticIPAddressTosIdC;
	TrafficP.RadioControl -> IPStackC;

	components new TimerMilliC() as RandomTimer;
	TrafficP.RandomTimer -> RandomTimer;

	components new TimerMilliC() as ResetTimer;
	TrafficP.ResetTimer -> ResetTimer;

	components new UdpSocketC() as AlarmSend;
	TrafficP.AlarmSend -> AlarmSend;

	components new UdpSocketC() as PollSend;
	TrafficP.PollSend-> PollSend;

	//define the interface to generate the random number for delay
	components RandomC;	
	TrafficP.Random ->RandomC;

#ifdef PRINTFUART_ENABLED
  components SerialPrintfC;
#endif
}

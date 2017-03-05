configuration ControllerC {
} implementation {
	components MainC, LedsC, ControllerP;
	ControllerP.Boot -> MainC;
	ControllerP.Leds -> LedsC;

	components IPStackC;
	components RPLRoutingC;
	components UdpC;
	components UDPShellC;
	components StaticIPAddressTosIdC;
	ControllerP.RadioControl -> IPStackC;

	components new TimerMilliC() as SendTimer;
	ControllerP.SendTimer -> SendTimer;

	//components new TimerMilliC() as ResetTimer;
	//ControllerP.ResetTimer -> ResetTimer;

	components new UdpSocketC() as AlarmSend;
	ControllerP.AlarmSend -> AlarmSend;

	components new UdpSocketC() as CarCountSend;
	ControllerP.CarCountSend ->CarCountSend;

	components new UdpSocketC() as PollSend;	
	ControllerP.PollSend-> PollSend;

	components new ShellCommandC("read") as ReadCmd;		//Command to read threhold value of the car on the traffic	
	components new ShellCommandC("newthresh") as NewThreshCmd; 	//Command to set new threshhold for the car capacity on road

	ControllerP.ReadCmd->ReadCmd;
	ControllerP.NewThreshCmd->NewThreshCmd;


#ifdef PRINTFUART_ENABLED
#endif
}

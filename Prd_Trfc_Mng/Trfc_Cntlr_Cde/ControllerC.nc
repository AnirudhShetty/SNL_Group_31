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

        components new TimerMilliC() as TrfcTimer;
	ControllerP.TrfcTimer -> TrfcTimer;

	components new UdpSocketC() as AlarmSend;
	ControllerP.AlarmSend -> AlarmSend;

	components new UdpSocketC() as CarCountSend;
	ControllerP.CarCountSend ->CarCountSend;

	components new UdpSocketC() as PollSend;	
	ControllerP.PollSend-> PollSend;

	components new UdpSocketC() as SettingSend;	
	ControllerP.SettingSend-> SettingSend;

	components new UdpSocketC() as TrfcMngSend;	
	ControllerP.TrfcMngSend-> TrfcMngSend;

	components new ShellCommandC("read") as ReadCmd;		//Command to read threhold value of the car on the traffic	
	components new ShellCommandC("newthresh") as NewThreshCmd; 	//Command to set new threshhold for the car capacity on road

	ControllerP.ReadCmd->ReadCmd;
	ControllerP.NewThreshCmd->NewThreshCmd;


#ifdef PRINTFUART_ENABLED
  /* This component wires printf directly to the serial port, and does
   * not use any framing.  You can view the output simply by tailing
   * the serial device.  Unlike the old printfUART, this allows us to
   * use PlatformSerialC to provide the serial driver.
   *
   * For instance:
   * $ stty -F /dev/ttyUSB0 115200
   * $ tail -f /dev/ttyUSB0
  */
  components SerialPrintfC;

  /* This is the alternative printf implementation which puts the
   * output in framed tinyos serial messages.  This lets you operate
   * alongside other users of the tinyos serial stack.
   */
  // components PrintfC;
  // components SerialStartC;
#endif
}

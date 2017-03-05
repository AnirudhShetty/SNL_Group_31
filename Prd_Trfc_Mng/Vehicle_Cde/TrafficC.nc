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

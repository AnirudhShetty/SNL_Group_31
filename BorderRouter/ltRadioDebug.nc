interface ltRadioDebug{

	/**
   * Puts a Message on the UDP Shell
   * @param debugMsg
   * @param len 
   */
  command void udpDebug(char* debugMsg, uint16_t len);

  /**
   * Sends a debug message to the border router
   * @param msg is the pointer to the message
   * @param length is the lengt of msg
   */
  command void sendDebugMessage(char* msg, uint8_t length);
}

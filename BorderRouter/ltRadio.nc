 /** 
  * Provides an encapusulated interface for all the network stuff we need
  * for the LaserTag Game
  * @param bla
  */
#define PPPADDRESS "fec::100"
  
interface ltRadio {
  /**
   * This is a dummy command till now. If we do some initializing for the radio
   * it should go in here.
   */
  command void init();
  
  /**
   * Sends a Multicast PengMessage over the Radio.
   */
  command void sendPengMessage();
  
  /**
   * Sends a Message to the border router that it was hit.
   * ONLY in LT_TARGET
   * @param killerId is the ID of the player that shot you.
   */
  command void sendHitMessage(uint8_t killerId);


  /**
   * Sends a Message to the paired GUN that it was hit.
   * ONLY in LT_TARGET
   * @param destination is the ID of the paired gun
   */
  command void sendHitMessageToMyGun(uint8_t destination, uint8_t killerId);
  
  /**
   * multicasts a discoverymessage with the nodeID
   */
  command void sendDiscoveryMessage(uint8_t gameId);

  /**
   * 
   */
  command void sendLifeCountMessage(uint8_t lifecount);

  /**
   * 
   */
   command void repeatStartGameMessage();

   /**
    * 
    */
   command void repeatEndOfGameMessage(uint8_t winnerId);

  /**
   * This event is signaled when the radio receives a PengMessage.
   * This should trigger the sampling of the light sensor later.
   */
  event   void receivedPengMessage(uint8_t shooterId);
  
  /**
   * This event is signaled when the radio receives a lifecount message.
   * This should update the lifecount and leds.
   */
  event   void receivedLifecountMessage(uint8_t lifecount);
  
  /**
   * This event is signaled when the radio receives a endOfGameMessage.
   * This should trigger end of game state.
   */
  event   void receivedEndOfGameMessage(uint8_t winnerId, uint8_t isFromRouter);
  
  
  /**
   * This event is signaled when the radio receives a discoveryMessage.
   * This should trigger end of game state.
   */
  event   void receivedDiscoveryMessage(uint8_t gunId);
  
  /**
   * This event is signaled when the radio receives a startGameMessage.
   * This should trigger game start.
   * @param isFromRouter true if a unicast was sent from router. false if unicast received
   */
  event   void receivedStartGameMessage(uint8_t isFromRouter);

  /**
   * 
   */
  event void receivedHitMessageFromTarget(uint8_t killerId);
  
//  command void setPppRouterIp6Address(char* );
//  command int getPppRouterIp6Address(); //TODO! right return type
}

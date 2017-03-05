/**
 * ltRadio is the abstraction of all the networking we need to
 * implement the Laser Tag Game. It takes care of the whole UDP / IP stuff.
 *
 * The lab4.pdf has some info on what needs to be done here.
 *
 * @author Florian Voit
 * @author Lukas Schaus
 */
#include <lib6lowpan/ip.h>
#include "ltTypes.h"
#include "blip_printf.h"

module ltRadioP {
	provides interface ltRadio;
	provides interface ltRadioDebug;

	uses interface SplitControl as RadioControl;
	uses interface UDP as multicastSend;
	uses interface UDP as unicastSend;
	uses interface ShellCommand as debugCmd;
} implementation {
//-----------------Default Values--------------------------
	#define MULTICAST_PORT		      1500
	#define UNICAST_PORT			      3000
  #define ROUTER_ADDRESS   "fec0::100"
	#define MULTICAST 		   "ff02::001"


//-----------------Local Variables-------------------------
	struct sockaddr_in6 multicastSocket;
	struct sockaddr_in6 unicastSocket;
	struct sockaddr_in6 unicastSocketToGun;  //to controller
	
	nx_struct radioMessage_t radioMessage;
	struct debugMessage_t debugMessage;


	command void ltRadio.init(){
    call RadioControl.start();
	}
	

  command void ltRadio.sendPengMessage(){
    radioMessage.type = PENG_MESSAGE;
    radioMessage.data = TOS_NODE_ID;
    call multicastSend.sendto(&multicastSocket, &radioMessage, sizeof(radioMessage));
    call unicastSend.sendto(&unicastSocket, &radioMessage, sizeof(radioMessage));
  }
	
  command void ltRadio.sendHitMessage(uint8_t killerId){
    radioMessage.type = HIT_MESSAGE;
    radioMessage.data = killerId;
    call unicastSend.sendto(&unicastSocket, &radioMessage, sizeof(radioMessage));
  }

  command void ltRadio.sendDiscoveryMessage(uint8_t gameId){
  	radioMessage.type = DISCOVERY_MESSAGE;
  	radioMessage.data = gameId;
  	call multicastSend.sendto(&multicastSocket, &radioMessage, sizeof(radioMessage));
  	call unicastSend.sendto(&unicastSocket, &radioMessage, sizeof(radioMessage));
  }

  command void ltRadioDebug.sendDebugMessage(char* msg, uint8_t length){
  	debugMessage.type = DEBUG_MESSAGE;
  	strncpy(debugMessage.msg, msg, length);
  	call unicastSend.sendto(&unicastSocket, &debugMessage, sizeof(debugMessage));
  }

  command void ltRadio.sendHitMessageToMyGun(uint8_t destination, uint8_t killerId){
  	char gunAddress[10];
  	sprintf(gunAddress, "fec0::%d", destination);
  	inet_pton6(gunAddress, &unicastSocketToGun.sin6_addr);
  	radioMessage.type = HIT_MESSAGE_TO_GUN;
    radioMessage.data = killerId;
    call unicastSend.sendto(&unicastSocketToGun, &radioMessage, sizeof(radioMessage));
  }

  command void ltRadio.repeatStartGameMessage(){
  	radioMessage.type = START_MESSAGE;
  	radioMessage.data = 0;
  	call multicastSend.sendto(&multicastSocket, &radioMessage, sizeof(radioMessage));

  }

  command void ltRadio.repeatEndOfGameMessage(uint8_t winnerId){
  	radioMessage.type = ENDOFGAME_MESSAGE;
  	radioMessage.data = winnerId;
  	call multicastSend.sendto(&multicastSocket, &radioMessage, sizeof(radioMessage));

  }

  command void ltRadio.sendLifeCountMessage(uint8_t lifecount){
  	radioMessage.type = LIFCOUNT_MESSAGE;
    radioMessage.data = lifecount;
    call unicastSend.sendto(&unicastSocket, &radioMessage, sizeof(radioMessage));
  }

  event void multicastSend.recvfrom(struct sockaddr_in6 *from, void *data,
  uint16_t len, struct ip6_metadata *meta) {
	  nx_struct radioMessage_t msg;
	  memcpy(&msg, data, sizeof(msg));
	  switch(msg.type) {
      case PENG_MESSAGE:
        signal ltRadio.receivedPengMessage(msg.data);
	      break;
	    case DISCOVERY_MESSAGE:
	      signal ltRadio.receivedDiscoveryMessage(msg.data);
	      break;
	    case ENDOFGAME_MESSAGE:
	      signal ltRadio.receivedEndOfGameMessage(msg.data, 0);
	      break;
      case START_MESSAGE:
        signal ltRadio.receivedStartGameMessage(0);
        break;
//      case HIT_MESSAGE_TO_GUN:
//	     signal ltRadio.receivedHitMessageFromTarget(msg.data);
//	     break;
	    default:  break;
    }  
	}

	event void unicastSend.recvfrom(struct sockaddr_in6 *from, void *data,
	uint16_t len, struct ip6_metadata *meta) {
	  nx_struct radioMessage_t msg;
	  memcpy(&msg, data, sizeof(msg));
	  	  switch(msg.type) {
      			case LIFCOUNT_MESSAGE:
        			signal ltRadio.receivedLifecountMessage(msg.data);
	      			break;
	     		case HIT_MESSAGE_TO_GUN: //Car count reached
	     			signal ltRadio.receivedHitMessageFromTarget(msg.data);
	     			break;
	     		case START_MESSAGE:
	     			signal ltRadio.receivedStartGameMessage(1);
	     			break;
	     		case ENDOFGAME_MESSAGE:
	     			signal ltRadio.receivedEndOfGameMessage(msg.data,1);
	    default:  break;
    }  
	}

	event void RadioControl.startDone(error_t e) {
		  multicastSocket.sin6_port = htons(MULTICAST_PORT);
		  inet_pton6(MULTICAST, &multicastSocket.sin6_addr);
		  call multicastSend.bind(MULTICAST_PORT);

		  unicastSocketToGun.sin6_port = htons(UNICAST_PORT);
		
		//#ifdef LT_TARGET
		  unicastSocket.sin6_port = htons(UNICAST_PORT);
		  inet_pton6(ROUTER_ADDRESS, &unicastSocket.sin6_addr);
		  call unicastSend.bind(UNICAST_PORT);
		//#endif

	} //See TheftP for info
	
	event char* debugCmd.eval(int argc, char* argv[]){
    char* reply_buf = call debugCmd.getBuffer(50);
    sprintf(reply_buf, "OK!");
    return reply_buf;
	}
	
	
	event void RadioControl.stopDone(error_t e) {}

	command void ltRadioDebug.udpDebug(char* debugMsg, uint16_t len){
    	char* reply_buf = call debugCmd.getBuffer(len);
		memcpy(reply_buf, debugMsg, len);
		call debugCmd.write(reply_buf,len);
	}
}

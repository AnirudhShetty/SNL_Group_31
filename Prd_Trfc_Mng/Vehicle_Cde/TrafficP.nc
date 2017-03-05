#include <lib6lowpan/ip.h>
#include "node.h"
#include <string.h>

module TrafficP {
	uses {
		interface Boot;
		interface Leds;
		interface SplitControl as RadioControl;
		interface UDP as AlarmSend;
		interface UDP as PollSend;
		interface Timer<TMilli> as RandomTimer;
		interface Timer<TMilli> as ResetTimer;

		// use the random function to generate random delay for sending poll response to avoid collision of packet at receiver		
		interface Random; 
		
	}

} implementation {

	enum {
		RANDOM_PERIOD =100,  	
		RESET_PERIOD=5000,	//ms
		POLL=1, 		//flag for poll request
		CAR=0, 			//for the car
		CONTROLLER_1=2,
		CONTROLLER_2=3,
                PLL_ACK = 2,
		};

	nx_struct poll_report PollReport;

	struct sockaddr_in6 route_dest;
	struct sockaddr_in6 route_control;
	
	int r;
	int i;
	uint8_t Node_ID[NODE_COUNT];
	
	event void Boot.booted() {
		call RadioControl.start();
	}

	event void RadioControl.startDone(error_t e) {


		call ResetTimer.startPeriodic(RESET_PERIOD);

		call AlarmSend.bind(7000); 
	
	//Binding to the controller
		route_control.sin6_port = htons(4000);
		//inet_pton6(route_control, &route_control.sin6_addr);
		call PollSend.bind(4000);

		
	}

	 void report_car(){
		
		PollReport.type=PLL_ACK;		
		PollReport.sender=TOS_NODE_ID;
		PollReport.sendertype=CAR;
		
		call PollSend.sendto(&route_control, &PollReport, sizeof(PollReport));
		call Leds.led2On();					// polling request send with indication of green LED
	}

	event void RandomTimer.fired() {
		report_car();
	}

	event void ResetTimer.fired() {
		
		call Leds.set((uint8_t)0);				//Leds are reset to distinguish the changes
	}

/* When Alarm received for more than threshhold value*/
	event void AlarmSend.recvfrom(struct sockaddr_in6 *from, 
			void *data, uint16_t len, struct ip6_metadata *meta) {
		nx_struct alarm_report *AlarmReport= (nx_struct alarm_report*) data;
			call Leds.set((uint8_t)7);			//All LEDS are set as alarming signal
			memcpy(Node_ID, AlarmReport->car_divert,sizeof(uint8_t));
			for(i=0;i<NODE_COUNT;i++){
				if(TOS_NODE_ID==Node_ID[i])
				{
				call Leds.set((uint8_t)7);
                                }
			}
					

		}

/* When poll from control is received*/
	event void PollSend.recvfrom(struct sockaddr_in6 *from, 
			void *data, uint16_t len, struct ip6_metadata *meta) {

		nx_struct poll_report *PollRcvd= (nx_struct poll_report*) data;
		
		r = (call Random.rand16())%10;         	//send car data after random delay to avoid collision of data at controller as poll is set according to time
		
		if (PollRcvd->type==POLL){
			memcpy (&route_control,from, sizeof(route_control));
			
			call RandomTimer.startOneShot(RANDOM_PERIOD *r);
				}

	}

	

	event void RadioControl.stopDone(error_t e) {}
}

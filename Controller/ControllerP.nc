#include <lib6lowpan/ip.h>
#include "controller.h"
#include "blip_printf.h"
#include <Timer.h>

module ControllerP {
	uses {
		interface Boot;
		interface Leds;
		interface SplitControl as RadioControl;
		interface UDP as AlarmSend;
		interface UDP as CarCountSend;
		interface UDP as PollSend;

		interface Timer<TMilli> as SendTimer;
		//interface Timer<TMilli> as ResetTimer;

		//Command to set and get the threhold values
		interface ShellCommand as ReadCmd;
		interface ShellCommand as NewThreshCmd;
		
	}

} implementation {

	enum {
		SEND_PERIOD =8000,  	//ms
		RESET_PERIOD=6000,
		POLL=1,			//poll flag set
		CONTROLLER=3,	//for the contoller node identification
		ALERT=5,
		NOALERT=6,
		POLL_ACK=2,
                CAR=4,

		};

	
	nx_struct poll_report PollReport;
	nx_struct alarm_report AlarmReport;
	nx_struct car_count_report  CarCountReport;

	struct sockaddr_in6 alarm_report_sock;
	struct sockaddr_in6 car_report_router_sock;
	struct sockaddr_in6 poll_request;

	//Default settings
	uint8_t count=0;
	uint8_t i=0;
	uint8_t j=0;
	uint8_t m_thresh=1;
	uint8_t Node_ID[NODE_COUNT];
	uint16_t PacketNumber=0;
	int Duplicate;
	int ALERT_FLAG=0;
	

	event void Boot.booted() {
		call RadioControl.start();
	}

	event void RadioControl.startDone(error_t e) {

		call SendTimer.startPeriodic(SEND_PERIOD);
		//call ResetTimer.startPeriodic(RESET_PERIOD);

/**************************************BInding Ports******************************************************************/	

	//IP and Port Binding for alarm		
		alarm_report_sock.sin6_port = htons(7000);
		inet_pton6(MULTICAST, &alarm_report_sock.sin6_addr);
		call AlarmSend.bind(7000);

	//IP and Port Binding for router
		car_report_router_sock.sin6_port = htons(8000);
		inet_pton6(REPORT_DEST, &car_report_router_sock.sin6_addr);

	//IP and Port Binding for poll
		poll_request.sin6_port = htons(4000);
		inet_pton6(MULTICAST, &poll_request.sin6_addr);
		call PollSend.bind(4000);	
	}

/***********************************Sending Data*******************************************************************************/

	// sending the polling request to the cars available in the network by multicast
	 void poll_car() {
		PollReport.type=POLL;
		PollReport.sender=TOS_NODE_ID;
		PollReport.sendertype=CONTROLLER;
		call PollSend.sendto(&poll_request, &PollReport, sizeof(PollReport));
		
	}

	/*When threshold is reached for the road traffic, alert is send to other car and administrator*/
	void traffic_alert(){
		AlarmReport.controllerID=TOS_NODE_ID;
		AlarmReport.car_count=count;
		memcpy(AlarmReport.car_divert,Node_ID,sizeof(uint8_t));
		call AlarmSend.sendto(&alarm_report_sock,&AlarmReport, sizeof(AlarmReport));
		call Leds.set((uint8_t)7);		
		
	}

	/*When normal report is sent to router*/
	void car_count_report(){
		PacketNumber++;
		CarCountReport.controllerID=TOS_NODE_ID;
		CarCountReport.car_count=count;
		CarCountReport.packetNo=PacketNumber;
		call CarCountSend.sendto(&car_report_router_sock,&CarCountReport, sizeof(CarCountReport));

	}

/*********************************Timer Fired*****************************************************/
	/*when polling is send Blue led glow*/
	event void SendTimer.fired() {
			if(ALERT_FLAG==1){
				CarCountReport.messageType=ALERT;
				car_count_report();
			}
			else{
				CarCountReport.messageType=NOALERT;
				car_count_report();

			}
			count=0;	
			j=0;
			memset(Node_ID,0, sizeof(Node_ID));
			ALERT_FLAG=0;
			call Leds.set((uint8_t)0);
			poll_car();
			
		}
/*	
	event void ResetTimer.fired() {
	
			call Leds.set((uint8_t)0);	//Leds reset so that for next polling result can be distinguable
			if(CarCountReport.messageType=NOALERT){
				car_count_report();
			}
			
			
		}*/

/**********************************Receive Event*******************************************************/
	event void AlarmSend.recvfrom(struct sockaddr_in6 *from, 
			void *data, uint16_t len, struct ip6_metadata *meta) {}

	event void CarCountSend.recvfrom(struct sockaddr_in6 *from, 
			void *data, uint16_t len, struct ip6_metadata *meta) {}

	/*When polling response is received Green Led is on*/
	event void PollSend.recvfrom(struct sockaddr_in6 *from, 
			void *data, uint16_t len, struct ip6_metadata *meta) {
		nx_struct poll_report *PollRcvd = (nx_struct poll_report*)data;
		call Leds.led1On();
		i=0;
		Duplicate=0;
		if (PollRcvd->type==POLL_ACK){
			while(i<NODE_COUNT){
				if(PollRcvd->sender==Node_ID[i]){
				   Duplicate=1;
				   break;
				}
				i++;
			}
			
			if(Duplicate!=1){
			  	count++;
				Node_ID[j]=PollRcvd->sender;
				j++;
				call Leds.led2On();	  
			  if (count>m_thresh){
				traffic_alert(); 
				CarCountReport.messageType=ALERT;
				ALERT_FLAG=1;
				car_count_report();
			  	}
			}			
	
		}

	}
	
/********************************Setting Threshhold***********************************************/
	/*Reading the value of currently set threshold*/
	event char* ReadCmd.eval(int argc, char** argv) {
		char* reply_buf = call ReadCmd.getBuffer(32);
		 
		sprintf(reply_buf,"Current Threshold Value is %d \n",m_thresh);
		return reply_buf;
	}
	
	/*changing the threhold of the traffic detection*/
	event char* NewThreshCmd.eval(int argc, char* argv[]) {
		char* reply_buf = call NewThreshCmd.getBuffer(64);
		if(argc == 2){
			m_thresh = atoi(argv[1]);
			call Leds.set((uint8_t)0);
			sprintf(reply_buf, "New Threshold %d\n", m_thresh);
		}
                else{sprintf(reply_buf, "Old Threshold %d and it is unchanged\n", m_thresh);}

		return reply_buf;
	}
	event void RadioControl.stopDone(error_t e) {}
}

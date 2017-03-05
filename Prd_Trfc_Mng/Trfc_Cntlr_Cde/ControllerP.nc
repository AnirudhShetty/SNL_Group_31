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
		interface UDP as TrfcMngSend;
		interface UDP as PollSend;
		interface UDP as SettingSend;

		interface Timer<TMilli> as SendTimer;
		interface Timer<TMilli> as TrfcTimer;

		//Command to set and get the threhold values
		interface ShellCommand as ReadCmd;
		interface ShellCommand as NewThreshCmd;
		
	}

} implementation {

	enum {
		SEND_PERIOD =3000,  	//ms
		TRFC_PERIOD =1000,
		POLL=1,			//poll flag set
		CONTROLLER=1,	//for the contoller node identification
		ALERT=1,
		NOALERT=0,
		SETTINGS_REQUEST = 1,
   		SETTINGS_RESPONSE = 2,
		TRAFFIC_MNG=5,
                PLL_ACK=2,
		

		};

	
	nx_struct poll_report PollReport;
	nx_struct alarm_report AlarmReport;
	nx_struct car_count_report  CarCountReport;
	nx_struct settings SettingsReport;
	nx_struct Trfc_managment Trfc_management_Report;

	struct sockaddr_in6 alarm_report_sock;
	struct sockaddr_in6 car_report_router_sock;
	struct sockaddr_in6 poll_request;
	struct sockaddr_in6 setting_change_sock;
	struct sockaddr_in6 Trfc_Mng_sock;
	
	

	//Default settings
	uint8_t count=0;
	uint8_t OthrCordCount=0;
	uint8_t	OthCordID=0;
	uint8_t Trfc_tot_count=0;
	uint8_t i=0;
	uint8_t j=0;
        uint8_t k=0;
        uint8_t Overflow=0;
	uint8_t m_thresh=1;
	uint8_t Node_ID[NODE_COUNT];
        uint8_t Divert_ID[NODE_COUNT];
	uint16_t PacketNumber=0;
	int Duplicate=0;
	int ALERT_FLAG=0;
	

	event void Boot.booted() {
		call RadioControl.start();
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
                //change
                Overflow = Trfc_tot_count-m_thresh;
		AlarmReport.controllerID=TOS_NODE_ID;
		AlarmReport.car_count=Trfc_tot_count;
                /*k=0;
                while(k<NODE_COUNT){
				if(k> Overflow || k==Overflow){ 
                                   Node_ID[k] = 0;  
				}
				k++;
                                Divert_ID
                } */
		memcpy(AlarmReport.car_divert,Node_ID,sizeof(uint8_t));
                //CarCountReport.messageType=ALERT;
                //car_count_report();
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

	/*Asking for setting*/
	void requestSettings() {
		SettingsReport.type = SETTINGS_REQUEST;
		call SettingSend.sendto(&setting_change_sock, &SettingsReport, sizeof(SettingsReport));
	}

	
	/*Sending the updated settings to other controllers*/
	void send_setting(){
		SettingsReport.type=SETTINGS_RESPONSE;
		SettingsReport.threshold=m_thresh;
		call SettingSend.sendto(&setting_change_sock,&SettingsReport, sizeof(SettingsReport));
	}
	/*Sending traffic data*/
	void send_traffic(){
		Trfc_management_Report.type=TRAFFIC_MNG;
		Trfc_management_Report.controllerID=TOS_NODE_ID;
		Trfc_management_Report.totcount=count;
		call TrfcMngSend.sendto(&Trfc_Mng_sock,&Trfc_management_Report, sizeof(Trfc_management_Report));
		}

/********************************Checking**********************************************/

	void trfc_thresh_check(){
		Trfc_tot_count=count+OthrCordCount;
		if(Trfc_tot_count>m_thresh){
			call Leds.set(1);
			if(count<OthrCordCount){
				traffic_alert();
		                CarCountReport.messageType=ALERT;
				ALERT_FLAG=1;
				car_count_report();
				}
			}
	
	}
/*******************Start Radio Control**********************************************/
	event void RadioControl.startDone(error_t e) {

		call SendTimer.startPeriodic(SEND_PERIOD);
		call TrfcTimer.startPeriodic(TRFC_PERIOD);
		requestSettings();

		/***BInding Ports*******/	

	//IP and Port Binding for alarm		
		alarm_report_sock.sin6_port = htons(7000);
		inet_pton6(MULTICAST, &alarm_report_sock.sin6_addr);
		call AlarmSend.bind(7000);

	//IP and Port Binding for settings		
		setting_change_sock.sin6_port = htons(5000);
		inet_pton6(MULTICAST, &setting_change_sock.sin6_addr);
		call SettingSend.bind(5000);

	//IP and Port Binding for router
		car_report_router_sock.sin6_port = htons(8000);
		inet_pton6(REPORT_DEST, &car_report_router_sock.sin6_addr);

	//IP and Port Binding for poll
		poll_request.sin6_port = htons(4000);
		inet_pton6(MULTICAST, &poll_request.sin6_addr);
		call PollSend.bind(4000);

	//IP and Port Binding for trafffic Management
		Trfc_Mng_sock.sin6_port = htons(6000);
		inet_pton6(MULTICAST, &Trfc_Mng_sock.sin6_addr);
		call TrfcMngSend.bind(6000);	
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
                        //CarCountReport.messageType=NOALERT;
			//car_count_report();
			count=0;	
			j=0;
			memset(Node_ID,0, sizeof(Node_ID));
			ALERT_FLAG=0;
			Trfc_tot_count=0;
			call Leds.set((uint8_t)0);
			poll_car();
			
		}
	event void TrfcTimer.fired() {
			
			send_traffic();
		}

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
		//call Leds.led2On();	 
		if (PollRcvd->type==PLL_ACK){
			while(i<NODE_COUNT){
				if(PollRcvd->sender==Node_ID[i]){
				   call Leds.led0On();
				   Duplicate=1;
				   break;
				}
				i++;
			}
			
			if(Duplicate!=1){
			  	count++;
				Node_ID[j]=PollRcvd->sender;
				j++;
				//call Leds.led0On();	  
			  if (count>m_thresh){
				//traffic_alert(); 
				CarCountReport.messageType=ALERT;
				ALERT_FLAG=1;
				car_count_report();
                                traffic_alert();
				call Leds.set((uint8_t)1);
				send_traffic();
		               /* CarCountReport.messageType=ALERT;
				ALERT_FLAG=1;
				car_count_report();
                                send_traffic();
				*/
			  	}
			}			
	
		}

	}
	
	event void SettingSend.recvfrom(struct sockaddr_in6 *from, 
			void *data, uint16_t len, struct ip6_metadata *meta) {
		nx_struct settings *recivedSettings = (nx_struct settings*)data;
		
		switch( recivedSettings->type ) {
			case SETTINGS_REQUEST:
				send_setting();
				break;
			case SETTINGS_RESPONSE:
				m_thresh=recivedSettings->threshold;
				break;
		}
	}
	
	event void TrfcMngSend.recvfrom(struct sockaddr_in6 *from, 
			void *data, uint16_t len, struct ip6_metadata *meta) {
		nx_struct Trfc_managment *recivedTrfcMngmnt = (nx_struct Trfc_managment*)data;
		if (recivedTrfcMngmnt->type==TRAFFIC_MNG){
			OthrCordCount=recivedTrfcMngmnt->totcount;
			OthCordID=recivedTrfcMngmnt->controllerID;
			//call Leds.set(3);
			}
		//trfc_thresh_check();
		Trfc_tot_count=count+OthrCordCount;
		if(Trfc_tot_count>m_thresh){
			call Leds.set(7);
			if(count<OthrCordCount || count==OthrCordCount){
                                 //Overflow = Trfc_tot_count-m_thresh;
                                 /*k=0;
                                 while(k<NODE_COUNT){
				if(k< Overflow || k==Overflow){ 
                                   Divert_ID[k] = 0;  
				}
				k++;
                                
                                } */
				traffic_alert();
		                CarCountReport.messageType=ALERT;
				ALERT_FLAG=1;
				car_count_report();
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
			send_setting();
		}
                else{sprintf(reply_buf, "Old Threshold %d and it is unchanged\n", m_thresh);}

		return reply_buf;
	}
	event void RadioControl.stopDone(error_t e) {}
}

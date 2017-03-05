#ifndef CONTROLLER_H_
#define CONTROLLER_H_

enum {
      AM_SENSING_REPORT = -1
};

#define NODE_COUNT 6

/*polling request format sent to the cars within the network*/
nx_struct poll_report {
	nx_uint16_t sender;
	nx_uint8_t sendertype;
	nx_uint16_t type;
};
/***Setings for threshold********/
nx_struct settings {
	nx_uint8_t type;
	nx_uint8_t threshold;
};

nx_struct Trfc_managment {
	nx_uint8_t type;
	nx_uint16_t controllerID;
	nx_uint8_t totcount;
};

/*alert msg format sent to the administrator and other cars of the network*/
nx_struct alarm_report {
	nx_uint16_t controllerID;
	nx_uint8_t  car_divert[NODE_COUNT];
	nx_uint16_t car_count;
};

/*car count report to administrator router*/
nx_struct car_count_report{
	nx_uint8_t messageType;
	nx_uint16_t packetNo;
	nx_uint16_t controllerID;
	nx_uint8_t car_count;
};

#define REPORT_DEST "fec0::100"
#define MULTICAST "ff02::1"
#endif

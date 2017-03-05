#ifndef NODE_H_
#define NODE_H_

enum {
      AM_SENSING_REPORT = -1
};

#define NODE_COUNT 6

nx_struct alarm_report {
	nx_uint16_t controllerID;
	nx_uint8_t  car_divert[NODE_COUNT];
	nx_uint16_t car_count;
};

nx_struct poll_report{
  	nx_uint16_t sender;
	nx_uint8_t sendertype;
  	nx_uint16_t type;
};

#define REPORT_DEST "fec0::100"
#define CONTROLLER_DEST "fec0::"
#define CONTROLLER_DEST1 "fec0::2"
#define CONTROLLER_DEST2 "fec0::3"

#endif

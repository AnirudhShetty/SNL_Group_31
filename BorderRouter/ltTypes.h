#ifndef LTTYPES_H
#define LTTYPES_H

typedef enum {
  STATE_INIT = 0,
  STATE_IDLE,
  STATE_PREGAME,
  STATE_DISCOVERY,
  STATE_GAME,
  STATE_POSTGAME,
} state_t;

enum {
      PENG_MESSAGE       = 1,
      HIT_MESSAGE        = 2,
      DISCOVERY_MESSAGE  = 3,
      ENDOFGAME_MESSAGE  = 4,
      LIFCOUNT_MESSAGE   = 5,
      START_MESSAGE      = 6,
      DEBUG_MESSAGE      = 7,
      HIT_MESSAGE_TO_GUN  = 8,
};

enum {
	RELOADING_IN_PROGRESS,
	RELOADING_READY,
};

nx_struct radioMessage_t {
  nx_uint8_t type;
  nx_uint8_t data;
};

struct debugMessage_t {
  uint8_t type;
  char msg[32];
};

#endif

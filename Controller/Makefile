COMPONENT=ControllerC

TOSMAKE_PRE_EXE_DEPS = NodeID.py
NodeID.py: controller.h
	mkdir -p utils
	nescc-mig python -I$(TOSROOT)/tos/lib/net/blip \
	-I$(TOSROOT)/support/sdk/c/blip/lib6lowpan \
	-python-classname=NodeID controller.h car_count_report \
	-o utils/NodeID.py

CFLAGS += -DCC2420_DEF_CHANNEL=$(TOS_CHANNEL)

#blip2.0
PFLAGS += -DIN6_PREFIX=\"fec0::\"
PFLAGS += -DLIB6LOWPAN_HC_VERSION=6

#rpl
PFLAGS += -DRPL_ROUTING -DRPL_STORING_MODE -I$(TINYOS_OS_DIR)/lib/net/rpl
PFLAGS += -DRPL_OF_0=1
PFLAGS += -DRPL_OF_MRHOF=0
PFLAGS += -DBLIP_SEND_ROUTER_SOLICITATIONS=1
PFLAGS += -DBLIP_SEND_ROUTER_ADVERTISEMENTS=1

#printf
PFLAGS += -DNEW_PRINTF_SEMANTICS -DPRINTFUART_ENABLED
CFLAGS += -I$(TINYOS_OS_DIR)/lib/printf

TINYOS_ROOT_DIR?=$(WSNPR_TOSROOT)

GOALS += blip rpl

include $(TINYOS_ROOT_DIR)/Makefile.include


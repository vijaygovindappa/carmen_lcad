include ../Makefile.conf

MODULE_NAME = Virtual Scan
MODULE_COMMENT = Abstract polar 2D representation of 2D or 3D range scanner data

CC = cc -std=c++0x
CFLAGS += -Wall -std=c++0x
CXXFLAGS += -Wall -std=c++0x
LINK = g++

IFLAGS += -I$(CARMEN_HOME)/sharedlib/libclustering
LFLAGS += -L$(CARMEN_HOME)/sharedlib/libclustering
LFLAGS += -L$(CARMEN_HOME)/sharedlib/libtf/src

LFLAGS += \
	-lgrid_mapping -lmap_io -lmap_interface -lmapper_interface -lparam_interface -lipc -lglobal -lmap_server_interface \
	-lmoving_objects_interface -lvelodyne_interface -ltf -lboost_thread-mt -lboost_signals -lboost_system -ldbscan

SOURCES = \
	virtual_scan.cpp \
	virtual_scan_interface.cpp \
	virtual_scan_main.cpp

PUBLIC_INCLUDES = \
	virtual_scan_interface.h \
	virtual_scan_messages.h

PUBLIC_LIBRARIES = \
	libvirtual_scan_interface.a

PUBLIC_BINARIES = \
	virtual_scan 
	
TARGETS = \
	libvirtual_scan_interface.a libclustering \
	virtual_scan 
	
# If you set graphics support in configure.
ifndef NO_GRAPHICS
#Carmen Global Graphic Library and Gtk+2 Graphics Libraries
IFLAGS += \
	`pkg-config --cflags gtk+-2.0 gmodule-export-2.0` \
	`pkg-config --cflags gtkglext-1.0`
LFLAGS += \
	-lglobal_graphics \
	`pkg-config --libs gtk+-2.0 gmodule-export-2.0` \
	`pkg-config --libs gtkglext-1.0`
endif

libclustering:
	$(MAKE) -C $(CARMEN_HOME)/sharedlib/libclustering
	
clean: clean_libclustering

clean_libclustering:
	$(MAKE) clean -C $(CARMEN_HOME)/sharedlib/libclustering

libvirtual_scan_interface.a: \
	virtual_scan_interface.o

virtual_scan: \
	virtual_scan_main.o \
	virtual_scan.o \
	virtual_scan_interface.o

include ../Makefile.rules


include $(CARMEN_HOME)/src/Makefile.conf

CXXFLAGS += -Wno-write-strings -std=c++0x -Wno-sign-compare

IFLAGS += -I/usr/include/suitesparse -I/usr/include/eigen3 -I/usr/local/include/EXTERNAL/csparse/ \
	 -I/usr/local/include/ -I$(CARMEN_HOME)/sharedlib/prob_models $(G2O_IFLAGS)

LFLAGS += -L$(CARMEN_HOME)/sharedlib/libcarmodel
LFLAGS += -L$(CARMEN_HOME)/sharedlib/libcontrol
	
LFLAGS += -lglobal -lipc -llocalize_ackerman_interface -lrobot_ackerman_interface -lbehavior_selector_interface \
	-lobstacle_avoider_interface -lcollision_detection -lobstacle_distance_mapper_interface \
	-L$(CARMEN_HOME)/sharedlib/prob_models -lparam_interface -lrobot_ackerman_interface \
	-llaser_interface `pkg-config --libs opencv` -lparam_interface \
	-lsimulator_ackerman -lcontrol -lcarmodel -lfann -lgsl -lgslcblas -lgeometry -lrddf_interface \
	-lnavigator_ackerman_interface -lmapper_interface

MODULE_NAME = carmen_comm
MODULE_COMMENT = Infra-structure for communicating with carmen via Python 

SOURCES = carmen_comm.cpp save_commands_dataset.cpp util.cpp test_carmen_comm.cpp
TARGETS =  libcarmen_comm_cpp.a pycarmen_comm save_commands_dataset test_carmen_comm 

test_carmen_comm: test_carmen_comm.o carmen_comm.o util.o 
save_commands_dataset: save_commands_dataset.o
libcarmen_comm_cpp.a: carmen_comm.o util.o
clean: pycarmen_comm_clean

PY_INC = -I `python -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())"`
PY_LIB = -L `python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())"` 
PY_LIB += `python3-config --libs`

pycarmen_comm:
	swig -python -c++ carmen_comm.i
	g++ -fPIC -c carmen_comm_wrap.cxx $(PY_INC) 
	g++ -shared carmen_comm_wrap.o libcarmen_comm_cpp.a -o _carmen_comm.so $(PY_LIB) $(LFLAGS)

pycarmen_comm_clean:
	rm carmen_comm.py carmen_comm_wrap.cxx

include $(CARMEN_HOME)/src/Makefile.rules

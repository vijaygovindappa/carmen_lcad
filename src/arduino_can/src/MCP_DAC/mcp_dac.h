#ifndef _MCP4922_H_
#define _MCP4922_H_

#include <Arduino.h>
#include <SPI.h>
#include <inttypes.h>

#define DAC_A 0
#define DAC_B 1

class MCP_DAC
{
    private:
		int MCPCS;
		uint16_t config[2];
/*
 channel | buffer | gain | shutdown | 12-bit Data

channel: 	0 - A, 			1 - B
buffer: 	0 - Unbuffered,	1 - Buffered
gain: 		0 - 2x, 		1 - 1x
shutdown:	0 - Shutdown,	1 - Active			
*/		
				
		
	public:
    	MCP_DAC(int _CS);
		void begin();

		void gain(int channel, bool gain);
		void buffered(int channel, bool buf);
		void off(int channel);
		void write( int channel, uint16_t data);
};

#endif

CON
  _clkmode = xtal1 + pll16x ' System clock → 80 MHz
  _xinfreq = 5_000_000

 GainScale = 1000
 numOfMotors = 8
 posErrIntThreshold = 100  'Threshold from which start integrating position err to avoid integral windup

 posErrIntMax = 330

 stadyStateErr = 1 'Try to get within 1 encoder count
 _axisToQuery = 6

VAR
  long ctrlParamA[numOfMotors]
  long ctrlParamB[numOfMotors]
  long ctrlParamC[numOfMotors]
  long ctrlParamD[numOfMotors]
  long _encoderStartAddr
  long _duration
  long _time
  long _axisDesiredPos
  long _axisDesiredVel
  long _axisPosErr
	long _axisPWM
  long stack[500]
  byte cog 

  
PUB Start(PWMStartAddr, EncoderStartAddr) : success | idx
  
  _encoderStartAddr := EncoderStartAddr

  'init ctrl params
  repeat idx from 0 to numOfMotors-1
    ctrlParamA[idx] := 0
    ctrlParamB[idx] := 0
    ctrlParamC[idx] := 0
    ctrlParamD[idx] := 0

  if (cog == 0)
    success := cog := cognew(PIDLoop(PWMStartAddr, EncoderStartAddr), @stack)
  else
    success := false

PUB Stop
  cogstop(cog)
  cog := 0

PUB isStarted : started

  if (cog == 0)
    started := false
  else
    started := true
  
PUB SetSingleAxisPos(axis, position, duration) : success | tmp

  success := true 'check if position is valid

  if ( axis > numOfMotors-1)
    success := false
    return false

  _duration := duration
  repeat tmp from 0 to numOfMotors-1
    if (tmp == axis)
      SetAxisParam(axis, position)
    else
      SetAxisParam(tmp, long[_encoderStartAddr + 4*tmp])

  _time := 0

PUB SetAxisPos(axis0, axis1, axis2, axis3, axis4, axis5, axis6, axis7, duration) : success 

  success := true 'check if position is valid

  _duration := duration
  SetAxisParam(0, axis0)
  SetAxisParam(1, axis1)
  SetAxisParam(2, axis2)
  SetAxisParam(3, axis3)
  SetAxisParam(4, axis4)
  SetAxisParam(5, axis5)
  SetAxisParam(6, axis6)
  SetAxisParam(7, axis7)
  _time := 0


PRI SetAxisParam(axis, position) | tmp, currentPos
  currentPos := long[_encoderStartAddr + 4*Axis] 

  'Perform the division by duration latter to avoid overflow
  tmp := (position-currentPos) '/(duration*duration)

  ctrlParamA[axis] := currentPos
  ctrlParamB[axis] := 0
  ctrlParamC[axis] := 3*tmp
  ctrlParamD[axis] := -2*tmp '/duration 


PUB getTime : time
  time := _time

PUB getAxisPWM : pwm
	pwm := _axisPWM

PUB getAxisPosErr : posErr
	posErr := _axisPosErr

PUB getAxisDesiredPos : pos
  pos := _axisDesiredPos

PUB getAxisDesiredVel : vel
  vel := _axisDesiredVel

PRI PIDLoop(PWMStartAddr, EncoderStartAddr ) | PWMAddr[numOfMotors], EncoderAddr[numOfMotors], targetPos[numOfMotors], targetVel[numOfMotors], lastPos[numOfMotors], intPosErr[numOfMotors], us, currentPos, currentVel, posErr, velErr, pwm, idx, startTime, dTime, time, duration, durationCub, timeSq, ct, dt, dtSq, dtCub, Pgain[numOfMotors], Dgain[numOfMotors], Igain[numOfMotors], maxPWM[numOfMotors], threshPWM[numOfMotors]

  '#################################Initialize the memory pointers################################'
  repeat idx from 0 to numOfMotors-1
    PWMAddr[idx] := PWMStartAddr + idx*4

  repeat idx from 0 to numOfMotors-1
    EncoderAddr[idx] := _encoderStartAddr + idx*4

  repeat idx from 0 to numOfMotors-1
    intPosErr[idx] := 0
    
  'Set the gains
	'Base
  Pgain[0]     := 3000
  Dgain[0]     := 20000' -1000
  Igain[0]     := 280  '1000 
  maxPWM[0]    := 900
  threshPWM[0] := 0 

  'Shoulder
  Pgain[1]     := 10000  '9000 '15000
  Dgain[1]     := 5000
  Igain[1]     := 270   '1000
  maxPWM[1]    := 900
  threshPWM[1] := 00

	'Elbow
  Pgain[2]     := 2600 '9000
  Dgain[2]     := 20000 
  Igain[2]     := 340 ' 400 
  maxPWM[2]    := 900
  threshPWM[2] := 00

  'Wrist1
  Pgain[3]     := 2300 ' 9000
  Dgain[3]     := 5000 
  Igain[3]     := 550 
  maxPWM[3]    := 900
  threshPWM[3] := 0

	'Wrist2
  Pgain[4]     := 2400' 2300
  Dgain[4]     := 4000
  Igain[4]     := 490
  maxPWM[4]    := 900
  threshPWM[4] := 0

	'Gripper
  Pgain[5]     := 0 
  Dgain[5]     := 0 
  Igain[5]     := 0 
  maxPWM[5]    := 0
  threshPWM[5] := 0

  'Linear slide
  Pgain[6]     :=  1900
  Dgain[6]     :=  9000   
  Igain[6]     :=  130    
  maxPWM[6]    :=  800
  threshPWM[6] :=  0      
  
  'Ex2
  Pgain[7]     := 0' -150 
  Dgain[7]     := 0' -200 
  Igain[7]     := 0 
  maxPWM[7]    := 0' 100 
  threshPWM[7] := 0' 80

  'Precompute the number of clock ticks in 1µs
  us := clkfreq/1_000_000
     
	startTime := cnt
  repeat

    'For efficent computations
    dTime := cnt-startTime
    startTime := cnt
    time := _time + 1 '(dTime * 10_000)/clkfreq 
    if (time > _duration)
      time := _duration
    _time := time

    timeSq := time * time

    duration := _duration
    durationCub := duration * duration * duration

    dt := time '((time*duration)/duration)
    dtSq := dt*dt
    dtCub := dtSq * dt


    repeat idx from 0 to numOfMotors-1  'Update each motor PID

			 'Skip the gripper
			 if(idx == 5)
					next

       currentPos := long[EncoderAddr[idx]]

       'Compute the desired pos and vel control 


       targetPos[idx] := ctrlParamA[idx]
       targetPos[idx] := targetPos[idx] + ((dt*((dt*ctrlParamC[idx])/duration))/duration)  'TO avoid overflow
       targetPos[idx] := targetPos[idx] + ((dt*((dt*((dt*ctrlParamD[idx])/duration))/duration))/duration) 'To avoid overflow

       targetVel[idx] := (2*((dt*ctrlParamC[idx])/duration))/duration
       targetVel[idx] := targetVel[idx] + (dt*(3*((dt*ctrlParamD[idx])/duration))/duration)/duration

       currentVel := currentPos - lastPos[idx]

       posErr := targetPos[idx] - currentPos


       'if (posErr < posErrIntThreshold)
       '   intPosErr[idx] := intPosErr[idx] + posErr

       intPosErr[idx] := intPosErr[idx] + posErr

       if(intPosErr[idx] > posErrIntMax)
           intPosErr[idx] := posErrIntMax
       if(intPosErr[idx] < -posErrIntMax)
           intPosErr[idx] := -posErrIntMax

       velErr := targetVel[idx]-currentVel

       'pwm := (Pgain[idx]*posErr) + (Dgain[idx]*velErr) + (intPosErr[idx]*Igain[idx])
			 pwm := (Pgain[idx] * posErr) + (Dgain[idx]*targetVel[idx]) + (intPosErr[idx]*Igain[idx])
       pwm := pwm / GainScale


       lastPos[idx] := currentPos

			 'If we have not reached stady state and the pwm is bellow the static friction (non linear control)
			 'Then apply just the threshold to get us moving
			 if (time => duration	and threshPWM > 0) '||currentVel == 0 and ||posErr > stadyStateErr)
			 		if (pwm > 0)
			    		pwm := threshPWM[idx]
			  	if (pwm < 0)
			    		pwm := -1*threshPWM[idx]

			 if (_axisToQuery == idx)
				 _axisDesiredPos := targetPos[idx]
				 _axisDesiredVel := targetVel[idx]
				 _axisPosErr     := intPosErr[idx]'posErr
				 _axisPWM        := pwm

       'Clamp the output power to [-100 100]
       if pwm >  maxPWM[idx]
         pwm :=  maxPWM[idx]
       elseif pwm < (-1*maxPWM[idx])
         pwm := (-1*maxPWM[idx])



  
       'Offset the power so that 0 is full backwards, and 200 is full forwards. 100 stops the motors
       pwm := pwm + 1000

       'Convert the output power to clock ticks of a 64µs period. 0% duty cycle is full backwards,
       '50% duty cycle is stopped, and 100% duty cycle is full forwards 
       long[PWMAddr[idx]] := -((( (64 * pwm) / 2000)) * us)

			 waitcnt(8_000 + cnt)
	

    'end repeat
  'end repeat

function [Data] = ccalcHPR_YUPDOWN(Data, Config)

L=length(Data.Burst_EnsembleCount);

for i=1:L
  % Use the sign of the y axis to determine the up/down orientation of the instrument. 
  ydown = (Data.Burst_AccelerometerY(i) < 0);
  stat = Data.Burst_Status(i);
  stat = bitset(uint32(stat), 25, 0);
  stat = bitset(uint32(stat), 26, 0);
  stat = bitset(uint32(stat), 27, 0);
  stat = bitor(uint32(stat), bitshift(2+ydown, 25));
  Data.Burst_Status(i) = stat;
  
  if (ydown)
     % AD2CP_ORIENTATION_YDOWN:
     Ax =  Data.Burst_AccelerometerZ(i);  	
     Ay =  Data.Burst_AccelerometerX(i);   	
     Az =  Data.Burst_AccelerometerY(i);  	
     
     Mx =  Data.Burst_MagnetometerZ(i);  	
     My =  Data.Burst_MagnetometerX(i);   	
     Mz =  Data.Burst_MagnetometerY(i);  	
  else
     % AD2CP_ORIENTATION_YUP:
     Ax =  Data.Burst_AccelerometerZ(i);  	
     Ay = -Data.Burst_AccelerometerX(i);   	
     Az = -Data.Burst_AccelerometerY(i);  	
     
     Mx =  Data.Burst_MagnetometerZ(i);  	
     My = -Data.Burst_MagnetometerX(i);   	
     Mz = -Data.Burst_MagnetometerY(i);  	
  end

  Ax = -Ax;
  Ay = -Ay;
  Az = -Az;
   
  roll = atan2(Ay, Az);    
  cosr = cos(roll);
  sinr = sin(roll);
  d1 = Ay*sinr;
  d2 = Az*cosr;
   
  pitch = atan(-Ax/(d1+d2));  
 
  Data.Burst_Pitch(i) = 180*pitch/pi;
  Data.Burst_Roll(i)  = 180*roll/pi;

  sinPitch = sin(pitch);
  cosPitch = cos(pitch);
  sinRoll = sin(roll);
  cosRoll = cos(roll);
  sinPsinR = sinPitch*sinRoll;
  sinPcosR = sinPitch*cosRoll;

  earthHy = Mz*sinRoll - My*cosRoll;
  earthHx = Mx*cosPitch + My*sinPsinR + Mz * sinPcosR;

  heading = atan2(earthHy, earthHx);
%  headingDeg = 180*heading/pi + Config.user_decl;
  headingDeg = 180*heading/pi;
  if (headingDeg < 0)
     headingDeg = headingDeg + 360;
  end
  
  Data.Burst_Heading(i) = headingDeg;
  
end

end
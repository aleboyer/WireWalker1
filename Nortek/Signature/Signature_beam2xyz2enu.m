function Data = Signature_beam2xyz2enu( Data)


T_beam2xyz = [0.6782     0       -0.6782   0;...
              0          -1.1831   0       1.1831;...
              0.2644     0.3546   0.2644   0.3546];

          
%Data=AQDprofiles{1};
              
beam = zeros( size( T_beam2xyz, 2 ), length(Data.Burst_MatlabTimeStamp) );
beam( 1, : ) = Data.Burst_VelBeam1';
beam( 2, : ) = Data.Burst_VelBeam2';
beam( 3, : ) = Data.Burst_VelBeam3';
beam( 4, : ) = Data.Burst_VelBeam4';

xyz = T_beam2xyz * beam;
%xyz = [xyz(3,:);xyz(1,:);xyz(2,:)]; %YDOWN YUP
              
Data.Burst_VelEast  = Data.Burst_MatlabTimeStamp*0;
Data.Burst_VelNorth = Data.Burst_MatlabTimeStamp*0;
Data.Burst_Up       = Data.Burst_MatlabTimeStamp*0;


for sampleIndex = 1:length(Data.Burst_Status)
    xyz1=xyz(:,sampleIndex);
    switch bitand(bitshift(uint32(Data.Burst_Status(sampleIndex)), -25),7)
        case 0
          signXYZ=[1 1 1]; % XUP
          xyz1 = xyz1([2,3,1]); %XDOWN YUP
        case 1
          signXYZ=[1 -1 -1]; % XDOWN
          xyz1 = xyz1([2,3,1]); %XDOWN YUP
        case 2
          signXYZ=[1 1 1]; % YUP
          xyz1 = xyz1([3,1,2]); %YDOWN YUP
        case 3
          signXYZ=[1 -1 -1]; % YDOWN
          xyz1 = xyz1([3,1,2]); %YDOWN YUP
        case 4
          signXYZ=[1 1 1];   % ZUP
          xyz1 = xyz1([1,2,3]); %YDOWN YUP
        case 5 
          signXYZ=[1 -1 -1]; % ZDOWN
          xyz1 = xyz1([1,2,3]); %YDOWN YUP
        case 7
          signXYZ=[1 1 1]; % AHRS
          xyz1 = xyz1([1,3,2]); %YDOWN YUP
    end
  
 
   hh = pi*(Data.Burst_Heading(sampleIndex)-90)/180;
   pp = pi*Data.Burst_Pitch(sampleIndex)/180;
   %pp = pi*Data.Burst_AccelerometerY(sampleIndex)*55/180;
   rr = pi*Data.Burst_Roll(sampleIndex)/180;
   %rr = -pi*rolli(sampleIndex)/180; %test for LAJIT d1 ... changed nothing
   
   % Make heading matrix
   H = [cos(hh) sin(hh) 0; -sin(hh) cos(hh) 0; 0 0 1];

   % Make tilt matrix
   P = [cos(pp) -sin(pp)*sin(rr) -cos(rr)*sin(pp);...
         0             cos(rr)          -sin(rr);  ...
         sin(pp) sin(rr)*cos(pp)  cos(pp)*cos(rr)];

   % Make resulting transformation matrix
   xyz2enu = H*P; 

   ENU = xyz2enu * (signXYZ.' .* xyz1);
   
   Data.Burst_VelEast(sampleIndex)  = ENU(1);
   Data.Burst_VelNorth(sampleIndex) = ENU(2);
   Data.Burst_Up(sampleIndex)       = ENU(3);
end
Data.Burst_VelEast=medfilt1(Data.Burst_VelEast,20);
Data.Burst_VelNorth=medfilt1(Data.Burst_VelNorth,20);
Data.Burst_Up=medfilt1(Data.Burst_Up,20);


       
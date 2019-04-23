function XYZ = ENU2XYZ(velE, velN, velU, P, R, H)
% convert xyz velocity to ENU velocity for Signature 1000
% velx/y/z - xyz velocity in form [profile# * cell#]
% R - Roll angle (Rotate around X) in degree
% P - Pitch angle (Rotate around Y) in degree
% H - Yaw angle (Rotate around Z) in degree

% Arnaud Le Boyer from Bofu Zheng
% Apr. 16 2019

% from xyz to ENU
hh = pi*(H - 90)/180;     % Heading-90 degrees for ENU velocity
pp = pi*P/180;
rr = pi*R/180;

for j = 1:length(P)
    % Make heading matrix
    H = [cos(hh(j)) sin(hh(j)) 0; -sin(hh(j)) cos(hh(j)) 0; 0 0 1];
    
    % Make tilt matrix
    P = [cos(pp(j)) -sin(pp(j))*sin(rr(j)) -cos(rr(j))*sin(pp(j));...
        0             cos(rr(j))          -sin(rr(j));  ...
        sin(pp(j)) sin(rr(j))*cos(pp(j))  cos(pp(j))*cos(rr(j))];
    
    % Make resulting transformation matrix
    R = H*P;
    
    velenu = [velE(j,1,:); velN(j,2,:); velU(j,3,:)];
    % calculate XYZ
    XYZ = velenu ./ R;      % Beam velocity to ENU



end

end

function [data, tau,L,fval] = ww_despike(T,C,P,figures)
% Salinity spiking correction.
% edited by Celia, for LaJIT Wirewalker. 2015-01-28
% T,C,P are vectors from a single cast.
% Calculates and applies a correction to the 6Hz temperature data. 
% The correction aims to make temperature and conductivity be in phase. 
% The raw and corrected series of temperature, 
% conductivity, pressure, salinity, fluorescense, transmissivity and 
% dissolved oxygen are stored in a structure and output with NaN ends.
% data.time_cut is the indices of the input that are preserved in output.

% Robert Todd, 2006-12-5
% Updates:
%  2006-12-19 (Robert Todd): changed to use entire length of time series;
%                            changed to overwrite uncorrected series;
%                            remove some extra plotting/comparison; include
%                            trans, fl, oxygen in LP filter; change function
%                            name from salinity_correction to ctd_correction;
%                            output structure instead of saving to .mat file

% figures: 0 for no figures, 1 for figures

% close all

% Spectral Analysis of Raw Data---------------------------------------------%

dt = 1/6;       % 6 Hz 

n = 2^6; % Number of points per segment
m = fix(length(T)/n); % Number of segments
N = n*m;
[x,fval] = find_tauL(T(1:N),C(1:N));
tau = x(1);
L = x(2);
% tau = 'L'; L = x;


    %%%%
    function [x,fval] = find_tauL(t,c)
At = fft(detrend(reshape(t,n,m)).*(window(@triang,n)*ones(1,m)));              % Data are detrended then
Ac = fft(detrend(reshape(c,n,m)).*(window(@triang,n)*ones(1,m)));  
At = At(1:n/2-1,:); % Positive frequencies only
Ac = Ac(1:n/2-1,:);
% Frequency 
f = ifftshift(linspace(-n/2,n/2-1,n)/(n*dt)); % +/- frequencies
f = f(:);
f = f(1:n/2-1); % Positive frequencies only
df = 1/(n*dt);

% spectra

Et = 2*mean(At.*conj(At)/df/n^2,2);          % spectrum
Ec = 2*mean(Ac.*conj(Ac)/df/n^2,2);
Ctc = 2*mean(At.*conj(Ac)/df/n^2,2);        % cross spectrum
Cohtc = Ctc.*conj(Ctc)./(Et.*Ec);       % coherence^2
Phitc = atan2(imag(Ctc),real(Ctc));       % cross-spectral phase 

% CI

% Determine tau and L--------------------------------------------------%
W1 = diag(1./(1+(f/1.5).^10)); % Matrix of weights
% W1 = diag(Cohtc);
% figure; plot(f,diag(W1),'g');
[x fval] = fminsearch(@atanfit,[0,0],[],f,Phitc,W1); % Nonlinear fit
    %%%%

% Plots of Spectral Quantities for Uncorrected Data--------------------%

if figures
  % Coherence between Temperature and Conductivity
  figure(1)
  plot(f, Cohtc,'b'); hold on;
  xlabel('Frequency (Hz)')
  ylabel('Squared Coherence')
  set(gca,'YLim',[0 1])

  % Phase between Temperature and Conductivity
  figure(2)
  plot(f, Phitc,'b'); hold on;
  plot(f, -atan(2*pi*f*x(1))-2*pi*f*x(2),'g--')
%   plot(f, -2*pi*f*x,'g--')
  xlabel('Frequency (Hz)')
  ylabel('Phase (rad)')

  drawnow
end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f = atanfit(x,fr,Phi,W)
M = find(Phi(2:end)>0,1,'first');
% f = 2*pi*fr(2:M)*x+Phi(2:M); % only lag
f = atan(2*pi*fr(1:M)*x(1))+2*pi*fr(1:M)*x(2)+Phi(1:M);
f = f'*W(1:M,1:M)*f;
% mean square error to be minimized w.r.t tau,L
% weight by Coh^8 to emphasize low frequencies
end
    %%%%
% Apply Phase Correction and LP Filter----------------------------------------%
% % % % % Without breaking profile into segments.
% % % % N = fix(length(T)/2)*2;
% % % % f = ifftshift(linspace(-N/2,N/2-1,N)/(N)/dt);
% % % % f = f(:);
% % % % H1 = (1+1i*2*pi*f*tau).*exp(1i*2*pi*f*L);
% % % % LP = ones(size(f));
% % % % t1 = ifft(fft(T(1:N)).*H1.*LP);
% % % % c1 = ifft(fft(C(1:N)).*LP);
% % % % p = ifft(fft(P(1:N)).*LP);

% Transfer function
f = ifftshift(linspace(-n/2,n/2-1,n)/(n)/dt); % +/- frequencies
f = f(:);
H1 = (1+i*2*pi*f*tau).*exp(i*2*pi*f*L);
% H1 = exp(i*2*pi*f*L); % only Lag.

% Low Pass Filter
f0 = 1/6; % Cutoff frequency
LP = 1./(1+(f/f0).^4);
% LP = ones(size(f)); % No filter.

t1(:,1:2:2*m-1) = reshape(T(1:N),n,m);
c1(:,1:2:2*m-1) = reshape(C(1:N),n,m);
p(:,1:2:2*m-1) = reshape(P(1:N),n,m);

t1(:,2:2:end) = reshape(T(1+n/2:N-n/2),n,m-1);
c1(:,2:2:end) = reshape(C(1+n/2:N-n/2),n,m-1);
p(:,2:2:end) = reshape(P(1+n/2:N-n/2),n,m-1);

At1 = fft(t1);
Ac1 = fft(c1);
Ap = fft(p);

% Corrected Fourier transforms of temperature.
At1 = At1.*((H1.*LP)*ones(1,2*m-1));

% LP filter pressure and conductivity.
Ac1 = Ac1.*(LP*ones(1,2*m-1));
Ap = Ap.*(LP*ones(1,2*m-1));

% Inverse transforms of corrected temperature and low passed conductivity and pressure.
t1 = real(ifft(At1));
c1 = real(ifft(Ac1));
p = real(ifft(Ap));

t1 = reshape(t1(n/4+1:3*n/4,:),[],1); 
p = reshape(p(n/4+1:3*n/4,:),[],1);
c1 = reshape(c1(n/4+1:3*n/4,:),[],1);

% Store corrected time series in structure for output-------------------------------%
data.P = p;
data.T = t1; 
% Corrected Salinity: C in mmho/cm.
data.S = sw_salt(c1/sw_c3515,data.T,p);
% Recalculate and replot spectra, coherence and phase----------------------%

% FFT of each column (segment)
% Data are detrended then windowed

df = 1/(n*dt);  % Frequency resolution at dof degrees of freedom

m2 = fix(length(t1)/n);
t1 = t1(1:m2*n); 
p = p(1:m2*n);
c1 = c1(1:m2*n);
At1 = fft(detrend(reshape(t1,n,m2)).*(window(@triang,n)*ones(1,m2)));              % Data are detrended then
Ac1 = fft(detrend(reshape(c1,n,m2)).*(window(@triang,n)*ones(1,m2)));  

At1 = At1(1:n/2-1,:);     % Positive frequencies only
Ac1 = Ac1(1:n/2-1,:);
f = f(1:n/2-1);         

% Spectra
Et1 = 2*mean(abs(At1).^2,2)/df/n^2;
Ec1 = 2*mean(abs(Ac1).^2,2)/df/n^2;
Ct1c1 = 2*mean(At1.*conj(Ac1)/df/n^2,2);        % Cross Spectral Estimates
Coht1c1_new = Ct1c1.*conj(Ct1c1)./(Et1.*Ec1);       % Squared Coherence Estimates
Phit1c1 = atan2(imag(Ct1c1),real(Ct1c1));       % Cross-spectral Phase Estimates

% Plots of Spectral Quantities for Corrected Data-----------------------------%

if figures

  % Coherence between Corrected Temperature and Conductivity
  figure(1);
  plot(f, Coht1c1_new, 'r-'); hold off; 
  title('Coherence'); legend('Original','Corrected');

  % Cross-Spectral Phase between Corrected Temperature and Conductivity
  figure(2)
  plot(f, Phit1c1,'r-'); hold off; 
  title('Phase'); legend('Original','Fit','Corrected');

  drawnow
end

end


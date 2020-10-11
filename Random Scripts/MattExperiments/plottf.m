%PLOTTF Plot sampled signal in time and frequency domains
%   PLOTTF(x,Ts) plots the time-domain samples in vector x, assuming 
%   that Ts is the sampling interval in seconds, and also plots the
%   Riemann-sum approximation of the Fourier transform between the 
%   frequencies of -1/(2Ts) and 1/(2Ts) Hertz.
%
%   PLOTTF(x,Ts,'t') plots only the time-domain signal.
%
%   PLOTTF(x,Ts,'f') plots only the frequency-domain signal.
%
%   In all cases, PLOTTF returns handles to the graphical objects.

% P. Schniter.  Used with permission

function hh = plottf(x,Ts,str)

plot_type = 0;
if nargin==3,
  if str=='f',
    plot_type = 1;
  elseif str=='t',
    plot_type = 2;
  end;
end;

N=length(x);                               % discrete signal length 
t=Ts*(0:N-1);                              % time vector 
if 2*floor(N/2)==N,
  f=(-N/2:N/2-1)/(Ts*N);                   % frequency vector
else
  f=(-(N-1)/2:(N-1)/2)/(Ts*N);             % frequency vector
end;
X=Ts*fft(x);                         	   % do DFT/FFT
Xs=fftshift(X);                            % shift it for plotting

if plot_type==1,
  hh = plot(f,abs(Xs));                         % plot magnitude spectrum
  xlabel('frequency [Hz]'); ylabel('magnitude');% label the axes
elseif plot_type==2,
  if isreal(x), 
    hh = plot(t,x);                             % plot the real waveform
    xlabel('time [sec]'); ylabel('amplitude');  % label the axes
  else
    hh = plot3(t,real(x),imag(x));              % plot the complex waveform
    xlabel('time [sec]'); ylabel('real'); zlabel('imag'); % label the axes
  end;
else
  subplot(2,1,1); 
  if isreal(x), 
    hh = plot(t,x);                             % plot the real waveform
    xlabel('time [sec]'); ylabel('amplitude');  % label the axes
  else
    hh = plot3(t,real(x),imag(x));              % plot the complex waveform
    xlabel('time [sec]'); ylabel('real'); zlabel('imag'); % label the axes
  end;
  subplot(2,1,2); 
  hh = [hh,plot(f,abs(Xs))];                    % plot magnitude spectrum
  xlabel('frequency [Hz]'); ylabel('magnitude') % label the axes
  subplot(2,1,1); 
end;

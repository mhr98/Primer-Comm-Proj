
% TX_RX_QPSK_Demo: This program illustrates QPSK transmission and reception,  
% providing an intuitive understanding of digital and wireless communication systems.
% Copyright (C) 2025  Mohammad Safa
% GitHub Repository: https://github.com/mhr98/Primer-Comm-Proj
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.

%% System Parameters
clear
Fs = 44100; % Sampling frequency (Hz)
Fc = 18000; % Carrier frequency (Hz)
rolloff = 0.5; % Pulse shaping roll-off factor
BandWidth = 3000; % Passband Bandwidth (Hz)
Ts = (1 + rolloff) / BandWidth; % Symbol duration (s)
L = floor(Ts * Fs); % Samples per symbol
sync_pilot_length = 100; % Pilot sequence length for synchronization
ch_est_pilot_length = 10; % Pilot length for channel estimation
Nf = 100; % Number of frames
pulse_filter = rcosine(1, L, 'sqrt', rolloff); % Pulse shaping filter
N_pulse = length(pulse_filter);
Eb = 1; % Average energy per bit

%% Load and Prepare Images
img_x = 100; img_y = 100; % Image dimensions

[pixels1, interleaving1] = process_image('myphoto1.jpg', img_x, img_y);
[pixels2, interleaving2] = process_image('myphoto2.jpg', img_x, img_y);
Ns = length(pixels1); % Number of symbols

%% Transmitter
% Generate pilot sequences
pilot = 2 * (rand(1, sync_pilot_length) > 0.5) - 1;
ch_est_pilot = 2 * (rand(1, ch_est_pilot_length) > 0.5) - 1;

% Modulate pilot for frame synchronization
impulses=[];
for n=1:sync_pilot_length
    temp= [pilot(n)  zeros(1, L-1)];
    impulses=[impulses  temp];
end
pilot_symbols=conv(impulses, pulse_filter);

% Modulate data using QPSK
impulses = [];
for n=1:Nf
    for p=1:ch_est_pilot_length
        temp= [ch_est_pilot(p)  zeros(1, L-1)];
        impulses=[impulses  temp];
    end
    
    for i= 1: Ns/Nf
        I_symb=sqrt(Eb)*(2*pixels1((n-1)*(Ns/Nf)+i)-1); %perform QPSK modulation
        Q_symb=sqrt(Eb)*(2*pixels2((n-1)*(Ns/Nf)+i)-1);
        temp= [I_symb+1i*Q_symb  zeros(1, L-1)];
        impulses=[impulses  temp]; 
    end
    
end
tx=conv(impulses, pulse_filter);

%plot pulses
plot_signal(impulses,L,Fs);

%plot pulse shaped signal
plot_signal(tx,L,Fs);

% Append pilot sequence
tx = [pilot_symbols, tx];

%Plot baseband spectrum
plot_spectrum(tx,Fs,'TX Baseband Spectrum')

% Upconvert to Carrier Frequency
t = (0:length(tx)-1) / Fs;
tx = real(tx .* sqrt(2) .* exp(1j * 2 * pi * Fc * t));

%Plot Passband spectrum
plot_spectrum(tx,Fs,'TX Passband Spectrum')

%plot passband signal
plot_signal(tx,L,Fs);

% Save as WAV file
tx = tx / max(abs(tx)); % Normalize
wavwrite(tx,Fs,'txAudio.wav')

total_time = length(tx) / Fs

%% Wireless Channel
%record the signal
% r = audiorecorder(Fs, 16, 1);
% record(r); pause(total_time+1);stop(r); 
% rx_rec=getaudiodata(r)';
% 
% %Plot Passband spectrum
% plot_spectrum(rx_rec,Fs,'Recorded RX Passband Spectrum')

%Or receive the signal perfectly
rx_rec = tx;
%% Receiver
% Downconvert the received signal
rx=rx_rec .* (sqrt(2)*exp(-1j * 2 * pi * Fc * (0:length(rx_rec)-1)/Fs));

%Plot baseband spectrum after down conversion
plot_spectrum(rx,Fs,'RX baseband Spectrum')

% Synchronization
yCorr = abs(conv(rx, pilot_symbols(end:-1:1))); % Cross-correlation
[~, x2] = max(yCorr); % Find start of frame
rx_sync = circshift(rx', -(x2 - length(pilot_symbols)))'; % Align frame

% Match filtering
rx_bb = conv(rx_sync, pulse_filter);

%Plot baseband spectrum after match filtering
plot_spectrum(rx_bb,Fs,'RX baseband Spectrum')

% Demodulate and decode data
rx_pixels_QPSK=[];
start_i=length(pilot_symbols)+N_pulse;
for n=1:Nf
    rx_temp=rx_bb(start_i+(((1:(Ns/Nf)+ch_est_pilot_length)-1)*L)); %sample the channel pilot and the data
    ch_estm_temp=rx_temp(1:ch_est_pilot_length)./ch_est_pilot; %find channel state
    ch_estm=sum(ch_estm_temp)/ch_est_pilot_length;
    pixels_temp=rx_temp(ch_est_pilot_length+1:end)/ch_estm;
    rx_pixels_QPSK=[rx_pixels_QPSK pixels_temp];
    
    start_i=start_i+((Ns/Nf)+ch_est_pilot_length)*L;
end

%Plot receiver constellation 
plot_scatter(rx_pixels_QPSK,'Receiver Concstellation')

% Decode images
rx_pixels1 = real(rx_pixels_QPSK) > 0;
rx_pixels1(interleaving1) = rx_pixels1;
rx_pixels2 = imag(rx_pixels_QPSK) > 0;
rx_pixels2(interleaving2) = rx_pixels2;

%% Reconstruct Images
figure; imshow(reshape(rx_pixels1, img_x, img_y)); title('Received Image 1');
figure; imshow(reshape(rx_pixels2, img_x, img_y)); title('Received Image 2');


















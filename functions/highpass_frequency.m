function out = highpass_frequency(I, type, D0, n)
% HIGHPASS_FREQUENCY - Highpass filter in frequency domain
% PERBAIKAN: Handle parameter yang missing dan implementasi langsung

% Default parameters jika tidak provided
if nargin < 4
    n = 2; % Default order untuk Butterworth
end
if nargin < 3
    D0 = 15; % Default cutoff frequency
end
if nargin < 2
    type = 'GHPF'; % Default type
end

% Convert to double untuk processing
I = im2double(I);
[M, N] = size(I);

% Apply FFT
F = fft2(I);
F_shift = fftshift(F);

% Create frequency grid
u = 0:(M-1);
v = 0:(N-1);
idx = find(u > M/2);
u(idx) = u(idx) - M;
idy = find(v > N/2);
v(idy) = v(idy) - N;
[V, U] = meshgrid(v, u);

% Calculate distance matrix
D = sqrt(U.^2 + V.^2);

% Create highpass filter berdasarkan type
switch type
    case 'IHPF' % Ideal Highpass Filter
        H = double(D > D0);
        
    case 'GHPF' % Gaussian Highpass Filter  
        H = 1 - exp(-(D.^2) ./ (2 * (D0^2)));
        
    case 'BHPF' % Butterworth Highpass Filter
        H = 1 ./ (1 + (D0 ./ (D + eps)).^(2*n));
        
    otherwise
        error('Filter type not supported. Use IHPF, GHPF, or BHPF');
end

% Apply filter
G_shift = F_shift .* H;

% Inverse FFT
G = ifftshift(G_shift);
out = real(ifft2(G));

% Normalize dan convert ke uint8
out = mat2gray(out); % Normalize to [0, 1]
out = im2uint8(out);

end
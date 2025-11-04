function out = highpass_frequency(I, type, D0)
% HIGH_PASS_FREQUENCY - Gaussian High-Pass Filter (domain frekuensi)
% Kompatibel grayscale & RGB
% I   : citra input
% type: 'GHPF'
% D0  : cutoff frequency

I = im2double(I);
[M,N,C] = size(I);

% Meshgrid pusat
u = 0:(M-1);
v = 0:(N-1);
u(u > M/2) = u(u > M/2) - M;
v(v > N/2) = v(v > N/2) - N;
[V,U] = meshgrid(v,u);
D = sqrt(U.^2 + V.^2);

% Buat filter frekuensi
switch upper(type)
    case 'GHPF'
        H = 1 - exp(-(D.^2) / (2*(D0^2)));
    otherwise
        error('Tipe filter tidak dikenali');
end

% Jika RGB, duplikasi H ke 3 channel
if C == 3
    H = repmat(H, [1 1 3]);
end

% Inisialisasi hasil
out = zeros(M,N,C);

for c = 1:C
    F = fft2(I(:,:,c));
    Fshift = fftshift(F);
    Gshift = H(:,:,c) .* Fshift;
    G = ifftshift(Gshift);
    out(:,:,c) = real(ifft2(G));
end

out = mat2gray(out);
end

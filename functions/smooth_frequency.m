function out = smooth_frequency(I, type, D0, n)
% type: 'ILPF','GLPF','BLPF' (ideal, gaussian, butterworth)
% D0: cutoff
% n: order for Butterworth
if nargin<4, n=2; end
if isinteger(I), I = im2double(I); end
if ndims(I)==3
    out = zeros(size(I));
    for c=1:3
        out(:,:,c) = freq_filter_channel(I(:,:,c), type, D0, n);
    end
else
    out = freq_filter_channel(I, type, D0, n);
end
end

function J = freq_filter_channel(A, type, D0, n)
[M,N] = size(A);
P = 2*M; Q = 2*N;
% pad and fft
A_pad = zeros(P,Q);
A_pad(1:M,1:N) = A;
F = fft2(A_pad);
[u,v] = meshgrid(0:Q-1, 0:P-1);
D = sqrt((u - Q/2).^2 + (v - P/2).^2);
switch upper(type)
    case 'ILPF'
        H = double(D <= D0);
    case 'GLPF'
        H = exp(-(D.^2)./(2*(D0^2)));
    case 'BLPF'
        H = 1 ./ (1 + (D./D0).^(2*n));
    otherwise
        error('Unknown type');
end
G = H .* F;
g = real(ifft2(G));
J = g(1:M,1:N);
J = uint8(255*mat2gray(J));
end

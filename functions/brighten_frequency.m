function out = brighten_frequency(I, method, D0, gammaH, gammaL)
% method 'emphasis' : high-frequency emphasis
% method 'homomorphic' : homomorphic (log-domain)
if nargin<3, D0=30; end
if nargin<4, gammaH=1.5; gammaL=1.0; end
if nargin<5, gammaL=0.5; end

if ndims(I)==3
    out = zeros(size(I));
    for c=1:3
        out(:,:,c) = brighten_frequency(I(:,:,c), method, D0, gammaH, gammaL);
    end
    out = uint8(out);
    return;
end

A = im2double(I);
[M,N] = size(A);
P=2*M; Q=2*N;
A_pad = zeros(P,Q);
A_pad(1:M,1:N)=A;
F = fft2(A_pad);
[u,v]=meshgrid(0:Q-1,0:P-1);
D = sqrt((u-Q/2).^2 + (v-P/2).^2);
Hlp = exp(- (D.^2) / (2*D0^2)); % gaussian LPF
if strcmp(method,'emphasis')
    H = gammaL + (gammaH - gammaL)*(1 - Hlp); % high-frequency emphasis
    G = H .* F;
    g = real(ifft2(G));
    out = g(1:M,1:N);
    out = im2uint8(mat2gray(out));
elseif strcmp(method,'homomorphic')
    % homomorphic: log transform, high-pass filter in freq domain
    L = log(1 + A);
    L_pad = zeros(P,Q); L_pad(1:M,1:N) = L;
    F2 = fft2(L_pad);
    Hhomo = 1 - Hlp;
    Gh = Hhomo .* F2;
    lres = real(ifft2(Gh));
    res = exp(lres(1:M,1:N)) - 1;
    out = im2uint8(mat2gray(res));
else
    error('Unknown method');
end
end

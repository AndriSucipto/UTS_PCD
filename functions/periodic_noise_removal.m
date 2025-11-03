function out = periodic_noise_removal(I)
% Estimate periodic noise peaks and apply notch filters
if ndims(I)==3, Igray = rgb2gray(I); else Igray = I; end
Igray = im2double(Igray);
F = fftshift(fft2(Igray));
M = log(1+abs(F));
% find peaks (manual parameter tuning might be required)
bw = imregionalmax(M);
% remove center
bw(round(end/2), round(end/2)) = 0;
% coordinates of peaks
[y,x] = find(bw);
H = ones(size(F));
D0 = 10; % notch radius
for k=1:length(x)
    [X,Y] = meshgrid(1:size(F,2), 1:size(F,1));
    D = sqrt((X - x(k)).^2 + (Y - y(k)).^2);
    H(D <= D0) = 0; % ideal notch
end
G = H .* F;
g = real(ifft2(ifftshift(G)));
out = im2uint8(mat2gray(g));
end

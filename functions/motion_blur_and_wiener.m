function out = motion_blur_and_wiener(I, len, theta, noise_var)
% MOTION_BLUR_AND_WIENER - Simulasi blur gerak dan restorasi Wiener
% Kompatibel grayscale & RGB
% I         : input image
% len       : panjang motion blur
% theta     : arah blur (derajat)
% noise_var : variansi noise (misal 0.01)

I = im2double(I);
[M,N,C] = size(I);

PSF = fspecial('motion', len, theta);
out = zeros(M,N,C);

for c = 1:C
    blurred = imfilter(I(:,:,c), PSF, 'conv', 'circular');
    out(:,:,c) = deconvwnr(blurred, PSF, noise_var);
end

out = mat2gray(out);
end

function out = custom_conv(I, kernel, pad_mode)
% CUSTOM_CONV  Convolusi 2D dengan normalisasi yang benar
% PERBAIKAN: Normalisasi kernel dan handling intensitas

if nargin < 3, pad_mode = 'replicate'; end

% NORMALISASI KERNEL - INI YANG PALING PENTING!
kernel = double(kernel);
kernel_sum = sum(kernel(:));
if abs(kernel_sum) > 1e-6
    kernel = kernel / kernel_sum; % Normalisasi untuk menjaga intensitas
end

kernel = rot90(kernel,2); % flip for convolution
pad = floor(size(kernel,1)/2);

% Handle gambar color/grayscale
if ndims(I) == 2
    out = conv_single_channel(double(I), kernel, pad, pad_mode);
else
    out = zeros(size(I));
    for c=1:size(I,3)
        out(:,:,c) = conv_single_channel(double(I(:,:,c)), kernel, pad, pad_mode);
    end
end

% Normalisasi output ke range 0-255
out = uint8(out);

end

function C = conv_single_channel(A, kernel, pad, pad_mode)
A = double(A);
A_pad = padarray_custom(A, pad, pad_mode);
[M,N] = size(A);
C = zeros(M,N);
k = size(kernel,1);

for i=1:M
    for j=1:N
        region = A_pad(i:i+k-1, j:j+k-1);
        C(i,j) = sum(region .* kernel, 'all');
    end
end
end

function B = padarray_custom(A, pad, mode)
switch mode
    case 'zero'
        B = zeros(size(A)+2*pad);
        B(1+pad:end-pad,1+pad:end-pad) = A;
    case 'replicate'
        B = padarray(A, [pad pad], 'replicate');
    case 'symmetric'
        B = padarray(A, [pad pad], 'symmetric');
    otherwise
        B = padarray(A, [pad pad], 'replicate');
end
end
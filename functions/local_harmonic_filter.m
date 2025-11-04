function out = local_harmonic_filter(I, w)
% LOCAL_HARMONIC_FILTER - Filter rata-rata harmonik lokal
% Mengurangi noise aditif pada citra grayscale / RGB
% 
% Input:
%   I - citra input (grayscale atau RGB)
%   w - ukuran jendela (mis. 3)
% Output:
%   out - hasil filtering
%
% Rumus: H = n / sum(1/x_i), dengan n = jumlah piksel dalam jendela

I = im2double(I);
[M,N,C] = size(I);
pad = floor(w/2);
out = zeros(M,N,C);

for c = 1:C
    channel = I(:,:,c);
    padded = padarray(channel, [pad pad], 'replicate');
    harmonic = zeros(M,N);

    for i = 1:M
        for j = 1:N
            window = padded(i:i+w-1, j:j+w-1);
            harmonic(i,j) = (w*w) / sum(1 ./ (window(:) + eps)); 
        end
    end

    out(:,:,c) = harmonic;
end

out = mat2gray(out);
end

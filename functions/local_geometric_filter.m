function out = local_geometric_filter(I, w)
% LOCAL_GEOMETRIC_FILTER - Rata-rata geometrik untuk mengurangi noise
% Kompatibel grayscale & RGB
% I : citra input
% w : ukuran jendela (mis. 3)

I = im2double(I);
[M,N,C] = size(I);
pad = floor(w/2);
out = zeros(M,N,C);

for c = 1:C
    channel = I(:,:,c);
    padded = padarray(channel,[pad pad],'replicate');
    geom = zeros(M,N);
    for i = 1:M
        for j = 1:N
            window = padded(i:i+w-1, j:j+w-1);
            geom(i,j) = exp(mean(log(window(:) + eps)));
        end
    end
    out(:,:,c) = geom;
end

out = mat2gray(out);
end

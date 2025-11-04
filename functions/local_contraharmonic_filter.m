function out = local_contraharmonic_filter(I, w, Q)
% LOCAL_CONTRAHARMONIC_FILTER - Filter kontraharmonik lokal
% Mengurangi noise salt/pepper tergantung nilai Q
%
%   Q > 0  → mengurangi pepper noise
%   Q < 0  → mengurangi salt noise

I = im2double(I);
[M,N,C] = size(I);
pad = floor(w/2);
out = zeros(M,N,C);

for c = 1:C
    channel = I(:,:,c);
    padded = padarray(channel, [pad pad], 'replicate');
    result = zeros(M,N);

    for i = 1:M
        for j = 1:N
            window = padded(i:i+w-1, j:j+w-1);
            num = sum(window(:).^(Q + 1));
            den = sum(window(:).^Q) + eps;
            result(i,j) = num / den;
        end
    end

    out(:,:,c) = result;
end

out = mat2gray(out);
end

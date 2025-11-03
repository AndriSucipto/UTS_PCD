function out = local_mean_filter(I, w)
% LOCAL_MEAN_FILTER  Filter rata-rata lokal (mean filter)
%   out = local_mean_filter(I, w)
if nargin < 2, w = 3; end
I = im2double(I);

if size(I,3) == 3
    out = zeros(size(I));
    kernel = ones(w) / (w^2);
    for c = 1:3
        out(:,:,c) = imfilter(I(:,:,c), kernel, 'replicate');
    end
else
    kernel = ones(w) / (w^2);
    out = imfilter(I, kernel, 'replicate');
end

out = im2uint8(mat2gray(out));
end

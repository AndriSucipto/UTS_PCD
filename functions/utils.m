function G = makeGaussian(n, sigma)
% MAKEGAUSSIAN - generate n x n gaussian kernel
if nargin<2, sigma = 0.3*((n-1)*0.5 - 1) + 0.8; end
h = fspecial('gaussian', n, sigma); % allowed helper for kernel only
G = h / sum(h(:));
end

function img_gray = img2gray(I)
if ndims(I) == 3
    img_gray = rgb2gray(I);
else
    img_gray = I;
end
end

function saveHighRes(figHandle, filename, dpi)
if nargin<3, dpi = 300; end
exportgraphics(figHandle, filename, 'Resolution', dpi);
end

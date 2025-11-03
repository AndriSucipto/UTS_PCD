function out = smooth_spatial(I, method, n)
% method: 'mean' or 'gaussian'
if nargin<3, n=3; end
if strcmp(method,'mean')
    kernel = ones(n)/ (n*n);
elseif strcmp(method,'gaussian')
    kernel = makeGaussian(n);
else
    error('Unknown method');
end
out = custom_conv(I, kernel, 'replicate');
end

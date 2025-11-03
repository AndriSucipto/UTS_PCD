function G = makeGaussian(n, sigma)
% makeGaussian Membuat kernel Gaussian n x n
%   G = makeGaussian(n, sigma)
%   n      : ukuran kernel (harus ganjil, misal 3,5,7)
%   sigma  : standar deviasi Gaussian
%
%   Output G : kernel Gaussian ter-normalisasi (jumlah elemen = 1)

if nargin < 2
    sigma = 0.3*((n-1)*0.5 - 1) + 0.8; % rumus default sigma
end

% Buat koordinat grid
[x, y] = meshgrid(-(n-1)/2:(n-1)/2, -(n-1)/2:(n-1)/2);

% Rumus Gaussian 2D
G = exp(-(x.^2 + y.^2) / (2*sigma^2));

% Normalisasi agar totalnya 1
G = G / sum(G(:));
end

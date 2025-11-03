function results = add_noise_and_denoise(I, noiseType, params)
% I: input image (grayscale or rgb)
% noiseType: 'saltpepper' or 'gaussian'
% returns struct with denoised variants
if nargin<3, params.prob=0.05; end
if strcmp(noiseType,'saltpepper')
    noisy = imnoise(I,'salt & pepper', params.prob);
else
    noisy = imnoise(I,'gaussian', params.var);
end

% create filters (we will implement all manually)
results.noisy = noisy;
window = params.w; if isempty(window), window = 3; end

% min filter
results.min = local_order_filter(noisy, window, 'min');
% max filter
results.max = local_order_filter(noisy, window, 'max');
% median filter (manual)
results.median = local_order_filter(noisy, window, 'median');
% arithmetic mean
results.arith = local_mean_filter(noisy, window);
% geometric mean
results.geom = local_geometric_filter(noisy, window);
% harmonic mean
results.harm = local_harmonic_filter(noisy, window);
% contraharmonic (Q param)
Q = getfield(params,'Q',0.5);
results.contra = local_contraharmonic_filter(noisy, window, Q);
% midpoint
results.mid = local_midpoint_filter(noisy, window);
% alpha-trimmed (d)
d = getfield(params,'d',2);
results.alpha = local_alpha_trimmed(noisy, window, d);

% helper functions should be implemented below or in utils
end

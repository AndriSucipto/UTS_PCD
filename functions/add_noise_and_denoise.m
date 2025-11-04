function R = add_noise_and_denoise(I, noise_type, params)
% ADD_NOISE_AND_DENOISE - Tambahkan noise dan lakukan beberapa filter denoise
% Kompatibel grayscale & RGB
%
% Input:
%   I           : citra input (grayscale/RGB)
%   noise_type  : 'saltpepper' | 'gaussian' | 'none'
%   params.prob : probabilitas noise (untuk salt & pepper)
%   params.w    : ukuran jendela (mis. 3)
%   params.Q    : parameter contraharmonic
%
% Output:
%   R : struktur berisi hasil dari berbagai filter
%       R.mean, R.median, R.geometric, R.harmonic, R.contraharmonic

% -------------------------------------------------------------
% Pastikan semua parameter ada
if ~isfield(params, 'prob'); params.prob = 0.05; end
if ~isfield(params, 'w');    params.w = 3;       end
if ~isfield(params, 'Q');    params.Q = 1.5;     end

I = im2double(I);
[M,N,C] = size(I);

% --- 1. Tambahkan noise (jika diminta) ---
switch lower(noise_type)
    case 'saltpepper'
        noisy = imnoise(I,'salt & pepper',params.prob);
    case 'gaussian'
        noisy = imnoise(I,'gaussian',0,0.01);
    otherwise
        noisy = I;
end

% Inisialisasi hasil
R = struct();

% --- 2. Mean filter (average) ---
try
    h = fspecial('average', params.w);
    mean_filtered = zeros(M,N,C);
    for c = 1:C
        mean_filtered(:,:,c) = imfilter(noisy(:,:,c), h, 'replicate');
    end
    R.mean = mat2gray(mean_filtered);
catch
    R.mean = noisy;
end

% --- 3. Median filter ---
try
    median_filtered = zeros(M,N,C);
    for c = 1:C
        median_filtered(:,:,c) = medfilt2(noisy(:,:,c), [params.w params.w]);
    end
    R.median = mat2gray(median_filtered);
catch
    R.median = noisy;
end

% --- 4. Geometric mean filter ---
try
    R.geometric = local_geometric_filter(noisy, params.w);
catch
    R.geometric = noisy;
end

% --- 5. Harmonic mean filter ---
try
    R.harmonic = local_harmonic_filter(noisy, params.w);
catch
    R.harmonic = noisy;
end

% --- 6. Contraharmonic mean filter ---
try
    R.contraharmonic = local_contraharmonic_filter(noisy, params.w, params.Q);
catch
    R.contraharmonic = noisy;
end

end

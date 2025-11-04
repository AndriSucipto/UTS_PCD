% ============================================================
% RUN_ALL_EXAMPLES.M
% Batch testing script untuk semua fungsi perbaikan citra UTS PCD
% MATLAB R2025b compatible
% ============================================================

clc; clear; close all;
addpath('functions');

inputDir = 'test_images';
outputDir = 'report/hasil_otomatis';
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Cari semua gambar JPG dan PNG
imgFiles = [dir(fullfile(inputDir, '*.jpg')); dir(fullfile(inputDir, '*.png'))];
if isempty(imgFiles)
    disp('⚠️  Tidak ada file JPG/PNG di folder test_images!');
    return;
end

for i = 1:numel(imgFiles)
    fname = imgFiles(i).name;
    disp('--------------------------------------------');
    disp(['🔹 Memproses: ', fname]);
    I = imread(fullfile(inputDir, fname));

    % --- Pastikan image dalam format double ---
    I = im2double(I);

    % === 1. Custom Convolution ===
    try
        k = [0 -1 0; -1 5 -1; 0 -1 0];
        out1 = custom_conv(I, k, 'replicate');
        imwrite(out1, fullfile(outputDir, ['conv_' fname]));
    catch ME
        disp(['❌ Custom Conv error: ' ME.message]);
    end

    % === 2. Smoothing ===
    try
        out2 = smooth_spatial(I, 'gaussian', 3);
        imwrite(out2, fullfile(outputDir, ['smooth_' fname]));
    catch ME
        disp(['❌ Smoothing error: ' ME.message]);
    end

    % === 3. Highpass (Frequency) ===
    try
        out3 = highpass_frequency(I, 'GHPF', 50);
        imwrite(out3, fullfile(outputDir, ['highpass_' fname]));
    catch ME
        disp(['❌ Highpass error: ' ME.message]);
    end

    % === 4. Brighten (Homomorphic) ===
    try
        out4 = brighten_frequency(I, 'homomorphic', 40, 1.6, 0.8);
        imwrite(out4, fullfile(outputDir, ['bright_' fname]));
    catch ME
        disp(['❌ Brighten error: ' ME.message]);
    end

    % === 5. Denoise Filters ===
    try
        % Tambahkan parameter lengkap agar semua filter punya input
        params.prob = 0.05; 
        params.w = 3; 
        params.Q = 1.5;  % default untuk contraharmonic filter
        
        R = add_noise_and_denoise(I, 'saltpepper', params);
        
        % Simpan semua hasil jika tersedia
        if isfield(R, 'median')
            imwrite(R.median, fullfile(outputDir, ['denoise_median_' fname]));
        end
        if isfield(R, 'geometric')
            imwrite(R.geometric, fullfile(outputDir, ['denoise_geo_' fname]));
        end
        if isfield(R, 'harmonic')
            imwrite(R.harmonic, fullfile(outputDir, ['denoise_harm_' fname]));
        end
        if isfield(R, 'contraharmonic')
            imwrite(R.contraharmonic, fullfile(outputDir, ['denoise_contra_' fname]));
        end
    catch ME
        disp(['❌ Denoise error: ' ME.message]);
    end

    % === 6. Periodic Noise Removal ===
    try
        out6 = periodic_noise_removal(I);
        imwrite(out6, fullfile(outputDir, ['periodic_' fname]));
    catch ME
        disp(['❌ Periodic noise error: ' ME.message]);
    end

    % === 7. Motion Blur + Wiener ===
    try
        out7 = motion_blur_and_wiener(I, 15, 30, 0.01);
        imwrite(out7, fullfile(outputDir, ['motion_' fname]));
    catch ME
        disp(['❌ Motion blur error: ' ME.message]);
    end

    disp(['✅ Selesai: ', fname]);
end

disp('=======================================');
disp('✅ Semua gambar selesai diproses.');
disp(['📁 Hasil tersimpan di: ', fullfile(outputDir)]);

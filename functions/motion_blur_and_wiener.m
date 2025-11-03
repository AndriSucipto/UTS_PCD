function result = motion_blur_and_wiener(I, len, theta, K)
% IMPROVED VERSION - Better image restoration

% Default parameters
if nargin < 4, K = 0.001; end      % Adjusted noise-to-signal ratio
if nargin < 3, theta = 30; end
if nargin < 2, len = 8; end        % Shorter blur length for better restoration

% Convert to grayscale for processing if needed, but preserve color
is_color = false;
if ndims(I) == 3 && size(I, 3) == 3
    is_color = true;
    % Process each color channel separately for better color preservation
    R = I(:,:,1);
    G = I(:,:,2);
    B = I(:,:,3);
else
    % Already grayscale
    I_gray = I;
end

% Create PSF (Point Spread Function) for motion blur
PSF = fspecial('motion', len, theta);

if is_color
    % Process each color channel separately
    R_restored = restore_channel(R, PSF, K);
    G_restored = restore_channel(G, PSF, K);
    B_restored = restore_channel(B, PSF, K);
    
    % Combine channels
    result = cat(3, R_restored, G_restored, B_restored);
else
    % Process grayscale image
    result = restore_channel(I_gray, PSF, K);
end

% Final enhancement
result = final_enhancement(result);

end

function restored_channel = restore_channel(channel, PSF, K)
% Restore a single channel using Wiener deconvolution
    
    % Convert to double for processing
    channel_double = im2double(channel);
    
    % Apply edgetaper to reduce boundary artifacts
    channel_edgetaper = edgetaper(channel_double, PSF);
    
    % Wiener deconvolution
    restored = deconvwnr(channel_edgetaper, PSF, K);
    
    % Normalize to [0, 1] range
    restored = mat2gray(restored);
    
    % Convert back to uint8
    restored_channel = im2uint8(restored);
end

function enhanced = final_enhancement(img)
% Apply final enhancement to improve visual quality
    
    % Mild sharpening with better parameters
    sharpened = imsharpen(img, 'Amount', 0.8, 'Radius', 1.0, 'Threshold', 0.1);
    
    % Contrast enhancement using adaptive histogram equalization
    if ndims(img) == 3
        % Color image - convert to LAB space and enhance luminance
        lab = rgb2lab(sharpened);
        L = lab(:,:,1);
        L_enhanced = adapthisteq(L/100) * 100; % Normalize and scale back
        lab(:,:,1) = L_enhanced;
        enhanced = lab2rgb(lab, 'OutputType', 'uint8');
    else
        % Grayscale image
        enhanced = adapthisteq(sharpened);
    end
    
    % Mild noise reduction to clean up artifacts
    enhanced = medfilt2(enhanced, [2 2]);
end
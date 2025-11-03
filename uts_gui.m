function uts_gui
% ============================================================
% UTS PCD - VERSION FIXED dengan parameter optimal
% ============================================================

addpath('functions');

% ====== FIGURE & LAYOUT ======
fig = uifigure('Name','UTS PCD - Image Enhancement Tool',...
    'Position',[100 100 1000 600],...
    'Color',[0.95 0.95 0.95]);

gl = uigridlayout(fig,[6 4]);
gl.RowHeight = {'fit','fit','1x','fit','fit','fit'};
gl.ColumnWidth = {'1x','1x','1x','1x'};

% ====== TITLE LABEL ======
lblTitle = uilabel(gl);
lblTitle.Text = 'UTS Pengolahan Citra Digital';
lblTitle.FontSize = 18;
lblTitle.FontWeight = 'bold';
lblTitle.Layout.Row = 1;
lblTitle.Layout.Column = [1 4];

% ====== AXES ======
ax1 = uiaxes(gl);
title(ax1,'Original Image');
ax1.Layout.Row = 3;
ax1.Layout.Column = [1 2];

ax2 = uiaxes(gl);
title(ax2,'Processed Image');
ax2.Layout.Row = 3;
ax2.Layout.Column = [3 4];

% ====== DROPDOWN ======
lblMethod = uilabel(gl);
lblMethod.Text = 'Pilih Operasi:';
lblMethod.FontWeight = 'bold';
lblMethod.Layout.Row = 2;
lblMethod.Layout.Column = 1;

methodList = {
    '1 - Custom Convolution (Sharpening Ringan)'
    '2 - Smoothing (Gaussian Ringan)'
    '3 - Highpass Filter (Freq - Radius Kecil)'
    '4 - Brighten (Homomorphic - Parameter Aman)'
    '5 - Denoise (Median Filter)'
    '6 - Periodic Noise Removal'
    '7 - Motion Blur + Wiener (Parameter Aman)'
    };
ddMethod = uidropdown(gl);
ddMethod.Items = methodList;
ddMethod.Value = methodList{1};
ddMethod.Layout.Row = 2;
ddMethod.Layout.Column = [2 4];

% ====== BUTTONS ======
btnLoad = uibutton(gl);
btnLoad.Text = '📂 Load Image';
btnLoad.FontWeight = 'bold';
btnLoad.Layout.Row = 4;
btnLoad.Layout.Column = 1;
btnLoad.ButtonPushedFcn = @loadImage;

btnProcess = uibutton(gl);
btnProcess.Text = '⚙️ Proses';
btnProcess.FontWeight = 'bold';
btnProcess.Layout.Row = 4;
btnProcess.Layout.Column = 2;
btnProcess.ButtonPushedFcn = @processImage;

btnReset = uibutton(gl);
btnReset.Text = '🔄 Reset';
btnReset.FontWeight = 'bold';
btnReset.Layout.Row = 4;
btnReset.Layout.Column = 3;
btnReset.ButtonPushedFcn = @resetImage;

btnSave = uibutton(gl);
btnSave.Text = '💾 Save As...';
btnSave.FontWeight = 'bold';
btnSave.Layout.Row = 4;
btnSave.Layout.Column = 4;
btnSave.ButtonPushedFcn = @saveImage;

% ====== STATUS LABEL ======
lblStatus = uilabel(gl);
lblStatus.Text = 'Status: Menunggu gambar diunggah...';
lblStatus.FontWeight = 'bold';
lblStatus.FontColor = [0 0.3 0.7];
lblStatus.Layout.Row = 5;
lblStatus.Layout.Column = [1 4];

% ====== VARIABEL PENYIMPAN GAMBAR ======
imgOriginal = [];
imgProcessed = [];

% ============================================================
% ================  CALLBACK FUNCTIONS  =======================
% ============================================================

    function loadImage(~,~)
        [file,path] = uigetfile({'*.jpg;*.png;*.tif;*.bmp','All Image Files'},'Pilih Citra');
        if isequal(file,0)
            lblStatus.Text = 'Status: Upload dibatalkan.';
            return;
        end
        imgOriginal = imread(fullfile(path,file));
        imgProcessed = imgOriginal;
        imshow(imgOriginal,'Parent',ax1);
        cla(ax2);
        title(ax1,'Original Image');
        title(ax2,'Processed Image');
        lblStatus.Text = sprintf('Status: Gambar "%s" dimuat.', file);
    end
    
       function processImage(~,~)
        if isempty(imgOriginal)
            uialert(fig,'Silakan upload gambar terlebih dahulu!','Tidak ada gambar');
            return;
        end
        method = ddMethod.Value;
        I = imgOriginal;
        
        try
            % Konversi ke grayscale untuk method frequency domain
            if size(I, 3) == 3
                I_gray = rgb2gray(I);
            else
                I_gray = I;
            end
            
            switch method
                case '1 - Custom Convolution (Sharpening Ringan)'
                    % PARAMETER LEBIH EFFECTIVE - masih aman tapi terlihat efeknya
                    k = [0 -0.5 0; -0.5 3.0 -0.5; 0 -0.5 0];  % ↑ dari 2.0 ke 3.0
                    imgProcessed = custom_conv(I, k, 'replicate');
                    lblStatus.Text = 'Status: Sharpening applied - efek medium';
    
                case '2 - Smoothing (Gaussian Ringan)'
                    % GAUSSIAN LEBIH EFFECTIVE
                    if exist('imgaussfilt', 'file')
                        imgProcessed = imgaussfilt(I, 1.2);  % ↑ dari 0.8 ke 1.2
                    else
                        k = fspecial('gaussian', [5 5], 1.2);
                        imgProcessed = custom_conv(I, k, 'replicate');
                    end
                    lblStatus.Text = 'Status: Gaussian smoothing - efek terlihat';
    
                case '3 - Highpass Filter (Freq - Radius Kecil)'
                    % HIGHPASS LEBIH EFFECTIVE
                    imgProcessed = highpass_frequency(I_gray, 'GHPF', 30, 2);  % ↑ dari 15 ke 30
                    lblStatus.Text = 'Status: Highpass filter - edges enhanced';
    
                case '4 - Brighten (Homomorphic - Parameter Aman)'
                    % HOMOMORPHIC LEBIH EFFECTIVE
                    imgProcessed = brighten_frequency(I_gray, 'homomorphic', 25, 1.5, 0.4);  
                    % gammaH=1.5 (↑ dari 1.2), gammaL=0.4 (↓ dari 0.6)
                    lblStatus.Text = 'Status: Homomorphic filtering - contrast improved';
    
                case '5 - Denoise (Median Filter)'
                    % MEDIAN FILTER - tetap sama (sudah bagus)
                    if size(I,3)==3
                        imgProcessed = I;
                        for c=1:3
                            imgProcessed(:,:,c) = medfilt2(I(:,:,c), [3 3]);
                        end
                    else
                        imgProcessed = medfilt2(I, [3 3]);
                    end
                    lblStatus.Text = 'Status: Median filter - noise reduced';
    
                case '6 - Periodic Noise Removal'
                    imgProcessed = periodic_noise_removal(I_gray);
                    lblStatus.Text = 'Status: Periodic noise removal applied';
    
                case '7 - Motion Blur + Wiener (Parameter Aman)'
                    imgProcessed = motion_blur_and_wiener(I_gray, 12, 30, 0.001);  
                    % length=12 (↑ dari 8)
                    lblStatus.Text = 'Status: Motion deblurring applied';
            end
    
            % Normalisasi hasil
            if isinteger(imgProcessed)
                % Jika sudah uint8, biarkan saja
            else
                imgProcessed = im2uint8(mat2gray(imgProcessed));
            end
            
            imshow(imgProcessed, 'Parent', ax2);
            lblStatus.Text = sprintf('Status: "%s" - EFEK DIPERKUAT', method);
    
        catch ME
            lblStatus.Text = sprintf('Error: %s', ME.message);
            uialert(fig, ME.message, 'Terjadi Error');
        end
    end
    function resetImage(~,~)
        if isempty(imgOriginal)
            return;
        end
        imgProcessed = imgOriginal;
        imshow(imgOriginal,'Parent',ax1);
        cla(ax2);
        lblStatus.Text = 'Status: Citra telah direset.';
    end

    function saveImage(~,~)
    if isempty(imgProcessed)
        uialert(fig,'Tidak ada gambar yang bisa disimpan!','Error');
        return;
    end
    
    % Format yang umum digunakan
    formats = {
        '*.jpg', 'JPEG (*.jpg)';
        '*.png', 'PNG (*.png)'; 
        '*.tif', 'TIFF (*.tif)';
        '*.bmp', 'Bitmap (*.bmp)';
        '*.gif', 'GIF (*.gif)';
        '*.*', 'Semua File (*.*)'
    };
    
    [file, path] = uiputfile(formats, 'Simpan hasil sebagai');
    
    if isequal(file, 0)
        lblStatus.Text = 'Status: Penyimpanan dibatalkan.';
        return;
    end
    
    try
        % Simpan dengan kualitas optimal untuk JPEG
        if endsWith(lower(file), {'.jpg', '.jpeg'})
            imwrite(imgProcessed, fullfile(path, file), 'Quality', 95);
        else
            imwrite(imgProcessed, fullfile(path, file));
        end
        
        lblStatus.Text = sprintf('Status: Hasil disimpan sebagai %s', file);
        
    catch ME
        lblStatus.Text = sprintf('Error: %s', ME.message);
        uialert(fig, ME.message, 'Error Penyimpanan');
    end
end

end
function medical_image_enhancement_app
    % Create GUI Window
    fig = uifigure('Name','Medical Image Enhancement','Position',[100 100 1400 500]);

    % Global variables
    img = [];
    final_img = [];

    % Upload button
    uibutton(fig,'push',...
        'Text','Upload Image',...
        'Position',[50 450 120 30],...
        'ButtonPushedFcn',@(btn,event) uploadImage());

    % Download button
    uibutton(fig,'push',...
        'Text','Download Enhanced Image',...
        'Position',[200 450 180 30],...
        'ButtonPushedFcn',@(btn,event) downloadImage());

    % Side-by-Side Comparison button
    uibutton(fig,'push',...
        'Text','Side-by-Side Comparison',...
        'Position',[420 450 200 30],...
        'ButtonPushedFcn',@(btn,event) showComparison());

    % Axes for each stage (single row layout)
    ax1 = uiaxes(fig,'Position',[50 120 240 240]);     title(ax1,'Original');
    ax2 = uiaxes(fig,'Position',[320 120 240 240]);    title(ax2,'Denoised');
    ax3 = uiaxes(fig,'Position',[590 120 240 240]);    title(ax3,'Histogram Equalized');
    ax4 = uiaxes(fig,'Position',[860 120 240 240]);    title(ax4,'CLAHE');
    ax5 = uiaxes(fig,'Position',[1130 120 240 240]);   title(ax5,'Sharpened (Final)');

    % ---------------- Functions ---------------- %
    function uploadImage()
        [file,path] = uigetfile({'*.jpg;*.png;*.jpeg','Image Files'});
        if isequal(file,0)
            return;
        end
        img = imread(fullfile(path,file));
        if size(img,3) == 3
            img = rgb2gray(img);
        end
        imshow(img,'Parent',ax1);

        % Step 1: Denoising
        denoised = medfilt2(img,[3 3]);
        imshow(denoised,'Parent',ax2);

        % Step 2: Histogram Equalization
        hist_img = histeq(denoised);
        imshow(hist_img,'Parent',ax3);

        % Step 3: CLAHE
        clahe_img = adapthisteq(hist_img,'ClipLimit',0.02,'NumTiles',[8 8]);
        imshow(clahe_img,'Parent',ax4);

        % Step 4: Sharpening
        final_img = imsharpen(clahe_img,'Radius',2,'Amount',1);
        imshow(final_img,'Parent',ax5);
    end

    function downloadImage()
        if isempty(final_img)
            uialert(fig,'Please upload and process an image first.','No Image Found');
            return;
        end
        [file,path] = uiputfile('enhanced_image.png','Save Enhanced Image As');
        if isequal(file,0)
            return;
        end
        imwrite(final_img, fullfile(path,file));
        uialert(fig,'Enhanced image saved successfully!','Download Complete');
    end

    % Side-by-Side Comparison Window
    function showComparison()
        if isempty(img) || isempty(final_img)
            uialert(fig,'Please upload and process an image first.','No Images Available');
            return;
        end
        % Create a new figure window
        compFig = uifigure('Name','Side-by-Side Comparison','Position',[200 180 900 400]);

        % Original Image
        ax_orig = uiaxes(compFig,'Position',[40 30 450 350]);
        title(ax_orig,'Original Image');
        imshow(img,'Parent',ax_orig);

        % Enhanced Image
        ax_final = uiaxes(compFig,'Position',[500 30 450 350]);
        title(ax_final,'Enhanced Image');
        imshow(final_img,'Parent',ax_final);
    end
end

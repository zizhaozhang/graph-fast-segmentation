%% function [f_maps] = getFeatures(im_rgb,scale,which_feature,opts)
% 
% INPUTS
%  im_rgb        - NxMx3 query image; C can be 1 (grayscale) or 3 (rgb color)
%  scale         - how many times should the image be downsampled?
%  which_feature - which feature types to compute? can contain multiple entries
%  opts          - parameter settings (see setEnvironment)
%
% OUTPUTS
%  f_maps        - NxMxF array of F feature maps input im_rgb
% 
% -------------------------------------------------------------------------
% Crisp Boundaries Toolbox
% Phillip Isola, 2014 [phillpi@mit.edu]
% Please email me if you find bugs, or have suggestions or questions
% -------------------------------------------------------------------------

function [f_maps] = getFeatures(im_rgb,scale,which_feature,opts)
    
    im = [];
    
    %%
    if (strcmp(which_feature,'luminance'))
        im = mat2gray(mean(im_rgb,3));
    elseif (strcmp(which_feature,'r'))
        im = mat2gray(im_rgb(:,:,1));
    
    elseif strcmp(which_feature,'rgb')
        im = mat2gray(im_rgb);
    
    elseif strcmp(which_feature,'mixed') % rgb lab hsv
        im = cat(3, im, im_rgb);
        colorTransform = makecform('srgb2lab');
        cf = mat2gray(applycform(im_rgb,colorTransform));
        im = cat(3,im,cf(:,:,1:3));
        cf2 = mat2gray(rgb2hsv(im_rgb)); 
        im = cat(3,im,cf2(:,:,1:3));
   
    elseif strcmp(which_feature,'highorder')
        im = cat(3, im, im_rgb); % rgb
        colorTransform = makecform('srgb2lab');
        cf = mat2gray(applycform(im_rgb,colorTransform));
        im = cat(3,im,cf(:,:,1:3)); % lab
        cf2 = mat2gray(rgb2hsv(im_rgb)); 
        im = cat(3,im,cf2(:,:,1:2)); % hs
        
        
        % no need gradient rgb
%         [GX, GY] = gradient(im_rgb(:,:,1));
%         GR = abs(GX) + abs(GY);
%         [GX, GY] = gradient(im_rgb(:,:,2));
%         GG = abs(GX) + abs(GY);
%         [GX, GY] = gradient(im_rgb(:,:,3));
%         GB = abs(GX) + abs(GY);
%         im = cat(3, im, GR, GG, GB);
        
        % nolinear concat
        im = cat(3, im.^0.5, im.^1.5, im.^2.0);
   
    elseif (strcmp(which_feature,'color'))
        %% color features
        if (size(im_rgb,3)==3)
            colorTransform = makecform('srgb2lab');
            cf = mat2gray(applycform(im_rgb,colorTransform));
            im = cat(3,im,cf(:,:,1:3));
        elseif (size(im_rgb,3)==1) % grayscale image
            im = im_rgb;
        else
            error('unhandled image format');
        end
    
    elseif (strcmp(which_feature,'var'))
        
        %% variance features
        f = pcaIm(im_rgb);
        
        Nhood_rad = 2^(scale-1);
        se = strel('disk',Nhood_rad,0);
        vf = mat2gray(sqrt(stdfilt(f,getnhood(se))));
        
        im = cat(3,im,vf);
    
    elseif (strcmp(which_feature,'x'))

        %% x position feature
        xx = repmat((1:size(im_rgb,2)),[size(im_rgb,1),1]);
        xx = mat2gray(xx);
        im = cat(3,im,xx);
   
    elseif (strcmp(which_feature,'y'))

        %% y position feature
        yy = repmat((1:size(im_rgb,1))',[1 size(im_rgb,2)]);
        yy = mat2gray(yy);
        im = cat(3,im,yy);
    end
    
    %% downsample
    im = imresize(im,2^(-(scale-1)));
    
    %%
    if (opts.features.decorrelate)
        im = mat2gray(pcaIm(im));
    end
    
    f_maps = im;
end
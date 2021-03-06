clc;
disp('=========SL_ZED_WITH_MATLAB -- Basic=========');
close all;
clear mex; clear functions; clear all;

% SVO playback
% path = '../MySVO.svo';
% mexZED('create', path)

% Live mode
mexZED('create', 720, 60);

% parameter struct, the same as sl::zed::InitParams
% values as enum number, defines in : include/zed/utils/GlobalDefine.hpp
% 1: true, 0: false for boolean
param.unit = 1; % in this sample we use METER
param.mode = 2;
result = mexZED('init', param)

if(strcmp(result,'SUCCESS'))
    
    size = mexZED('getImageSize')
    
    % Set Confidence Threshold
    mexZED('setConfidenceThreshold', 98);
    
    % Define maximum depth (in METER)
    maxDepth = 10;
    binranges = 0:0.1:maxDepth ;
    mexZED('setDepthClampValue',maxDepth);
    
    % Get number of frames (if SVO)
    nbFrame = mexZED('getSVONumberOfFrames')
    
    % Get cameras parameters
    params = mexZED('getCameraParameters')
    
    % Create Figure and wait for keyboard interruption to quit
    f = figure('name','ZED SDK : Images and Depth','NumberTitle','off','keypressfcn','close');
    ok = 1;
    % loop over frames
    while ok
        
        % grab the current image and compute the depth
        mexZED('grab', 'STANDARD')
        
        % retrieve letf image
        image_l = mexZED('retrieveImage', 'left');
        % retrieve right image
        image_r = mexZED('retrieveImage', 'right');
        
        % retrieve depth as a normalized image
        depth_im = mexZED('normalizeMeasure', 'depth');
        % retrieve the real depth
        depth = mexZED('retrieveMeasure', 'depth');
        
        % display
        subplot(2,2,1)
        imshow(image_l);
        title('Image Left')
        subplot(2,2,2)
        imshow(image_r);
        title('Image Right')
        subplot(2,2,3)
        imshow(depth_im);
        title('Depth')
        subplot(2,2,4)
        % Compute the depth histogram
        val_ = find(isfinite(depth(:))); % handle wrong depth values
        depth_v = depth(val_);
        [bincounts] = histc(depth_v(:),binranges);
        bar(binranges,bincounts,'histc')
        title('Depth histogram')
        xlabel('meters')
        
        drawnow; %this checks for interrupts
        ok = ishandle(f); %does the figure still exist
    end
end

% Make sure to call this function to free the memory before use this again
mexZED('delete')

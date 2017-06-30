close all; clear all; clc;

% preparing camera
device = imaqhwinfo;
[camera_name, camera_id, resolution] = CameraInfo(device);
vid = videoinput(camera_name, camera_id, resolution);
set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorspace', 'rgb')
vid.FrameGrabInterval = 5; % grab frame per 5 interval

% display windows for selecting music files
[FileName,PathName] = uigetfile('*.mp3;*.wma;*.ogg;*.wav;*.aif;*.m4a');
v = fullfile(PathName, FileName);
b = audioread(v);
s = audioplayer(b,44100);

% start webcam and play the music
start(vid);
pause(1);
play(s);

% any key pressed will stop the program
h = figure('KeyPressFcn','keep=0');
keep = 1;

first=[]; % initialize the first frame in the video stream

% loop over the frames of the video
while keep
    frame = getsnapshot(vid); % grab the current frame
    frame = imresize(frame, [240 320]); % resize it to 240x320
    data = rgb2gray(frame); % convert it to grayscale
    data = imgaussfilt(data, 35); % Gaussian Blur
    
    % set the first frame as the background model
    if isempty(first)
        first = data;
        continue
    end
    
    % performing a subtraction between the current frame and a background 
    % model, dilate the thresholded image to fill in holes, then find 
    % contours on thresholded image
    diff = imsubtract(first, data); 
    diff = imdilate(diff,strel('line',2,0));
    diff = im2bw(diff, 0.015);
    diff = bwareafilt(diff, 1);
    bw = bwlabel(diff, 8);
    stats = regionprops(bw, 'BoundingBox', 'Centroid');
    
    imshow(frame) % show the frame
    
    hold on
    
    % loop over the contours
    for object = 1:length(stats)
        bb = stats(object).BoundingBox;
        bc = stats(object).Centroid;
        
        % compute the bounding box for the contour, draw it on the frame
        rectangle('Position',bb,'EdgeColor','r','LineWidth',2)
        plot(bc(1),bc(2), '-m+')
        ay=text(bc(1)+25,bc(2), strcat('X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
        set(ay, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
        
        % compute the scales to get the volume value
        vol = round((bb(3)*bb(4))/76800,2);
        volume = SoundVolume(vol);
        
    end
    hold off
    pause(0.1)
end

% cleanup camera and sound system, and close any open windows
stop(vid);
stop(s);
flushdata(vid);    
close all;

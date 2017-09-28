function [im_rgb, im_dep] = read_image(s_frames, d_frames, idF)

% read: RGB image
im_rgb            = imread(s_frames{idF});  

% read: depth image (limit its range from 0-255)
im_dep            = double(imread(d_frames{idF}));
im_dep(im_dep==0) = 10000;
im_dep            = (im_dep-500)/8500;  %only use the data from 0.5-8m
im_dep(im_dep<0)  = 0;
im_dep(im_dep>1)  = 1;
im_dep            = uint8(255*(1 - im_dep));
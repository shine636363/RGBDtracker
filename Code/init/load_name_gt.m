function [rgb_name, dep_name, GT] = load_name_gt(SeqPath, SeqName)

% load the name of images
directory         = sprintf('%s%s/',SeqPath, SeqName);
FrameNum          = length(dir([directory,'RGB/*.png']));
for idF = 1:1:FrameNum
    rgb_name{idF} = sprintf('%sRGB/%08d.png',directory, idF);
    dep_name{idF} = sprintf('%sDepth/%08d.png',directory, idF);
end
% read ground-truth
GT                = dlmread(strcat(directory,'GT','.txt'));


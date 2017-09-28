function Run_STC()
% Author: Jingjing Xiao 14/01/2016 
% Email: shine636363@sina.com

warning off 

addpath(genpath('Code'));
SeqPath  = './RGBD_public/RGBDdataset/'; % path to the dataset
SeqList  = sprintf('%sbenchmark_name.txt', SeqPath);               % list of sequences
SeqNum   = 36;                                                     % number of suquences

%% Read namelist
Fid   = fopen(SeqList, 'r'); 
for idS = 1:1:SeqNum
    SeqName{idS} = fgetl(Fid);
end
fclose(Fid);

%% Tracking
for idS = 1:SeqNum
    Results  = STC(SeqPath, SeqName{idS}); % main tracker
    SavePath = sprintf('STC/STC_%s.txt', SeqName{idS});
    disp(sprintf('%s: done.....', SeqName{idS}))
    dlmwrite(SavePath, Results,'newline', 'pc','precision','%.2f')
end

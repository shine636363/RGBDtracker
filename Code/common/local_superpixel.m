function [Patch, im_rgb, SupImg] = local_superpixel(im_rgb, im_dep, g_para, Segbb, Para, patch_num, patch_size)
% Input: im_rgb--RGB image
%        im_dep--RGBD image
%        g_para--parameters for global model
%        Para--overall parameters
%        Segbb--bounding box for segmentation
% Output: Patch--local pool
%         SupImg--New segmented image

%% segment image
img                  = uint8(im_rgb(Segbb(1):Segbb(2),Segbb(3):Segbb(4),:));   % region for segmentation
[SupImg, SupCluster] = slic_segmentation(double(img), double(patch_num)); % segment region
Patch.size           = init_size(patch_size, g_para, patch_num);          % size initialization

%% initialize local patches
SupNum     = max(max(SupCluster));
for i = 0:1: SupNum
    [SpR SpC] = find(SupCluster == i);
    Patch.pos(i+1,:) = [round([mean(SpC) mean(SpR)])+ [Segbb(3) Segbb(1)]-Patch.size, repmat(2 * Patch.size, 1, 2)]; % get the patch image position
end
Patch.rgb_hist                   = col_hist(double(im_rgb), Patch.pos');
[Patch.dep_hist, Patch.dep_area] = dep_hist(double(im_dep), floor(Patch.pos')); 
Patch.dep_mean                   = sum(repmat(1:255, size(Patch.dep_hist, 1), 1).*Patch.dep_hist,2); % get the patch depth position  

%% depth constraint : depth (delete the ones belong to background/foreground)
if ~isempty(Para)
    id_out = [];
    
    % depth foreground
    if ~isempty(Para.dep_hist_fore) 
        id_out_fore = find(Patch.dep_mean>Para.dep_hist_fore)';
        id_out      = [id_out, id_out_fore];
    end
    % depth background
    if ~isempty(Para.dep_hist_back)
        id_out_back = find(Patch.dep_mean<Para.dep_hist_back)';  
        id_out      = [id_out, id_out_back];   
    end
    
    if ~isempty(id_out)
        Patch.pos(id_out,:)  = [];
        Patch.rgb_hist(id_out,:) = [];
        Patch.dep_mean(id_out)   = [];
        Patch.dep_area(id_out)   = [];
        Patch.dep_hist(id_out,:) = [];
    end
end
% overall
Patch.num            = size(Patch.pos, 1);          % patch number

% ------------ likelihood based on global statistic----------
for i = 1: Patch.num
    Patch.global_color_like(i) = global_statistic_like(g_para.global_color_like, Patch.pos(i,:), im_rgb);
    Patch.global_depth_like(i) = global_statistic_like(g_para.global_depth_like, Patch.pos(i,:), im_dep);
end

% for display
im_rgb(Segbb(1):Segbb(2),Segbb(3):Segbb(4),:) = SupImg; 

%% display the local patches
if 0
    figure(10)
    imshow(uint8(Img))
    for i = 1:Patch.num
        rectangle('Position',Patch.pos(i, :), 'LineWidth',2,'EdgeColor',[1 1 1])      
    end
    pause
end
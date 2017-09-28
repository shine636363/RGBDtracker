function [g_para, Segbb, Para ] = check_dep_change(im_rgb, im_dep, g_para, Para, Segbb)

%% check valid target pixel (depth)
est_bb          = change_bb(g_para.bb, im_dep, 0);                 % check depth boundary
img_bb_dep      = im_dep(est_bb(1):est_bb(2),est_bb(3):est_bb(4)); % depth image region
img_bb_dep_seg  = double(seg_dep_img(img_bb_dep, Para));           % segment depth image
target_ratio    = sum(img_bb_dep_seg(:))/(size(img_bb_dep_seg, 1)*size(img_bb_dep_seg, 2)); % compute target ratio
% im_dep_seg    = show_img_seg(im_dep_new, Para, g_para);

if target_ratio > 0.2 
    % enough depth inform
    Para.occ_flag    = 0;  % no full occlusion
    dep_bb_mean      = round(mean(img_bb_dep(img_bb_dep_seg~=0)));          % bounding box mean depth
    change_ratio     = (255 - dep_bb_mean)/(255 - g_para.dep_bb_mean_org);  % depth change ratio
    
    % check local (criteria 2: depth change)
    if Para.enlocal_flag~=1
        if change_ratio < 0.9 
            % moving foreward : become big (enable local) 
            Segbb              = change_bb(g_para.bb, im_rgb, 0.1); % enlarge the area
            Para.patch_scaling = 1.1;
            Para.enlocal_flag  = 1;
        elseif change_ratio > 1.1 
            % moving backward : become small (enable local)
            Segbb              = est_bb; % original area
            Para.patch_scaling = 0.9;
            Para.enlocal_flag  = 1;
        else            
            g_para.dep_bb_mean  = dep_bb_mean; % No local: save current mean depth
        end    
    end
    
    % Enabled local: estimate depth invariant histogram
    if  Para.enlocal_flag == 1         
        % g_para.dep_bb_mean = round(g_para.dep_bb_mean);
        bb_mean_diff = round(dep_bb_mean - g_para.dep_bb_mean); % depth difference: k frame - (k-1) frame
        Tresh_back = round(Para.dep_hist_back + bb_mean_diff);  % background depth invariance
        Tresh_fore = round(Para.dep_hist_fore + bb_mean_diff);  % foreground depth invariance
        depth_like = g_para.global_depth_like(Para.dep_hist_back:Para.dep_hist_fore);
        g_para.global_depth_like = zeros(1, 255);
        % check histogram boundary
        sign_back = 1 - Tresh_back;
        sign_fore = Tresh_fore - 255;    
        if sign_back > 0        
            depth_like(1: sign_back) = [];
            Tresh_back = 1;
        end
        if sign_fore > 0
            depth_like(end - sign_fore+1: end) = [];
            Tresh_fore = 255;
        end
        g_para.global_depth_like(Tresh_back :Tresh_fore) = depth_like; % depth transfer
    end
else
    % not enough target information: full occlusion % missing target
    Para.occ_flag = 1;
end

function [g_rgb, g_dep, g_para, Patch, Para, rect] = update_LG(im_rgb, im_dep, g_rgb, g_dep, g_para, Para, idM, Patch, Sp, Org_psize, rect, idF)

%--------------------------
%    occlusion judge
%--------------------------
idA = find(idM~=0); % matched superpixel
if  length(idA) > Para.occ_num
    %--- partical occlusion----
    [g_rgb, g_dep, g_para, Patch]           = update_local(im_rgb, im_dep, g_rgb, g_dep, g_para, idM, Patch, Sp, Para);
    [Para.dep_hist_fore,Para.dep_hist_back] = dep_constraint(im_dep, g_para.bb, Para.dep_filter);
    
    % get mean depth in bb
    est_bb                 = change_bb(g_para.bb, im_dep, 0);
    img_bb_dep             = im_dep(est_bb(1):est_bb(2),est_bb(3):est_bb(4));
    img_bb_dep_seg         = double(seg_dep_img(img_bb_dep, Para));
    g_para.dep_bb_mean     = mean(img_bb_dep(img_bb_dep_seg~=0));
    g_para.dep_bb_mean_org = g_para.dep_bb_mean; 
    rect(idF,:)            = g_para.bb;    
else
    %--- full occlusion ----
    Para.occ_flag        = 1;
    Patch.size           = Org_psize;
    rect(idF,:)          = rect(idF-1,:);
end
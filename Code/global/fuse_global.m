function [g_dep, g_rgb, g_para, Segbb, Para] = fuse_global(pos_rgb, pos_dep, g_dep, g_rgb, g_para, Para, im_rgb)

diff_pos                 = abs(pos_rgb - pos_dep);
if diff_pos(1) < Para.global_diff*g_para.target_sz(1) || diff_pos(2) < Para.global_diff*g_para.target_sz(2)
    % unambiguity
    Para.enlocal_flag      = 0;
    Segbb                  = [];
    [dep_score, rgb_score] = regression_prediction(g_dep, g_rgb , 0);
    g_para.pos             = rgb_score*pos_rgb + dep_score*pos_dep;
else
    % enable local: ambiguity (criteria 1)
    Para.enlocal_flag      = 1;
    Segbb                  = change_bb(g_para.bb, im_rgb, 0.2); % enlarged box (segmentation): x_1, x_2, y_1, y_2    
    [dep_score, rgb_score] = regression_prediction(g_dep, g_rgb, 1);
    g_para.pos             = rgb_score*pos_rgb + dep_score*pos_dep;  
    Para.patch_scaling     = 1;
    g_dep.resp             = [];
    g_rgb.resp             = [];
    if dep_score > rgb_score
        Para.order         = {'RGB','Global_depth','Global_RGB'};
    else
        Para.order         = {'RGB','Global_RGB','Global_depth'};
    end
end
g_para.bb  = round([g_para.pos([2,1]) - g_para.target_sz([2,1])/2, g_para.target_sz([2,1])]);
Para.rgb_thresh = Para.rgb_scaling * rgb_score;
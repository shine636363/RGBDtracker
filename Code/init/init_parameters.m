function Para =  init_parameters(im_dep, bb)
% input: bb --- bounding box

% pre-defined parameters
Para.rgb_scaling    = 0.2;
Para.dep_hist_fore  = [];
Para.dep_hist_back  = [];
Para.dep_filter     = 0.7;
Para.global_diff    = 0.1;
Para.occ_num        = 2;  
Para.occ_flag       = 0;
Para.fea_num        = 3;
Para.patch_scaling  = 1;
Para.patch_num      = 15;
Para.order          = {'RGB','Global_RGB','Global_depth'};

% compute depth constraint
[Para.dep_hist_fore,Para.dep_hist_back] = dep_constraint(im_dep, bb, Para.dep_filter); % depth boundary


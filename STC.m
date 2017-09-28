function tracker_results = STC(SeqPath, SeqName)

    %% initialization   
    [name_rgb, name_dep, GT] = load_name_gt(SeqPath, SeqName);       % get the name of images: RGB & depth
    [im_rgb, im_dep]         = read_image(name_rgb, name_dep, 1);    % read 1st frame    
    Para                     = init_parameters(im_dep, GT(1,:));     % initialize parameters
    [g_rgb, g_dep, g_para]   = init_global(im_rgb, im_dep, Para, GT(1,:)); % initialize global model
    Segbb                    = change_bb(g_para.bb, im_rgb, 0);            % bb for segmentation    
    [Patch, ~, SupImg]       = local_superpixel(im_rgb, im_dep, g_para, Segbb, Para, Para.patch_num, []); % initialize lcoal model   
    rect                     = zeros(numel(name_rgb), 4);                                 % save results
    rect(1,:)                = GT(1, :);
   
    %% begin tracking....
    for idF = 2:numel(name_rgb),
        if idF >=30
        end
        
        %----------------------
        %  Display processing
        %----------------------
        disp([SeqName, ': ', num2str(idF), '/', num2str(numel(name_rgb))])
        [im_rgb, im_dep] = read_image(name_rgb, name_dep, idF);  % read frame idF        
        %----------------------
        %  Global propagation
        %----------------------
        [g_rgb, g_dep, g_para, Segbb, Para] = track_global(im_rgb, im_dep, g_para, g_rgb, g_dep, Para);
        if Para.enlocal_flag && Para.occ_flag == 0 % (ambiguity||depth change) && full occlusion 
            %---------------
            %  Local Tree
            %---------------        
            Org_psize                           = Patch.size;                    % save original patch size
            Patch.size                          = Patch.size*Para.patch_scaling; % update patch size
            [idM, Sp]                           = tree_match(im_rgb, im_dep, g_para, Patch, Segbb, Para);
            [g_rgb, g_dep, g_para, Patch, Para, rect] = update_LG(im_rgb, im_dep, g_rgb, g_dep, g_para, Para, idM, Patch, Sp, Org_psize, rect, idF); % update local/global            
        else
            %------------------------
            %    pure global update
            %------------------------
            [Para.dep_hist_fore,Para.dep_hist_back] = dep_constraint(im_dep, g_para.bb, Para.dep_filter); % depth boundary
            [g_rgb, g_dep, g_para] = update_global(im_rgb, im_dep, g_rgb, g_dep, g_para); % update global model                             
            rect(idF,:)   = g_para.bb;
        end
    end
    tracker_results = rect; % save results
end






function [idM, Sp] = tree_match(im_rgb, im_dep, g_para, Patch, Segbb, Para)

%% segment image
if Para.patch_scaling >=1
    SegNum = 3*Patch.num;
else
    SegNum = 2*Patch.num;
end
[Sp, ~, ~] = local_superpixel(im_rgb, im_dep, g_para, Segbb, Para, SegNum, Patch.size);        
idM        = zeros(Patch.num, 1);    

% figure(30)
% imshow(uint8(im_rgb))
% title('matched superpixel (deformation)')
if Sp.num ~=0
   P2Scolor = patch_sp(double(Patch.rgb_hist)', double(Sp.rgb_hist)')'; % color matching score
   for i = 1:1:Patch.num  % matching from highest score
        p  = candidate_patch(P2Scolor, idM);
        sp = candidate_sp(Sp.num, idM, P2Scolor(p, :), Para); % computer candidate id of superpixel
        if isempty(sp)                               % no more unmatched superpixel
            break
        end
        for feature_id = 1:1:Para.fea_num
            switch Para.order{feature_id}
                case 'RGB'
                    color_score  = P2Scolor(p, sp);
                    sp = cluster_id(color_score, sp, 'max', feature_id==Para.fea_num );% cluster
                case 'Global_depth'
                    global_depth_score = Sp.global_depth_like(sp);
                    sp = cluster_id(global_depth_score, sp, 'max', feature_id==Para.fea_num );% cluster
                case 'Global_RGB'
                    global_RGB_score = Sp.global_color_like(sp);
                    sp = cluster_id(global_RGB_score, sp, 'max', feature_id==Para.fea_num );% cluster
            end
            if length(sp) == 1  % find the unique match --- stop searching
                break;
            end
        end
        idM(p, 1) = sp;
%         rectangle('Position',Sp.rgb_pos(sp,:), 'LineWidth',3,'EdgeColor',[1 0 1])  
    end
end
            
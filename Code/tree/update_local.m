function [g_rgb, g_dep, g_para, Patch] = update_local(im_rgb, im_dep, g_rgb, g_dep, g_para, idM, Patch, Sp, Para)

idA           = find(idM~=0);
idC           = 1: Sp.num;
idC(idM(idA)) = [];                                      % unmatched sp id
idD_org       = drift_id_cluster(Sp.pos(idM(idA, 1),:)); % id: too far
if ~isempty(idD_org) && ~isempty(idC)                    % have: drifing & unmatched sp
    num_idD    = min(length(idC),length(idD_org));
    idD_real   = idM(idA(idD_org),1);             % get real matched sp id
    idT        = setdiff(idM(idA, 1)', idD_real); % trust matched sp    
    if length(idT) > 1                            % ensure more than one unmatched sp
        new_pos    = mean(Sp.pos(idT, 1:2));
%         new_dep    = mean(Sp.dep_mean(idT));      
        new_col    = mean(Sp.rgb_hist(idT, :));
    else
        new_pos    = Sp.pos(idT, 1:2);
%         new_dep    = Sp.dep_mean(idT);     
        new_col    = Sp.rgb_hist(idT, :);
    end
    cand_pos   = sum(abs(Sp.pos(idC, 1:2) - repmat(new_pos, length(idC), 1))');   
    cand_col   = sum(sqrt(Sp.rgb_hist(idC, :).* repmat(new_col,length(idC), 1)), 2);
    rank       = re_sort(cand_pos , cand_col);
        
    %--- replace the drifting patch ---  
    Sp.dep_mean(idD_real(1:num_idD))   = Sp.dep_mean(idC(rank(1:num_idD)));
    Sp.dep_area(idD_real(1:num_idD))   = Sp.dep_area(idC(rank(1:num_idD)));
    Sp.dep_hist(idD_real(1:num_idD),:) = Sp.dep_hist(idC(rank(1:num_idD)),:);
    Sp.pos(idD_real(1:num_idD),:)      = Sp.pos(idC(rank(1:num_idD)), :);
    Sp.rgb_hist(idD_real(1:num_idD),:) = Sp.rgb_hist(idC(rank(1:num_idD)),:);
end

%--- partial occlusion----
update_lambda           = 0.2;
match_ratio             = update_lambda * length(idA)/Patch.num;
dep_update_rate         = match_ratio*repmat(sum(Patch.dep_hist(idA,:)'.*Sp.dep_hist(idM(idA, 1),:)')', 1, 255);
rgb_update_rate         = match_ratio*repmat(sum(Patch.rgb_hist(idA,:)'.*Sp.rgb_hist(idM(idA, 1),:)')', 1, 512);

Patch.rgb_pos(idA,:)    = Sp.pos(idM(idA, 1),:); % Seg: local update 
Patch.rgb_hist(idA,:)   = (1-rgb_update_rate).*Patch.rgb_hist(idA,:) + rgb_update_rate.*Sp.rgb_hist(idM(idA, 1),:);   
Patch.dep_hist(idA,:)   = (1-dep_update_rate).*Patch.dep_hist(idA,:) + dep_update_rate.*Sp.dep_hist(idM(idA, 1),:);   
Patch.dep_pos(idA)      = Sp.dep_mean(idM(idA));                
Patch.dep_target        = mean(Patch.dep_pos(idA));
Patch.dep_relative      = Patch.dep_pos - Patch.dep_target;   

g_para.pos = mean(Patch.rgb_pos(idA,2:-1:1)) + Patch.size;
                
%-- no occlusion --
if length(idA) == Patch.num
    g_para.bb              = round([min(Patch.rgb_pos(idA,1)) min(Patch.rgb_pos(idA,2)) max(Patch.rgb_pos(idA,1))+ Patch.rgb_pos(1,3)-min(Patch.rgb_pos(idA,1)) max(Patch.rgb_pos(idA,2))+ Patch.rgb_pos(1,4)-min(Patch.rgb_pos(idA,2))]); 
    [g_rgb, g_dep, g_para] = init_global(im_rgb, im_dep, Para, g_para.bb); % initialize global model
end
Patch.occ                  = 0;
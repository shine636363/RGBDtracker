function im_dep_seg = seg_dep_img(img_bb_dep, Para)
% binary depth map

im_dep_seg = ones(size(img_bb_dep));
if ~isempty(Para.dep_hist_back)
    im_dep_seg(img_bb_dep<Para.dep_hist_back) = 0;
end


% if (size(im_dep_est, 1)== old_bb(4)) && (size(im_dep_est, 2)== old_bb(3))
%     lamda = 0.1;
%     im_dep_seg = ones(size(im_dep_est));
%     if ~isempty(Thresh.dep_hist_back)
%         im_dep_seg(im_dep_est<Thresh.dep_hist_back) = 0;
%     end
% 
%     % x - axis
%     for i = 1: old_bb(3)*lamda
%         if sum(im_dep_seg(:, i)) > 0
%             break
%         end
%     end
%     x_start = i;
%     for i = old_bb(3): -1: old_bb(3)*lamda
%         if sum(im_dep_seg(:, i)) > 0
%             break
%         end
%     end
%     x_end = i;
% 
%     % y - axis
%     for j = 1: old_bb(4)*lamda
%         if sum(im_dep_seg(j, :)) > 0
%             break
%         end
%     end
%     y_start = j;
%     for j = old_bb(4): -1:old_bb(4)*lamda
%         if sum(im_dep_seg(j, :)) > 0
%             break
%         end
%     end
%     y_end = j;
% 
%     if (y_end-y_start)*(x_end-x_start)>0.8*old_bb(3)*old_bb(4)
%         new_bb = old_bb;
%     else
%         new_bb = [old_bb(1)+x_start-1, old_bb(2)+y_start-1, x_end-x_start+1, y_end-y_start+1];
%     end
% else
%     new_bb = old_bb;
% end
%     
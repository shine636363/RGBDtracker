function [hist_fore, hist_back] = dep_constraint(im_dep, bb, dep_filter)

%% target depth Gaussian
[Tar_hist, Tar_area]   = dep_hist(double(im_dep), double(bb)');

% context depth Gaussian
ROI_bb               = change_bb(bb, im_dep, 0.5); % enlarged bounding box: target + context
[ROI_hist, ROI_area] = dep_hist(double(im_dep), double([ROI_bb(3), ROI_bb(1), ROI_bb(4)-ROI_bb(3), ROI_bb(2)-ROI_bb(1)])');  % ROI Gaussian: target + context
Cont_area            = ROI_area - Tar_area;        % contextual Gaussian
Cont_hist            = (ROI_area*ROI_hist - Tar_area*Tar_hist)/Cont_area;

%% infomation loss
[left_target, right_target]   = get_hist_thresh(Tar_hist, dep_filter, 'tight');  % depth threshold (from target)
[left_context, right_context] = get_hist_thresh(Cont_hist, dep_filter, 'loose'); % depth threshold (from context))

%% background consistency
if left_context > left_target
    hist_back = 1; % background clutter
else
    if right_context < left_target
        hist_back = round((right_context + left_target)/2); % strong constraint
    else
        hist_back = round((left_context + left_target)/2);
    end
end

%% foreground consistency
if right_context < right_target
    hist_fore = 255; 
else
    if left_context > right_target
        hist_fore = round((left_context + right_target)/2); % strong constraint
    else
        hist_fore = round((right_context + right_target)/2);
    end
end


%% visualization
if 0
    if ~isempty(hist_fore)
        plot([hist_fore, hist_fore], [0 0.6],'r')   % left threshold  
    end
    if ~isempty(hist_back)
        plot([hist_back, hist_back], [0 0.6],'g') % right threshold
    end
end




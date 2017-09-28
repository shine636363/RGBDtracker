function [dep_score, rgb_score] = regression_prediction(g_dep, g_rgb, flag)

    % depth regression
    dep_data = g_dep.resp(max(1, end-5):end-1);
    time_len = length(dep_data);
   if time_len > 2 && flag  % regression from 2nd frame
        fittype  = 'poly2';  
        dep_f    = fit([1:time_len]', dep_data',fittype);
        dep_est  = dep_f.p1*(time_len+1)^2+dep_f.p2*(time_len+1)+dep_f.p3;
        dep_s    = exp(-20*abs(g_dep.resp(end)-dep_est));

        % rgb regression
        rgb_data = g_rgb.resp(max(1, end-5):end-1);
        rgb_f    = fit([1:time_len]', rgb_data',fittype);
        rgb_est  = rgb_f.p1*(time_len+1)^2+rgb_f.p2*(time_len+1)+rgb_f.p3;
        rgb_s    = exp(-20*abs(g_rgb.resp(end)-rgb_est)); 
        
        % regression score
        dep_score = dep_s/(dep_s + rgb_s);
        rgb_score = rgb_s/(dep_s + rgb_s);
   else  
        % no regression
        weig_rgb = g_rgb.resp(end)/max(g_rgb.resp(max(1, end-5):end));
        weig_dep = g_dep.resp(end)/max(g_dep.resp(max(1, end-5):end));
        rgb_score = weig_rgb/(weig_rgb + weig_dep);
        dep_score = weig_dep/(weig_rgb + weig_dep);
    end
end
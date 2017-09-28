function [g_rgb, g_dep, g_para, Segbb, Para] = track_global(im_rgb, im_dep, g_para, g_rgb, g_dep, Para)

%% occlusion status
if Para.occ_flag
    step = 1:9;   % occlusion: enlarg search area
else
    step = 1;
end

%% KCF estimation
for i_shift = step
    new_pos = g_para.pos + g_para.shift_pos(i_shift);
    
    % RGB images
    zp = feature_projection(g_rgb.z_npca, g_rgb.z_pca, g_rgb.projection_matrix, g_rgb.cos_window);% compute the compressed learnt appearance       
    [xo_npca, xo_pca] = get_subwindow(im_rgb, new_pos, g_para.sz, g_rgb.non_compressed_features, g_rgb.compressed_features, g_rgb.w2c); % extract the feature map of the local image patch
    x = feature_projection(xo_npca, xo_pca, g_rgb.projection_matrix, g_rgb.cos_window);% do the dimensionality reduction and windowing
    kf = fft2(dense_gauss_kernel(g_rgb.sig, x, zp));% calculate the response of the classifier
    response_rgb = real(ifft2(g_rgb.alphaf_num .* kf ./ g_rgb.alphaf_den));
    [row, col] = find(response_rgb == max(response_rgb(:)), 1);% target location is at the maximum response
    if ~isempty(row) % update estimation
        pos_rgb_new(i_shift,:) = new_pos - floor(g_para.sz/2) + [row, col];
    end
    resp_rgb_new(i_shift)    = max(response_rgb(:));
    
    % Depth images
    p = get_subwindow_dep(im_dep,  new_pos, g_para.sz);
    zf = fft2(get_features(p, g_dep.features, g_dep.cell_size, g_dep.cos_window));
    kzf = gaussian_correlation(zf, g_dep.model_xf, g_dep.kernel.sigma);%calculate response of the classifier at all shifts
    response_dep = real(ifft2(g_dep.model_alphaf .* kzf));  %equation for fast detection
    [vert_delta, horiz_delta] = find(response_dep == max(response_dep(:)), 1);
    if vert_delta > size(zf,1) / 2,  %wrap around to negative half-space of vertical axis
        vert_delta = vert_delta - size(zf,1);
    end
    if horiz_delta > size(zf,2) / 2,  %same for horizontal axis
        horiz_delta = horiz_delta - size(zf,2);
    end
    pos_dep_new(i_shift,:) = new_pos + g_dep.cell_size * [vert_delta - 1, horiz_delta - 1];
    resp_dep_new(i_shift) = max(response_dep(:));
    
    % useful in occlusion
    resp_all(i_shift) = resp_rgb_new(i_shift) + resp_dep_new(i_shift);
end
% choose the best pair among all shifts
i_id = find(resp_all == max(resp_all));
pos_rgb = pos_rgb_new(i_id(1),:);
pos_dep = pos_dep_new(i_id(1),:);

g_rgb.bb          = round([pos_rgb([2,1]) - g_para.target_sz([2,1])/2, g_para.target_sz([2,1])]);
g_rgb.resp(end+1) = resp_rgb_new(i_id(1));

g_dep.bb = round([pos_dep([2,1]) - g_para.target_sz([2,1])/2, g_para.target_sz([2,1])]);
g_dep.resp(end+1) = resp_dep_new(i_id(1));
  
%% fuse global features
[g_dep, g_rgb, g_para, Segbb, Para] = fuse_global(pos_rgb, pos_dep, g_dep, g_rgb, g_para, Para, im_rgb);
[g_para, Segbb, Para] = check_dep_change(im_rgb, im_dep, g_para, Para, Segbb); % check depth change

%% show results
if 0
    res_rgb = max(response_rgb(:));
    res_dep = max(response_dep(:));
    rgb_bb = round([pos_rgb([2,1]) - KCF_para.target_sz([2,1])/2, KCF_para.target_sz([2,1])]);
    dep_bb = round([pos_dep([2,1]) - KCF_para.target_sz([2,1])/2, KCF_para.target_sz([2,1])]);
    figure(1)
    imshow(uint8(im_rgb))
    rectangle('Position',rgb_bb, 'LineWidth',1,'EdgeColor',[1 0 0])  
    rectangle('Position',KCF_para.bb, 'LineWidth',3,'EdgeColor',[1 0 1])  
    text(25,60, ['Score:',num2str(res_rgb)],'fontsize',30,'fontweight','bold','color',[0 1 0])
    figure(2)
    imshow(uint8(im_dep_new))
    rectangle('Position',dep_bb, 'LineWidth',1,'EdgeColor',[1 0 0])  
    rectangle('Position',KCF_para.bb, 'LineWidth',3,'EdgeColor',[1 0 1])  
    text(25,60, ['Score:',num2str(res_dep)],'fontsize',30,'fontweight','bold','color',[0 1 0])
end


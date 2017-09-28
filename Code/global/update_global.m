function [g_rgb, g_dep, g_para] = update_global(im_rgb, im_dep, g_rgb, g_dep, g_para)

%% likelihood based on global statistic
% color
Segbb = change_bb(g_para.bb, im_rgb, 0.5); % enlarged box (segmentation): x_1, x_2, y_1, y_2
[color_target_like, color_target_area]   = col_hist(double(im_rgb), double(g_para.bb)');
[color_overall_like, color_overall_area] = col_hist(double(im_rgb), double([Segbb(3);Segbb(1);Segbb(4)-Segbb(3);Segbb(2)-Segbb(1)]));
g_para.global_color_like = color_target_like*color_target_area./(color_overall_like*color_overall_area+1);

% depth
[depth_target_like, depth_target_area]   = dep_hist(double(im_dep), double(g_para.bb)');   
[depth_overall_like, depth_overall_area] = dep_hist(double(im_dep), double([Segbb(3);Segbb(1);Segbb(4)-Segbb(3);Segbb(2)-Segbb(1)]));
g_para.global_depth_like = depth_target_like*depth_target_area./(depth_overall_like*depth_overall_area+1);


%% KCF rgb
[xo_npca, xo_pca] = get_subwindow(im_rgb, g_para.pos, g_para.sz, g_rgb.non_compressed_features, g_rgb.compressed_features, g_rgb.w2c);% extract the feature map of the local image patch to train the classifer
 
% update the appearance
g_rgb.z_npca = (1 - g_rgb.learning_rate) * g_rgb.z_npca + g_rgb.learning_rate * xo_npca;
g_rgb.z_pca = (1 - g_rgb.learning_rate) * g_rgb.z_pca + g_rgb.learning_rate * xo_pca;

data_mean = mean(g_rgb.z_pca, 1); % compute the mean appearance
        
% substract the mean from the appearance to get the data matrix
data_matrix = bsxfun(@minus, g_rgb.z_pca, data_mean);
cov_matrix = 1/(prod(g_para.sz) - 1) * (data_matrix' * data_matrix); % calculate the covariance matrix
        
[pca_basis, pca_variances, ~] = svd((1 - g_rgb.compression_learning_rate) * g_rgb.old_cov_matrix + g_rgb.compression_learning_rate * cov_matrix);% calculate the principal components (pca_basis) and corresponding variances
g_rgb.projection_matrix = pca_basis(:, 1:g_rgb.num_compressed_dim);
projection_variances = pca_variances(1:g_rgb.num_compressed_dim, 1:g_rgb.num_compressed_dim);
% update the old covariance matrix using the computed
% projection matrix and variances
g_rgb.old_cov_matrix = (1 - g_rgb.compression_learning_rate) * g_rgb.old_cov_matrix + g_rgb.compression_learning_rate * (g_rgb.projection_matrix * projection_variances * g_rgb.projection_matrix');
% project the features of the new appearance example using the new
% projection matrix
x = feature_projection(xo_npca, xo_pca, g_rgb.projection_matrix, g_rgb.cos_window);
    
% calculate the new classifier coefficients
kf = fft2(dense_gauss_kernel(g_rgb.sig, x));
new_alphaf_num = g_rgb.yf .* kf;
new_alphaf_den = kf .* (kf + g_rgb.lambda);
        
% subsequent frames, update the model
g_rgb.alphaf_num = (1 - g_rgb.learning_rate) * g_rgb.alphaf_num + g_rgb.learning_rate * new_alphaf_num;
g_rgb.alphaf_den = (1 - g_rgb.learning_rate) * g_rgb.alphaf_den + g_rgb.learning_rate * new_alphaf_den;
        

%% KCF Depth
%obtain a subwindow for training at newly estimated target position
p  = get_subwindow_dep(im_dep, g_para.pos, g_para.sz);
xf = fft2(get_features(p,  g_dep.features,  g_dep.cell_size,  g_dep.cos_window));
kf = gaussian_correlation(xf, xf, g_dep.kernel.sigma);
alphaf = g_dep.yf ./ (kf + g_dep.lambda);   %equation for fast training

%subsequent frames, interpolate model
g_dep.model_alphaf = (1 - g_dep.interp_factor) * g_dep.model_alphaf + g_dep.interp_factor * alphaf;
g_dep.model_xf = (1 - g_dep.interp_factor) * g_dep.model_xf + g_dep.interp_factor * xf;


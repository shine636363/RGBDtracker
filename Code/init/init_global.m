function [g_rgb, g_dep, g_para] = init_global(im_rgb, im_dep, Para, rect)
%% global_parameters
g_para.bb        = rect;
g_para.target_sz = [rect(4), rect(3)];
g_para.pos       = [rect(2),rect(1)] + floor(g_para.target_sz/2);
g_para.sz        = g_para.target_sz + floor(mean(g_para.target_sz));  % floor(target_sz * (1 + padding)); % window_size: taking padding into account
g_para.shift_pos = 0.5*[0 0; -g_para.sz(1) -g_para.sz(2);-g_para.sz(1) 0;...
          -g_para.sz(1) g_para.sz(2);0 -g_para.sz(2);...
          0 g_para.sz(2); g_para.sz(1) -g_para.sz(2);...
          g_para.sz(1) 0; g_para.sz(1) g_para.sz(2)]; % for occlusion
      
% ------------ global compared likelihood ------------
% color
Segbb = change_bb(g_para.bb, im_rgb, 0.5); % enlarged box (segmentation): x_1, x_2, y_1, y_2
[color_target_like, color_target_area]   = col_hist(double(im_rgb), double(g_para.bb)');
[color_overall_like, color_overall_area] = col_hist(double(im_rgb), double([Segbb(3);Segbb(1);Segbb(4)-Segbb(3);Segbb(2)-Segbb(1)]));
g_para.global_color_like = color_target_like*color_target_area./(color_overall_like*color_overall_area+1);

% depth
[depth_target_like, depth_target_area]   = dep_hist(double(im_dep), double(g_para.bb)');   
[depth_overall_like, depth_overall_area] = dep_hist(double(im_dep), double([Segbb(3);Segbb(1);Segbb(4)-Segbb(3);Segbb(2)-Segbb(1)]));
g_para.global_depth_like = depth_target_like*depth_target_area./(depth_overall_like*depth_overall_area+1);

% mean depth in bb
est_bb                   = change_bb(g_para.bb, im_dep, 0);                 % change coordinates
img_bb_dep               = im_dep(est_bb(1):est_bb(2),est_bb(3):est_bb(4)); % get the depth bb image
img_bb_dep_seg           = double(seg_dep_img(img_bb_dep, Para));
g_para.dep_bb_mean       = mean(img_bb_dep(img_bb_dep_seg~=0));
g_para.dep_bb_mean_org   = g_para.dep_bb_mean;

%% global_rgb
output_sigma_factor             = 1/16;	    % spatial bandwidth (proportional to target)
g_rgb.sig                       = 0.2;      % gaussian kernel bandwidth
g_rgb.lambda                    = 1e-2;	    % regularization (denoted "lambda" in the paper)
g_rgb.learning_rate             = 0.075;	% learning rate for appearance model update scheme (denoted "gamma" in the paper)
g_rgb.compression_learning_rate = 0.15;     % learning rate for the adaptive dimensionality reduction (denoted "mu" in the paper)
g_rgb.non_compressed_features   = {'gray'}; % features that are not compressed, a cell with strings (possible choices: 'gray', 'cn')
g_rgb.compressed_features       = {'cn'};   % features that are compressed, a cell with strings (possible choices: 'gray', 'cn')
g_rgb.num_compressed_dim        = 2;        % the dimensionality of the compressed features
temp                    = load('w2crs');    % load the normalized Color Name matrix
g_rgb.w2c               = temp.w2crs;    
g_rgb.resp              = [];
g_rgb.bb                = rect;

% desired output (gaussian shaped), bandwidth proportional to target size
output_sigma = sqrt(prod(g_para.target_sz)) * output_sigma_factor;
[rs, cs]     = ndgrid((1:g_para.sz(1)) - floor(g_para.sz(1)/2), (1:g_para.sz(2)) - floor(g_para.sz(2)/2));
y            = exp(-0.5 / output_sigma^2 * (rs.^2 + cs.^2));
g_rgb.yf     = single(fft2(y));
    
g_rgb.cos_window  = single(hann(g_para.sz(1)) * hann(g_para.sz(2))');% store pre-computed cosine window  
[xo_npca, xo_pca] = get_subwindow(im_rgb, g_para.pos, g_para.sz, g_rgb.non_compressed_features, g_rgb.compressed_features, g_rgb.w2c);   % extract the feature map of the local image patch to train the classifer
g_rgb.z_npca      = xo_npca;
g_rgb.z_pca       = xo_pca;
g_rgb.num_compressed_dim = min(g_rgb.num_compressed_dim, size(xo_pca, 2));
    
data_mean   = mean(g_rgb.z_pca, 1);
data_matrix = bsxfun(@minus, g_rgb.z_pca, data_mean); % substract the mean from the appearance to get the data matrix    
cov_matrix  = 1/(prod(g_para.sz) - 1) * (data_matrix' * data_matrix);% calculate the covariance matrix    
[pca_basis, pca_variances, ~] = svd(cov_matrix);
g_rgb.projection_matrix  = pca_basis(:, 1:g_rgb.num_compressed_dim);
projection_variances     = pca_variances(1:g_rgb.num_compressed_dim, 1:g_rgb.num_compressed_dim);   
g_rgb.old_cov_matrix     = g_rgb.projection_matrix * projection_variances * g_rgb.projection_matrix'; % initialize the old covariance matrix using the computed projection matrix and variances
      
% calculate the new classifier coefficients
x  = feature_projection(xo_npca, xo_pca, g_rgb.projection_matrix, g_rgb.cos_window);
kf = fft2(dense_gauss_kernel(g_rgb.sig, x));
new_alphaf_num   = g_rgb.yf .* kf;
new_alphaf_den   = kf .* (kf + g_rgb.lambda);
g_rgb.alphaf_num = new_alphaf_num;
g_rgb.alphaf_den = new_alphaf_den;

%% global_depth
g_dep.interp_factor = 0.02;
g_dep.lambda        = 1e-4;  %regularization
g_dep.cell_size     = 4;
g_dep.kernel.sigma  = 0.5;
g_dep.kernel.poly_a = 1;
g_dep.kernel.poly_b = 9;
g_dep.features.gray = 0;
g_dep.features.hog  = 1;
g_dep.features.hog_orientations = 9;
g_dep.resp          = [];
g_dep.bb            = rect;

output_sigma     = sqrt(prod(g_para.target_sz)) * output_sigma_factor / g_dep.cell_size;
g_dep.yf         = fft2(gaussian_shaped_labels(output_sigma, floor(g_para.sz / g_dep.cell_size)));
g_dep.cos_window = hann(size(g_dep.yf,1)) * hann(size(g_dep.yf,2))';

p      = get_subwindow_dep(im_dep, g_para.pos, g_para.sz);
xf     = fft2(get_features(p, g_dep.features, g_dep.cell_size, g_dep.cos_window));
kf     = gaussian_correlation(xf, xf, g_dep.kernel.sigma);%Kernel Ridge Regression, calculate alphas (in Fourier domain)
alphaf = g_dep.yf ./ (kf + g_dep.lambda);   %equation for fast training
g_dep.model_alphaf = alphaf;
g_dep.model_xf     = xf;
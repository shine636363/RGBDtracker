function out = get_feature_map(im_patch, features, w2c)

    % out = get_feature_map(im_patch, features, w2c)
    % Extracts the given features from the image patch. w2c is the
    % Color Names matrix, if used.
    if nargin < 3
        w2c = [];
    end

    valid_features = {'gray', 'cn'};% the names of the features that can be used
    feature_levels = [1 10]';% the dimension of the valid features
    num_valid_features = length(valid_features);
    used_features = false(num_valid_features, 1);

    % get the used features
    for i = 1:num_valid_features
        used_features(i) = any(strcmpi(valid_features{i}, features));
    end

    
    num_feature_levels = sum(feature_levels .* used_features);% total number of used feature levels
    level = 0;
    if size(im_patch, 3) == 1 % If grayscale image
        % Features that are available for grayscale sequances
        % Grayscale values (image intensity)
        out = single(im_patch)/255 - 0.5;
    else
        % Features that are available for color sequances
        % allocate space (for speed)
        out = zeros(size(im_patch, 1), size(im_patch, 2), num_feature_levels, 'single');

        % Grayscale values (image intensity)
        if used_features(1)
            out(:,:,level+1) = single(rgb2gray(im_patch))/255 - 0.5;
            level = level + feature_levels(1);
        end
        % Color Names
        if used_features(2)
            if isempty(w2c)
                % load the RGB to color name matrix if not in input
                temp = load('w2crs');
                w2c = temp.w2crs;
            end
            % extract color descriptor
            out(:,:,level+(1:10)) = im2c(single(im_patch), w2c, -2);
            level = level + feature_levels(2);
        end
    end
end
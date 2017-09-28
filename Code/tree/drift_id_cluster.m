function idD = drift_id_cluster(pos)

idD = [];
if size(pos, 1) > 5 % check drifting when there are enough matched patches
    thresh_x   = 2*pos(1, 3);
    thresh_y   = 2*pos(1, 4);

    num        = size(pos, 1);
    label      = zeros(num, 1);
    label_last = zeros(num, 1);
    label_x    = zeros(num, num);
    label_y    = zeros(num, num);
    dist_x     = abs(repmat(pos(:, 1), 1, num) - repmat(pos(:, 1)', num, 1));
    dist_y     = abs(repmat(pos(:, 2), 1, num) - repmat(pos(:, 2)', num, 1));

    label_x(dist_x < thresh_x) = 1;
    label_y(dist_y < thresh_y) = 1;
    label_xy = (label_x + label_y)/2;
    label_xy(label_xy < 1) = 0;

    % clustering
    label_count = 1;
    for i = 1: 1: num-1
        if sum(label_xy(i, i+1:end)) == 0 % no link
            if label(i) == 0 % no label -- add label
                label(i) = label_count;
                label_count = label_count + 1;
            end
        else % has link
            id = find(label_xy(i, i:end) == 1); 
            if sum(label(id+i-1)) == 0 % no label
                label(id+i-1) = repmat(label_count, 1, length(id));
                label_count = label_count + 1;
            else % with label
                swap_label = label(id+i-1);
                swap_label(swap_label==0) = max(label(id+i-1));
                label(id+i-1) = swap_label;
                uni_label = unique(label(id+i-1));
                id_num = length(uni_label);% merge all labels
                for j = 1:1:id_num
                    label(label == uni_label(j)) = max(label(id+i-1));
                end
            end
        end
    end
    label_id = unique(label); % squential number
    for i = 1:1:length(label_id)
        cluster_id             = find(label == label_id(i));
        label_last(cluster_id) = i;
        if length(cluster_id) == 1
            center(i, :)       = pos(cluster_id, 1:2);
        else
            center(i, :)       = mean(pos(cluster_id, 1:2));
        end
        num_ratio(i)           = length(cluster_id)/size(pos, 1);
    end    
    if size(center, 1) ~= 1                   % within disconnected patches
        [~, id_x_start] = min(center(:, 1));  % get edge clusters
        [~, id_x_end]   = max(center(:, 1));
        [~, id_y_start] = min(center(:, 2));
        [~, id_y_end]   = max(center(:, 2));
        id_x            = [id_x_start id_x_end];
        id_y            = [id_y_start id_y_end];
        id_xy           = unique([id_x, id_y]);  % edge cluster
        id_num_ratio    = find(num_ratio ~= max(num_ratio));
        id              = intersect(id_xy, id_num_ratio);
        
        if ~isempty(id)
            for i = 1: length(id)
                idD_init = find(label_last == id(i));
                num_ratio = length(idD_init)/size(pos, 1);
                if num_ratio < 0.3
                    idD = [idD idD_init'];
                end
            end
        end
    end
end




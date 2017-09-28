function new_id = cluster_id(score, candidate_id, dir, flag_stop)

if flag_stop == 1
    Thresh_cluster = 0;
else
    Thresh_cluster = var(score);
end

switch dir
    case 'max'
        id = find(score >= max(score)-Thresh_cluster);
    case 'min'
        id = find(score <= min(score)+Thresh_cluster);
end

if flag_stop == 1
    new_id = candidate_id(id(1));
else
    new_id = candidate_id(id);
end


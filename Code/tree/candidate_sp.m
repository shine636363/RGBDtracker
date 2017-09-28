function id = candidate_sp(num, idM, color_score, Para)

% get unmatched superpixel id
id        = 1:1:num;
id_score  = find(color_score < Para.rgb_thresh);
id_m_sp   = find(idM ~= 0)';
id_delete = unique([id_score, idM(id_m_sp)']);
if ~isempty(id_delete)
    id(id_delete) = [];
end
    
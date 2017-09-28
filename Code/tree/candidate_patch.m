function  p  = candidate_patch(P2Scolor, idM)

% begin with the best match
id_p = find(idM ~= 0);
id_s = idM(id_p)';
P2Scolor(id_p, :) = 0;
P2Scolor(:, id_s) = 0;
[p, ~] = find(P2Scolor == max(P2Scolor(:)), 1);


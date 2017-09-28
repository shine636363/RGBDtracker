function rank = re_sort(cand_dep , cand_col)

% rank from depth
[~, rank1] = sort(cand_dep, 'ascend');  
SpId       = 1: length(cand_dep);
rank       = [];
k          = 1;

while k<=length(rank1)
    id1 = find(cand_dep(k:end) >= max(cand_dep(k: end)) - std(cand_dep));
    if length(id1)<2
        rank = [rank; rank1(k)];
    else
        id2 = rank1(k:k-1+length(id1));  % get the similar likelihood id
        idReal = SpId(id2);
        [~,id3] = sort(cand_col(idReal),'descend');
        rank = [rank; idReal(id3)'];
    end   
    k   = k +length(id1);
end
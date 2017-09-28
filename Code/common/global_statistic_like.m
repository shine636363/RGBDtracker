function pos_like = global_statistic_like(like_hist, pos, im)

Segbb = change_bb(pos, im, 0);
if length(like_hist) == 512 % RGB
    rawMap = floor(im/32);
    for k = 1: size(pos, 1)
        patch = rawMap(Segbb(k, 1):Segbb(k, 2),Segbb(k, 3):Segbb(k, 4),:);
        binMap = patch(:,:,1)+patch(:,:,2)*8+patch(:,:,3)*64+1; % normalize bins: r+4*g+16*b
        for i = 1:1:size(patch,1)
            for j = 1:1:size(patch,2)
                like_map(i, j) = like_hist(binMap(i,j)); % likelihood map
            end
        end
        pos_like =  sum(like_map(:));
    end
else  % depth    
    for k = 1: size(pos, 1)
        patch = im(Segbb(k, 1):Segbb(k, 2),Segbb(k, 3):Segbb(k, 4),:)+1;
        for i = 1:1:size(patch,1)
            for j = 1:1:size(patch,2)
                like_map(i, j) = like_hist(patch(i,j)); % likelihood map
            end
            pos_like =  sum(like_map(:));
        end
    end
end

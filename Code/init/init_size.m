function new_size = init_size(patch_size, g_para, num)

if ~isempty(patch_size)
    % transfer the patch size
    new_size = patch_size;
else
    % heuristic size initialization
    bb_size = g_para.bb(3)*g_para.bb(4);
    if bb_size > 20000
        new_size = floor(sqrt(g_para.bb(3)*g_para.bb(4)/num)/1.7);  
    elseif bb_size > 10000
        new_size = floor(sqrt(g_para.bb(3)*g_para.bb(4)/num)/1.9);  
    elseif bb_size > 5000
        new_size = floor(sqrt(g_para.bb(3)*g_para.bb(4)/num)/2.1);  
    else
        new_size = floor(sqrt(g_para.bb(3)*g_para.bb(4)/num)/2.3);  
    end
end
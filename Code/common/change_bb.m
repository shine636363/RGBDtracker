function NewBox = change_bb(rect, im, ratio)
% input : rect --- [x, y, w, h]
%         ratio ---- scaling factor
% output: NewBox --- [x1, x2, y1, y2]
Dim_row = size(rect, 1);
NewBox  = [];
for i = 1:1: Dim_row
    
    % check the boundary
    if rect(i, 1) > size(im, 2)
        rect(i, 1) = size(im, 2)-rect(i, 3);
    end

    if rect(i, 2) > size(im, 1)
        rect(i, 2) = size(im, 1)-rect(i, 4);
    end
    
    % get ROI coordinates
    Edge = floor(mean([ratio*rect(i, 4), ratio*rect(i, 3)]));   
    NewBox(i, 1) = rect(i, 2)-floor(Edge);
    NewBox(i, 2) = rect(i, 2)+floor(rect(i, 4))+floor(Edge)-1;
    NewBox(i, 3) = rect(i, 1)-floor(Edge);
    NewBox(i, 4) = rect(i, 1)+floor(rect(i, 3))+floor(Edge)-1;
    
    % check the boundary
    if NewBox(i, 1)<1   
        NewBox(i, 1) = 1;
    end

    if NewBox(i, 3)<1
        NewBox(i, 3) = 1;
    end

    if NewBox(i, 2) > size(im, 1)
        NewBox(i, 2) = size(im, 1);
    end

    if NewBox(i, 4) > size(im, 2)
        NewBox(i, 4) = size(im, 2);
    end
    
    NewBox = floor(NewBox);
end
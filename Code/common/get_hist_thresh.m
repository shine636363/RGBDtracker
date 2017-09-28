function [out_left, out_right] = get_hist_thresh(org_hist, area_thresh, width)
% INPUT: org_hist --- original histogram
%        area_thresh --- information loss
%        width --- 'tight','loose'

% TEST
% width       = 'tight';
% area_thresh = 0.2; % inside interval
% org_hist    = [0,0,0,0,0,0,0,0,0.000988630746416214,0,0,0.00741473059812160,0,0.0192782995551162,0,0.0358378645575877,0,0.0311418685121107,0,0.00840336134453782,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.0301532377656945,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.00123578843302027,0.0323776569451310,0.104547701433515,0.0630252100840336,0.00296589223924864,0.643845773603559,0.0187839841819081,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
% org_hist    = org_hist./sum(org_hist(:));

%% ----- initialize the data -------
new_hist  = cumsum(org_hist);

der1hist = org_hist(1:end-1)-org_hist(2:end); % get the first derivative
switch width
    case 'tight'
        id1_left  = find(der1hist<0);  % monotone increasing
        id1_right = find(der1hist>0);  % monotone decreating
        id2       = find(org_hist <= 0.001);
        id_left   = intersect(id1_left, id2);
        id_right  = intersect(id1_right+1, id2);
        area_thresh = 1 - area_thresh;
    case 'loose'        
        id1_left  = find(der1hist>0);  % monotone decreasing
        id1_right = find(der1hist<0);  % monotone increasing
        id2       =  find(org_hist <= 0.001);
        id_left   = intersect(id1_left+1, id2);
        id_right  = intersect(id1_right, id2);        
end;
if isempty(id_left)
    id_left = [1];
end
if isempty(id_right)
    id_right = [255];
end

%-------tight: plz solve the below problem --------
% find the index_left, index_right of the id_left, id_right, respectively
% Problem:
%            min(id_right(index_right) - id_left(index_left) )
%                            s.t.
%  new_hist(id_left(index_left))-new_hist(id_right(index_right)) < area_thresh - 1
%                id_right(index_right) > id_left(index_left)
switch width
    case 'tight'
        obj_value=inf;
        index_left=1;
        index_right=size(id_right, 2);
        for idx_left=1:length(id_left)
            for  idx_right=1:length(id_right)
                if  new_hist(id_left(idx_left))-new_hist(id_right(idx_right)) < area_thresh - 1 ...
                        && id_right(idx_right) > id_left(idx_left)

                    if id_right(idx_right) - id_left(idx_left) < obj_value                
                        index_left=idx_left;
                        index_right=idx_right;
                        obj_value=id_right(idx_right) - id_left(idx_left);
                    end
                end
            end
        end
%% -------loose: plz solve the below problem ------
% Problem:
%            max(id_right(index_right) - id_left(index_left) )
%                            s.t.
%  new_hist(id_left(index_left))-new_hist(id_right(index_right)) >  area_thresh - 1
%                id_right(index_right) > id_left(index_left)
    case 'loose'
        obj_value=-inf;
        index_left=1;
        index_right=size(id_right, 2);
        for idx_left=1:length(id_left)
            for  idx_right=1:length(id_right)
                if  new_hist(id_left(idx_left))-new_hist(id_right(idx_right)) > area_thresh - 1 ...
                        && id_right(idx_right) > id_left(idx_left)

                    if id_right(idx_right) - id_left(idx_left) > obj_value                
                        index_left=idx_left;
                        index_right=idx_right;
                        obj_value=id_right(idx_right) - id_left(idx_left);
                    end
                end
            end
        end
end

%% ------- output -------
out_left  = id_left(index_left);
out_right = id_right(index_right);

%% ------- display the results --------
if 0
    figure(20)
    hold off
    switch width
        case 'tight'
            subplot(2, 1, 1)
        case 'loose'
            subplot(2, 1, 2)
    end
    plot(1: 255, org_hist, 'b')               % original distribution
    hold on
    plot([out_left, out_left], [0 0.4],'g')   % left threshold  
    plot([out_right, out_right], [0 0.4],'r') % right threshold
    axis([0 255 0 0.5])
    switch width
        case 'tight'
            legend('histgram','background', 'foreground')
            filter_hist = sum(org_hist(out_left: out_right));
            title(['tight (target): ', num2str(out_left),', ', num2str(out_right), ', ',num2str(filter_hist)])
        case 'loose'
            legend('histgram','background', 'foreground')
            filter_hist = 1 - sum(org_hist(out_left: out_right));
            title(['loose (context): ', num2str(out_left),', ', num2str(out_right),', ', num2str(filter_hist)])
    end
end
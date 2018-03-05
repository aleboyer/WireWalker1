function gridout = add_nancolumns(gridin,idpos);
% idpos are the positions where a column of NaN should be added

idpos = idpos+cumsum(ones(size(idpos)));

[r,c]           = size(gridin);
add             = numel(idpos);             % How much longer Anew is
gridout         = NaN(r,c+add);             % Preallocate
idx             = setdiff(1:c+add,idpos);    % all positions of gridout except idpos
gridout(:,idx)  = gridin;


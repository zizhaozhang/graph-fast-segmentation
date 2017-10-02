% function [S, V, A, E, E_sp, U] = getSp(I, sp_scale)
function [U,V] = getSp(I, sp_scale)

addpath(genpath('SE/'));
persistent model1;
if isempty(model1)
    model1=load('SE/models/forest/modelBsds'); 
end
model=model1.model;
model.opts.nms=-1; model.opts.nThreads=4;
model.opts.multiscale=0; model.opts.sharpen=2;

%% set up opts for spDetect (see spDetect.m)
opts = spDetect;
opts.nThreads = 4;  % number of computation threads
opts.k = sp_scale;       % controls scale of superpixels (big k -> big sp)
opts.alpha = .9;    % relative importance of regularity versus data terms
opts.beta = .9;     % relative importance of edge versus color terms
opts.merge = 0.000;     % set to small value to merge nearby superpixels at end

%% detect and display superpixels (see spDetect.m)
[E,~,~,segs]=edgesDetect(I,model);
[S,V] = spDetect(I,E,opts); 
[A,E_sp,U]=spAffinities(S,E,segs,opts.nThreads); 


% remove empty superpixels, still do not understand why
% S = removeemptysp(S); % bug here?

end

function seg = removeemptysp(seg)
    
lis = unique(seg);
realn = length(lis);
for i = 2:realn
    %assert(~isempty(seg == lis(i)))
%     if length(find(seg == lis(i))) == 0, fprintf('%d:',i);end
    seg(seg == lis(i)) = i-1;
end
end


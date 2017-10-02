function Nei = buildNeiborMat(W, geoD, opts, imsz)
% W: affinity matrix in N x N
% k: number of neighboor
% Nei is N x N
%% Zizhao @ UF

N = size(W,1);
Nei = zeros(N, N);
% W(W == 0) = Inf;
for i = 1:size(W,1)
    
%     [~, idx] = sort(W(i,:),'descend'); % Weight has larger value for closer points
    [~, idx] = sort(W(i,:),'ascend'); % Weight has small value for closer points
    idx(geoD(i,idx) > opts.geoThre | geoD(i,idx) ==0) = [];
%     idx(idx==i) = []; % remove the index of itself
    
    idx = idx(1:min(length(idx),opts.NUM_OF_NEIGHBOR));
    Nei(idx,i) = 1;
end

end



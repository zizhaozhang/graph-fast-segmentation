function [centers, seg_val, D, borderdis] = compute_sp_mapping_info(segs,f_maps)

N = max(max(segs)); % # of sps
imsz = size(segs);
feat_dim = size(f_maps,3);
vec_f = reshape(f_maps,[],feat_dim);
seg_val = zeros(N,feat_dim);
centers = zeros(N,2); % [x, y]
borderdis = zeros(N,1);
parfor i = 1:N
   [y, x] = find(segs == i);
%    assert(~isempty(y) || ~isempty(x));
   seg_val(i,:) = mean(mean(vec_f(segs==i,:),1),1); % pay attention here that how to compute the mean
   tmp = [round(mean(y)), round(mean(x))]; 
   centers(i,:) = tmp;
   borderdis(i) = min([tmp(1) imsz(1)-tmp(1) tmp(2) imsz(2)-tmp(2)]);
end

%% small trick for multi-scale segs NaN problem

D = pdist3(centers, centers,'euclidean'); % pairwise distance


end
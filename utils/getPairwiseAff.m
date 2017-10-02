function [W, seg_val] = getPairwiseAff(segs, f_maps, opts)
% seg: is label map with 0 of edge
% radius: # of neighbors


N = max(max(segs)); % # of sps
feat_dim = size(f_maps,3);
vec_f = reshape(f_maps,[],feat_dim);
seg_val = zeros(N,feat_dim);

parfor i = 1:N
   seg_val(i,:) = mean(vec_f(segs==i,:),1); % pay attention here that how to compute the mean
end

W = pdist3(seg_val,seg_val);








% % extract features
% num_of_features = length(f_maps) ;
% 
% N = max(max(segs)); % # of sps
% W = cell(1,num_of_features);
% for ff = 1: num_of_features
% %     [~, feat{i}, ~] = compute_sp_mapping_info(seg,f_maps{i}); % recompute for each scale
%     feat_dim = size(f_maps{ff},3);
%     vec_f = reshape(f_maps{ff},[],feat_dim);
%     seg_val = zeros(N,feat_dim);
%     
%     parfor i = 1:N
%        seg_val(i,:) = mean(vec_f(segs==i,:),1); % pay attention here that how to compute the mean
%     end
% 
%     W{ff} = pdist3(seg_val,seg_val);
% %     W{i} = exp(W{i}/var(W{i}(:)));
% end

end


% function D = getWeights(fea1, fea2)
%     
%     D = pdist3(fea1, fea2);
% %     D = exp(-D);
% end



function [EV, EVal_true] = obtainEigs(img, segments, centers, opts)


%% get co-occurance probability 
[Ws, im_sizes, feat_maps] = getW_sp(img, segments, opts);

if length(Ws) > 1
    W = full(Ws{1}.*Ws{2});
else
    W = full(Ws{1});
end

W = (W - min(W(:))) / (max(W(:)) - min(W(:))); W(sub2ind(size(W),1:size(W,1),1:size(W,1))) = 1;
% pairwiseStrength(pairwiseStrength == 0) = 1;
% W = W .* pairwiseStrength;

%% compute LLE
if opts.withlle
    %% get neighboor for lle constriant M
    highorderfeat = getFeatures(im2double(img),1,'highorder',opts); %X = reshape(highorderfeat,[],3)'; 
    [PwD, feat_vec] = getPairwiseAff(segments, highorderfeat, opts); % simple use 
    opts.geoThre = norm(size(segments)) / 4; % LLE neighbor maximum distance large value gives tight constraint   
    geoD = geoDistance(centers, size(segments));
    neighboorMat = buildNeiborMat(PwD, geoD, opts, size(segments));
    [~, M] = compute_LLE(feat_vec', neighboorMat);
end

%% optimization
if opts.withlle
    [EV, EVal_true] = ncuts_sp(double(W), opts.NVEC, M, opts);
else
    [EV, EVal_true] = ncuts_sp(double(W), opts.NVEC, [], opts);
end

if opts.if_select_eigs
    % select eigenvectors
    [EV, keep_idx] = selectEigenV(EV, opts.eigen_ratio_thre, opts.max_eig_dim); % select eigs with large variance
end
%     

end
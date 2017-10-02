function [F, extra] = sampleF_dist(segs, f_maps, radius, opts)
% N: number of sampled pair


%% sampling params
    sig = opts.sig;
    max_offset = 4*sig+1;

%% obtain superpixel information
N = max(max(segs)); % # of sps

if ~isfield(opts,'centers')
    feat_dim = size(f_maps,3);
    centers = zeros(N,2); % [x, y]
    vec_f = reshape(f_maps,[],feat_dim);
    seg_val = zeros(N,feat_dim);
    for i = 1:N
       [y, x] = find(segs == i);
    %    if isempty(y) || isempty(x) disp('what the fuck');continue; end % why has empty?
       assert(~isempty(y) || ~isempty(x));
       seg_val(i,:) = mean(mean(vec_f(segs==i,:),1),1); % pay attention here that how to compute the mean
       centers(i,:) = [round(mean(y)), round(mean(x))]; 
    %    spidx{i} = sub2ind(imsz(1:2),y,x);

    %    for f = 1:num_of_features % current 2 different features
    %         feat{f}(i,:) =  getSpFeat(spidx{i}, vec_feat_map{f}, opts.histlen, opts.comp_feat_type);
    %    end
    end
    D = pdist3(centers, centers,'euclidean'); % pairwise distance
else
    seg_val = opts.seg_val;
    centers = opts.centers;
    D = opts.D;
end

%% sampling
% g = genCenterGaussian(ones(size(segs)));

p1 = []; p2 = []; %dist = [];
if isfield(opts,'sampling_weighting') && opts.sampling_weighting
    mask = tril(ones(size(D)));
    D(mask==1) = 1e4;  % only take half of the p(Si,Sj);
    d = []; % pairwise distance
    [sD,sI] = sort(D,2,'ascend');
    
%     scanidx = randperm(size(D,1), round(opts.sampling_ratio*size(D,1))); 
%     for j = 1:scanidx
    for j = 1:size(D,1) % this will
        idx = find(sD(j,:) <= radius);
        p1 = [p1; ones(length(idx),1)*j];
        p2 = [p2; sI(j,idx)']; 
        d = [d; sD(j,idx)'];
    end
    prob = (1/(sqrt(opts.sig)*sqrt(2*pi))) * exp(- (d / max(d)) / (2*opts.sig)); % gaussian weights
    idx = discretesample(prob, max(1, round(opts.sampling_ratio * numel(d))));
%     idx = unique(idx);
    p1 = p1(idx);
    p2 = p2(idx);
else
    for i = 1:N
       if centers(i,1) == 0 disp('samping error');continue; end

       s_dn = i+1:N; % only get half of the matrix 
       idx  = s_dn(D(i,s_dn) <= radius);

       p1 = [p1; repmat(i,length(idx),1)];
       p2 = [p2; idx(:)];

    end
end

if (opts.display_progress), fprintf('%d region pairs sampled\n', length(p1)); end

F = [seg_val(p1,:) seg_val(p2,:)];

% compute F_unary
extra.F_unary = nan(N,size(f_maps,3));
kk = cat(1,p1,p2);
extra.F_unary(kk,:) = seg_val(kk,:);

extra.F = F;
extra.ii = p1;
extra.jj = p2;
extra.sp_num = N;

% if (opts.model_half_space_only)
%     F = orderAB(F);
% end

end
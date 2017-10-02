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
for i = 1:N
%    figure(2),text(centers(i,2), centers(i,1),num2str(i),'Color',rand(1,3),'FontSize',8);
   if centers(i,1) == 0 disp('samping error');continue; end
   
   if opts.samping_weighting
% %        s_dn = [1:i-1 i+1:N];
%        s_dn = i+1:N; % only get half of the matrix 
%        [sD,sI] = sort(D(i,s_dn),'ascend');
%        tmpidx = find(sD < radius);
%        
%        if numel(tmpidx)==0 
%            idx = [];  
%        else
%            seD = sD(tmpidx);
%            mxv = max(seD) / (2*opts.sig);
%            p = (1/(opts.sig*sqrt(2*pi))) * exp(- (seD / mxv) / (2*opts.sig^2));
%            tidx = discretesample(p, max(1, round(opts.sampling_ratio * numel(p))));
%            idx = s_dn(sI(tmpidx(tidx)));
%         end


        mask = ones(tril(zeros(size(D))));
        D(mask==1) = 1e4;  % only take half of the p(Si,Sj);
        p1 = []; p2 = []; d = []; % pairwise distance
        [sD,sI] = sort(D,2,'ascend');
        for j = 1:length(D) % this will
            idx = find(sD(j,:) <= radius);
            p1 = [p1; ones(length(idx),1)*j];
            p2 = [p2; sI(j,idx)]; 
            d = [d;D(sD)];
        end
        prob = (1/(opts.sig*sqrt(2*pi))) * exp(- (d / max(d)) / (2*opts.sig^2)); % gaussian weights
        idx = discretesample(prob, max(1, round(opts.sampling_ratio * numel(d))));
        p1 = p1(idx);
        p2 = p2(idx);

   else
       s_dn = i+1:N; % only get half of the matrix 
       idx  = s_dn(D(i,s_dn) <= radius);
   end
   
  
   p1 = [p1; repmat(i,length(idx),1)];
   p2 = [p2; idx(:)];
   
%    dist = [dist; D(i,s_dn)']; % distance of region pair
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

if (opts.model_half_space_only)
    F = orderAB(F);
end

end
function [F, extra] = sampleF(segs, f_maps, opts)
% N: number of sampled pair

feat_dim = size(f_maps,3);

rid = 2; % neighboor position rid
sp_num = max(segs(:));
[y,x] = find(segs == 0);
f_maps = imPad(single(f_maps),[rid rid],'symmetric'); 
segs = imPad(single(segs),[rid rid],'symmetric');
pos = [y+rid x+rid]; % index to segs positions

orientations = {{[rid 0], [-rid 0]},...  % up and down
                {[0 -rid],[ 0 rid]} };   % left and right

imsz = size(f_maps); imsz = imsz(1:2);
% im_rgb = reshape(pad_img, [], 3);

%% find neighoboor pairs
accu = cell(2);
p1 = []; p2 = [];
for i = 1:2
%    figure,imshow(segs), hold on,
   n1_sub = bsxfun(@plus, pos, orientations{i}{1}); 
   n2_sub = bsxfun(@plus, pos, orientations{i}{2});   
%    plot(n1_sub(:,2), n1_sub(:,1),'*b');
%    plot(n2_sub(:,2), n2_sub(:,1),'*r');
   n1_idx = sub2ind(imsz, n1_sub(:,1), n1_sub(:,2));
   n2_idx = sub2ind(imsz, n2_sub(:,1), n2_sub(:,2));
   
   % clear points has neighboor not belonging to any segs 
   clear_idx = segs(n1_idx) == 0 | segs(n2_idx) == 0;
   n1_idx(clear_idx) = [];n2_idx(clear_idx) = [];
   
   % draw
   accu{i} = accumarray([segs(n1_idx), segs(n2_idx)], ones(numel(n1_idx),1)); 
   
   square = zeros(sp_num, sp_num);
   square(1:size(accu{i},1), 1:size(accu{i},2)) = accu{i};
   
   accu{i} = square + square'; % the matrix need to be symmetric
   
   [s1, s2] = find(triu(accu{i}) > 0); % find all pairs
   p1 = [p1; s1];
   p2 = [p2; s2];
end

% [p1, p2] = find(triu(accu) > 0); % find all pairs
tmp = accumarray([p1, p2], ones(numel(p1),1));
square = zeros(sp_num, sp_num);
square(1:size(tmp,1), 1:size(tmp,2)) = tmp;
square = square + square';
[p1, p2] = find( square > 0); % find all pairs

seg_val = zeros(sp_num,feat_dim);
vec_f = reshape(f_maps,[],feat_dim);
for i = 1:sp_num
    seg_val(i,:) = mean(mean(vec_f(segs==i,:),1),1); % pay attention here that how to compute the mean
end

% F = [seg_val(p1,:) seg_val(p2,:); seg_val(p2,:) seg_val(p1,:)]; % make pair symmetric, is that necessary?
F = [seg_val(p1,:) seg_val(p2,:)];

extra.F_unary = [seg_val(p1,:); seg_val(p2,:)];

extra.ii = p1;
extra.jj = p2;
extra.sp_num = sp_num;

end
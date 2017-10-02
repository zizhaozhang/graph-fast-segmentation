function [baseRegions, nBaseRegions, Tree, V, pwStrength] = build_pylon(ucm, opts)
% build tree structure based on ucm
% outputs:
%   - baseRegion: superpixel map with filled edges
%   - nBaseRegions: # of regions in superpixel map
%   - Tree: tree structure
%   - V: pairwise term of energy function
%   - pwStrength: exponential pairwise edge strength
% see pylon model paper for more details
%%
regions = bwlabel(ucm==0,4);
edges = find(ucm > 0);
[edgeI edgeJ] = ind2sub(size(ucm),edges);
edgeStrength = ucm(edges);

regions = padarray(regions,[1 1]);
edges = sub2ind(size(regions), edgeI+1, edgeJ+1); %reflect the padding

neighbors4 = [regions(edges-1) regions(edges+1) regions(edges+size(regions,1)) regions(edges-size(regions,1))];
neighbors8 = [neighbors4 ...
    regions(edges-1-size(regions,1)) regions(edges+1-size(regions,1)) ...
    regions(edges-1+size(regions,1)) regions(edges+1+size(regions,1))];

neighbors4 = neighbors4';
neighbors8 = neighbors8';

nRegions = max(regions(:));

bLength4 = zeros(nRegions);
bLength8 = zeros(nRegions);
bStrength = zeros(nRegions);

for i = 1:size(neighbors8,2)
    t = unique(neighbors8(:,i));
    bLength8(t(2:end),t(2:end))=bLength8(t(2:end),t(2:end))+1; %begin from 2 is to remove background 8
    t = unique(neighbors4(:,i));
    bLength4(t(2:end),t(2:end))=bLength4(t(2:end),t(2:end))+1;   
end

bLength8(bLength8==1) = 0; %removing "accross corner" neighbors 
bLength = (bLength4+bLength8)*0.5; %reasonable approximation to the Euclidean length

bLength = bLength-diag(diag(bLength));

[nbr1 nbr2] = ind2sub(size(bLength),find(bLength));
t = find(nbr1 > nbr2);
nbr1(t) = [];
nbr2(t) = [];

where8 = cell(nRegions,1);

for i = 1:nRegions
    where8{i} = find(any(neighbors8 == i));
end

for i = 1:numel(nbr1)
    bStrength(nbr1(i),nbr2(i)) = median(edgeStrength(intersect(where8{nbr1(i)},where8{nbr2(i)})));
end
bStrength = max(bStrength,bStrength');

%filling in edge pixels
el = strel('diamond',1); 
for i = 1:2
   tmp = imdilate(regions,el);
   regions(regions == 0) = tmp(regions == 0);
end

bStrength(bStrength == 0) = +inf;
bStrength(sub2ind(size(bStrength),1:size(bStrength,1),1:size(bStrength,1))) = 0;

Tree = linkage(squareform(bStrength));
baseRegions = regions(2:end-1,2:end-1);
nBaseRegions = nRegions;

[i j s] = find(bLength);
where = i >= j;
i(where) = [];
j(where) = [];
s(where) = [];
t = bStrength(sub2ind(size(bStrength), i, j));
% V = [i j s.*exp(-t/10) s.*exp(-t/40) s.*exp(-t/100) ones(size(t))]';
% V = [i j s.*exp(-t/0.1)*30]';

V = [i j s.*exp(-t/50)*30]';
% V = [i j s.*exp(-t/.1)*10]'; % this results is fine for many images

%V(3, t > 0.85*max(t(:)))  = min(V(3,:));
% V(3, t < 0.25*max(t(:)))  = max(V(3,:));
pwStrength = exp(-bStrength/opts.pwstrength_sigma);
% pwStrength = (pwStrength - min(pwStrength(:))) / (max(pwStrength(:)) - min(pwStrength(:)));
end
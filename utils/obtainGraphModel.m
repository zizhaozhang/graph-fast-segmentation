function Graphmodel = obtainGraphModel(img, opts)

%% get superpixels
sp = getSp(img, 256);
initEdgeStrength = mat2gray(sp); % val control the amount of superpixels
% segments = fillGap_sp(segments, img);

%% build pylon tree
[segments, nBaseRegions, Tree, pairWise, pairwiseStrength] = build_pylon2(im2uint8(initEdgeStrength), opts);
centers = zeros(nBaseRegions,2);
for i = 1:nBaseRegions, [y, x] = find(segments == i); centers(i,:) = [round(mean(y)), round(mean(x))];  end

Graphmodel.centers = centers;
Graphmodel.Tree = Tree;
Graphmodel.pairwise = pairWise;
Graphmodel.segments = segments;
Graphmodel.nBaseRegions = nBaseRegions;
Graphmodel.initEdgeStrength = initEdgeStrength;
% Graphmodel.pairwiseStrength = pairwiseStrength;

end
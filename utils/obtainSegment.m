function [E, saliencyMap, kMeansMap, kMeansMapSeg] = obtainSegment(img, EVD, Graphmodel, K)


segments = Graphmodel.segments;
initEdgeStrength = Graphmodel.initEdgeStrength;
pairwise = Graphmodel.pairwise;
nBaseRegions = Graphmodel.nBaseRegions;
Tree = Graphmodel.Tree;

%% saliency featres
% saliency_path = './images/saliency_maps/';
% [saliencyMap, saliencyVal_sp] = getSaliencyFeat(segments, imname, [size(img,1) size(img,2)], saliency_path);

%% kmeans: piror partitions
% centers = bsxfun(@rdivide, Graphmodel.centers, size(segments));
% normalized EVDx
for i = 1:size(EVD,2) EVD(:,i) = (EVD(:,i) - min(EVD(:,i))) / (max(EVD(:,i))-min(EVD(:,i))); end
% get features
% X = [EVD mean(saliencyVal_sp,2)*.9]; % !!! features for pylon model
X = [EVD]; % original
prm = {'nTrial',3,'metric','euclidean'} ;
[IDX, C] = kmeans2(X, K, prm);
kMeansMap = unMap(IDX, segments, 1, false); % remove for pascal
% convert kMeansMap to UCM maps
kMeansMapSeg = region2seg(kMeansMap);

%% using eigenHistogram
for i = 1:size(X,2) fhidx{i} = [i]; end %{[1],[2],[3],[4],[5]};
U = zeros(nBaseRegions*2-1, K);
% bin = 0:0.25:1;
bin = linspace(0, 1, K);
fLen = numel(bin)*size(X,2);
refV = zeros(K, fLen); % for each eigenmap generate a centeral value
for i = 1:K
    for j = 1:length(fhidx)
        refV(i,(j-1)*numel(bin)+1:j*numel(bin)) = getHist(X(IDX==i,fhidx{j}),bin);
    end
end
refV = bsxfun(@times,refV,1./(sum(refV,2)+eps)); % normalization
regionV = zeros(nBaseRegions*2-1, size(X,2));
for i = 1:nBaseRegions
   for j = 1:length(fhidx)
        regionV(i,(j-1)*numel(bin)+1:j*numel(bin)) = getHist(X(i,fhidx{j}),bin);
   end
end
count = zeros(size(U,1),1);
count(1:nBaseRegions) = 1;
for i = 1:size(Tree,1)
    regionV(nBaseRegions+i,:) = sum([regionV(Tree(i,1),:); regionV(Tree(i,2),:)],1);
    count(nBaseRegions+i) = count(Tree(i,1)) + count(Tree(i,2));
end
regionV = bsxfun(@times,regionV,1./(sum(regionV,2)+eps)); % normalization


%% multi-class segmentation
parmv = [200 300 400 500 600 800];
% parmv = [200 400 700];
accucm = zeros(size(initEdgeStrength));
% lasttmp = zeros(size(initEdgeStrength));
% deno = 0;
% parfor pp = 1:numel(parmv)
for pp = 1:numel(parmv)
    U = -regionV *refV'*parmv(pp);
    %% do pylon model
    %V = bsxfun(@times, V, [1; 1 ; 100]);
    xlabels_full = pylonInferenceMultiClass(nBaseRegions, Tree, U', pairwise);
    % flabels_full = pylonConvertLabels(xlabels_full, Tree, nBaseRegions);
    [~, tmp, ~] = label2segs2(xlabels_full, segments, initEdgeStrength, img);
%     if ~isempty(find(xor(lasttmp, tmp),1))
        accucm = accucm + tmp;
%         deno = deno + 1;
%         lasttmp = tmp;
%     end

%     figure(3),subplot(121),imshow(lasttmp),subplot(122),imshow(lasttmp);
%     figure(3),imshow(accucm);
%     figure(4), 
%     subplot(141), imshow(clust,[]); impixelinfo
%     subplot(142),imshow(saliencyMap,[]);
%     subplot(143),imshow(initEdgeStrength,[]);
%     subplot(144),imshow(labesegs,[]);
end
E = mat2gray((accucm+initEdgeStrength) ./ numel(parmv)); % denominator minus 1 
% E = mat2gray(accucm./numel(parmv) + initEdgeStrength); % this is not good

E = closeedgematch(E, initEdgeStrength);
  
% ucm2 = double(labsegs(:,:,1) == 0);
end
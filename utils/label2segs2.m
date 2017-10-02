function [vis_segs, edgeRes, augedgeRes] = label2segs2(xlabels, baseRegionMap, initedgeRestrength, img)
% input:
% - xlabels: predicated labels for each node in the tree
% - baseRegionsMap: superpixel image with filled gap
% - initRegions: superpixel image without filled-gap
% - original image
% output:
%   - vis_segs: segments have colored
%   - edgeRes: edge map 
%   - augedgeRes: generated from vis_segs with doubled image size
% Zizhao @ UF
%%

initRegions = baseRegionMap .* (double(initedgeRestrength==0)); % this is to leave the edge part, segments is totally filled

xlabels =[0 xlabels]; % making 1 is edges
pixelLabels = xlabels(initRegions+1);

% nClass = length(unique(pixelLabels));
% o_imsz = size(img); % original imsize

% initE = initRegions == 0;
[y, x] = find(initedgeRestrength); 
y = y + 1; x = x + 1;


% img = padarray(img, [1 1]);
pixelLabels = padarray(pixelLabels, [1 1],'replicate');
imsz = size(pixelLabels);
initedgeRestrength = padarray(initedgeRestrength, [1 1],'replicate');
% mask = zeros(size(edgeRestrength)); mask(2:end-1, 2:end-1) = 1;
% edgeRestrength = edgeRestrength * mask;

neighbor = getNeighbor(imsz, y, x, 8);
       
neighbor_labels= pixelLabels(neighbor(:,2:end));
edgeRes = zeros(imsz);
neighbor_labels = sort(neighbor_labels, 2);
[C,~,ic] = unique(neighbor_labels,'rows');
for i = 1:size(C)
   if length(unique(C(i,:)))> 2 % cross-section area
     idx = find(ic == i);
     idx = sub2ind(imsz, y(idx), x(idx));
     edgeRes(idx) = initedgeRestrength(idx);
%      edgeRes(idx) = 1;
   end
end
edgeRes = edgeRes(2:end-1,2:end-1);
vis_segs = []; augedgeRes = [];
% vis_segs = ucm2colorsegs(edgeRes,img,0);
% augedgeRes = double(vis_segs(:,:,1) == 0);
%% deprecated
% color = reshape(img,[],3);
% vis_segs = zeros(size(color));
% for i = 1:nClass
%     tmp = find(pixelLabels == i);
%     vis_segs(tmp,:) = repmat(mean(color(tmp,:),1), length(tmp),1);
% end
% vis_segs(idx,:) = 255;
% vis_segs = reshape(vis_segs,[imsz(1) imsz(2) 3]);
% 
% vis_segs = uint8(vis_segs(2:end-1,2:end-1,:));


% neighbor = [sub2ind(imsz, y, x)  ...
%              sub2ind(imsz, y+1, x)  ...
%              sub2ind(imsz, y-1, x)  ...
%              sub2ind(imsz, y, x-1)  ...
%              sub2ind(imsz, y, x+1)  ...
%              sub2ind(imsz, y-1, x-1) ...
%              sub2ind(imsz, y+1, x+1) ...
%              sub2ind(imsz, y-1, x+1) ...
%              sub2ind(imsz,  y+1, x-1)]; % eight different orientation
% neighbor = [sub2ind(imsz, y, x)  ...
%              sub2ind(imsz, y+1, x)  ...
%              sub2ind(imsz, y-1, x)  ...
%              sub2ind(imsz, y, x-1)  ...
%              sub2ind(imsz, y, x+1)]; % four different orientation
%          
% Indictor = pixelLabels(neighbor(:,2:end));
% Indictor = range(Indictor, 2) > 0; % 0 means not in the boundary of two segments
% 
% idx = neighbor(Indictor,1); % get original position of edge
% 
% edge = zeros(imsz);
% edge(idx) = 1;
% edge = edge(2:end-1,2:end-1); % go back to original size
% 
% 
% color = reshape(img,[],3);
% vis_segs = zeros(size(color));
% for i = 1:nClass
%     tmp = find(pixelLabels == i);
%     vis_segs(tmp,:) = repmat(mean(color(tmp,:),1), length(tmp),1);
% end
% vis_segs(idx,:) = 255;
% vis_segs = reshape(vis_segs,[imsz(1) imsz(2) 3]);
% 
% vis_segs = uint8(vis_segs(2:end-1,2:end-1,:));

end
function neighbor = getNeighbor(imsz, y, x, t)
% get neighbors index
if t == 4 % 4-connected
    neighbor = [sub2ind(imsz, y, x)  ...
             sub2ind(imsz, y+1, x)  ...
             sub2ind(imsz, y-1, x)  ...
             sub2ind(imsz, y, x-1)  ...
             sub2ind(imsz, y, x+1)]; % four different orientation
elseif t == 8 % 8-connected
    neighbor = [sub2ind(imsz, y, x)  ...
             sub2ind(imsz, y+1, x)  ...
             sub2ind(imsz, y-1, x)  ...
             sub2ind(imsz, y, x-1)  ...
             sub2ind(imsz, y, x+1)  ...
             sub2ind(imsz, y-1, x-1) ...
             sub2ind(imsz, y+1, x+1) ...
             sub2ind(imsz, y-1, x+1) ...
             sub2ind(imsz,  y+1, x-1)]; % eight different orientation  
end

end





















% 
% Rout = reshape(palette(pixelLabels,1),size(pixelLabels))*255;
% Gout = reshape(palette(pixelLabels,2),size(pixelLabels))*255;
% Bout = reshape(palette(pixelLabels,3),size(pixelLabels))*255;
% 
% %the tricky bit is to visualize region boundaries
% %
% regionLabels = -ones(size(Tree,1)+nBaseRegions,1);
% for i = size(Tree,1):-1:1
%   if xlabels(i+nBaseRegions) == 0
%       continue;
%   end
%   if regionLabels(i+nBaseRegions) == -1
%      regionLabels(i+nBaseRegions) = i+nBaseRegions;
%   end
%   regionLabels(Tree(i,1)) = regionLabels(i+nBaseRegions);
%   regionLabels(Tree(i,2)) = regionLabels(i+nBaseRegions);
% end
% for i = 1:nBaseRegions
%   if regionLabels(i) == -1
%       regionLabels(i) = i;
%   end
% end    
% Rout = Rout*0.9;
% Gout = Gout*0.9;
% Bout = Bout*0.9;
% regionMask = regionLabels(baseRegionMap);
% 
% pL = unique(regionLabels(:));    
% for i=1:numel(pL)
%     if pL(i) == -1
%         continue;
%     end
%     t = regionMask == pL(i);
%     t = t-imerode(t,strel('diamond',1));
%     Rout(t > 0) = 255;
%     Gout(t > 0) = 255;
%     Bout(t > 0) = 255;
% end    
% 
% outImage = uint8(cat(3,Rout,Gout,Bout));

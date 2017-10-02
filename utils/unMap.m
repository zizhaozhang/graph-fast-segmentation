function out = unMap(eigs, segments, num, ifnor)
% un-map value of superpixels to image pixles for visualization
% -eigs: eigen
% -segments: superpixel map
% -num: number of eigenvector to keep
% Zizhao
%%
if nargin < 4
    ifnor = true;
end

[N, K] = size(eigs);
[h,w,c] = size(segments);

out = zeros([h w min(size(eigs,2),num)]);
for s = 1:min(size(eigs,2),num)
    tmp = eigs(:,s);
    O = tmp(segments);
    
%     O = (O - min(O(:))) / (max(O(:)) - min(O(:)));
    if ifnor 
        out(:,:,s) = mat2gray(O);
    else
        out(:,:,s) = O;
    end
    
%    out(:,:,s) = medfilt2(out(:,:,s),[10 10]);
end

%for i = 1:
end
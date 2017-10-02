function D = geoDistance(center, imsz)
% obtrain geodestic distince for global-local eigenHistogram
% see paper for details
% Zizhao 
%%
N = size(center,1);

for i = 1:size(center,2) % y first and then x
    D1x = repmat(center(:,i), [1 N]);
    D1x = abs(D1x - D1x'); %D1x = |xi - xj|
    D2x = bsxfun(@minus, imsz(i), D1x); % D2x = W - |xi - xj|
    D{i} = min(cat(3,D1x,D2x),[],3);
end

D = sqrt((D{1}.^2 + D{2}.^2));

end
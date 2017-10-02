function [EV, keep] = selectEigenV(EV, thre, num)


keep = [];
%     out = unMap(EV, Graphmodel.segments, 6, 1); % eigenmap is normalized to 0-1
%     figure(1),montage2(out),title('selected eigenvectors');
N = size(EV,1);
for i = 1:size(EV,2)
    tmp = hist(EV(:,i));
    ratio = bsxfun(@rdivide, tmp, N);
    if isempty(find(ratio > thre,1)) 
        keep = [keep i];
        if numel(keep) == num break; end
    end
end
EV = EV(:,keep);

end
function h = getHist(data, BIN)

h = hist(data', BIN);
if size(h,1) ~= 1
    h = sum(h,1);
end
% h = bsxfun(@times, h, 1./(sum(h)+eps));

end
function sigma  = select_sigma(W)

maxw = max(W(:));
sq = sort(unique(W(:)));
minw = sq(2);

sigma = (maxw - minw) / (2*log(maxw/minw));

end
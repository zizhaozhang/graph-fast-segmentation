function seg = region2seg(region)

threholds = unique(region);
seg = zeros([size(region,1) size(region,2)]);
sz = (size(region)-1) / 2;
for t = 1:length(threholds)
    tmp_reg = region;
    tmp_reg(region <= threholds(t)) = 0;
    tmp_reg = imresize(tmp_reg, sz, 'nearest');
    bdry = seg2bdry(tmp_reg);    
    seg = max(seg, threholds(t)*bdry);
end
   seg = mat2gray(seg);
end
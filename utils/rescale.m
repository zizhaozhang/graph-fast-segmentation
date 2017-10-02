function new_data = rescale(data, ratio)

h  = sqrt(size(data(1,:),2));
w = sqrt(size(data(1,:),2));
new_h = round(h*ratio);
new_w = round(w*ratio);

new_data = zeros(size(data,1), new_h*new_w);
parfor i = 1:size(data,1)
   tmp = reshape(data(i,:), [h,w]);
   tmp = imresize(tmp, [new_h, new_w]);
   new_data(i,:) = tmp(:)';
    
end

end
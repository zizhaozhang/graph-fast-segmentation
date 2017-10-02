function segs = fillGap_sp(segs, img)
    % Zizhao 
    
%     img = rgb2gray(img);
    
    
    pad_img = imPad(im2single(img),[1 1],'symmetric');
    
    
    for i = 1:2 % two iterations to remove all edge points
        [y,x] = find(segs == 0);
        pad_segs = imPad(single(segs),[1 1],'symmetric');
        pos = [y+1 x+1]; % index to pad_segs positions
        orientations = {[1 0], [0 1],[-1 0],[0 -1]};
        pad_imsz = size(pad_img); pad_imsz = pad_imsz(1:2);
        im_rgb = reshape(pad_img, [], 3);
        dist = zeros(size(pos,1), length(orientations));
        out = pad_segs;
        for o = 1:length(orientations) % four different orientations

            neibor = bsxfun(@plus, pos,  orientations{o});
            c_idx = sub2ind(pad_imsz, pos(:,1), pos(:,2));
            neibor_idx = sub2ind(pad_imsz, neibor(:,1), neibor(:,2));
            tmp = sqrt(sum(im_rgb(c_idx,:)-im_rgb(neibor_idx,:).^2,2)); % color (rgb) distance of each point with its neighborhood

            tmp(pad_segs(neibor_idx)==0) = Inf; % if neighbor is also a edge, assign distance inf to avoid 0 distance
            dist(:,o) = tmp;

            if o > 1
                best = find(dist(:,o) < dist(:,o-1)); % only update those points with better distance
                out(c_idx(best)) = pad_segs(neibor_idx(best));
            else
                out(c_idx) = pad_segs(neibor_idx);  
            end
        end

        segs = out(2:end-1,2:end-1); % remove pad
    end
    
end

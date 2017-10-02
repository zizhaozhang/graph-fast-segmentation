function data = vis_eigimg(vis_true, EV_sp, centers_sp, img, keep)

vis_true = 4 * sign(vis_true) .* abs(vis_true).^0.5;
montage2(max(0, min(1, vis_true + 0.5))); colormap(betterjet); colorbar; title('true eigenvectors');
% impixelinfo

data = getframe;
data = data.cdata;

%% visualize data plot
% figure(2),
% % subplot(131), scatter3(feat{feature_type}(:,1),feat{feature_type}(:,2),feat{feature_type}(:,3),12,'+'), title('original');
% % subplot(132), scatter3(sp_centers(:,1),sp_centers(:,2),EV_my(:,1),12,'+'), title('new mapped');
% scatter3(centers_sp(:,2), centers_sp(:,1), EV_sp(:,1),12,'+'), title('nc mapped');
% 
% %% For fun, let's project the image into and out of the eigenvectors and
% % visualize it
% 
% if nargin < 3
%     keep = 1;
% end
% EV = reshape(vis_true(:,:,keep), [], numel(keep));
% 
% X = double(reshape(img, [], 3));
% mu = mean(X,1);
% Xc = bsxfun(@minus, X,   mu);
% im_eig = uint8(reshape(bsxfun(@plus, EV * (Xc' * EV)', mu), size(img)));
% % figure(3); imshow([img, im_eig],[]); axis image off;
% 



end
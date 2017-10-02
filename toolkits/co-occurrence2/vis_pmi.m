function [pmi] = vis_pmi(p, img, opts)

    
    [xx,yy] = meshgrid(0:0.01:1.05,0:0.01:1.05); yy = 1.05-yy;
    
    F_unary1 = xx(:); F_unary2 = yy(:);
    F = cat(2,F_unary1,F_unary2); % {A,B} pairs
    F_unary = cat(1,F_unary1,F_unary2); % A followed by B
    A_idx = 1:size(F_unary1,1); B_idx = (size(F_unary1,1)+1):2*size(F_unary1,1);

    
    [pmi,pJoint,pProd] = evalPMI(p,F,F_unary,A_idx,B_idx,opts);

    w1 = pJoint;
%     w2 = (pJoint.^1)./pProd; % this gives PMI_1
    w2 = pmi;
    w1 = reshape(w1,size(xx,1),size(xx,2));
    w2 = reshape(w2,size(xx,1),size(xx,2));
    
    
    subplot(131); imshow(img); title('input image');
    subplot(132); [~,ch] = contourf(xx,yy,(((w1)).^1),20); xlabel('Luminance A'); ylabel('Luminance B'); title('log P(A,B)'); axis('image'); colorbar; set(ch,'edgecolor','k');
    subplot(133); [~,ch] = contourf(xx,yy,(((w2)).^1),20); xlabel('Luminance A'); ylabel('Luminance B'); title('PMI_1(A,B)'); axis('image'); colorbar; set(ch,'edgecolor','k');
    colormap jet;

    pmi = w2;
end

% function [v] = evaluate_batches(p,F,tol)
%     
%     v = zeros(size(F,2),1);
%     n = 100000;
%     m = floor(size(F,2)/n);
%     end_i = 0;
%     eps = 10e-6;
%     for i=1:m
%         start_i = (i-1)*n+1;
%         end_i = start_i + n;
%         tmp = F(:,start_i:end_i);
%         tmp = tmp+eps*(rand(size(tmp))-0.5); % add a tiny bit of noise to make 'evaluate' 
%                                              % faster (not sure why this is necessary, but 
%                                              % evaluate is super slow when there are 
%                                              % lots of identical points)
%         v(start_i:end_i) = evaluate(p,tmp,tol);
%     end
%     tmp = F(:,end_i+1:end);
%     tmp = tmp+eps*(rand(size(tmp))-0.5);
%     v(end_i+1:end) = evaluate(p,tmp,tol);
% end
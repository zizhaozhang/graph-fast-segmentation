function [pmi,pJoint,pProd] = computePMI(estimator,F,F_unary,A_idx,B_idx,opts)


% pJoint = reg + evaluate_batches(estimator,F',0.001)/2;

pJoint = opts.reg + evaluate(estimator,F',opts.tol)';

% w1 = pJoint;
% w2 = (pJoint.^1)./pProd; % this gives PMI_1
% w1 = reshape(w1,size(xx,1),size(xx,2));
% pJoint = (pJoint - min(pJoint(:))) / (max(pJoint(:)) - min(pJoint(:)));

N = floor(size(F,2)/2); assert((round(N)-N)==0);
p2_1 = marginal(estimator,1:N);
p2_2 = marginal(estimator,N+1:(2*N));
p2 = joinTrees(p2_1,p2_2,0.5);
pMarg = zeros(size(F_unary,1),1);
ii = find(~isnan(F_unary(:,1))); % only evaluate where not nan (A_idx and B_idx will only refer to non-nan entries)
pMarg(ii) = evaluate(p2,F_unary(ii,:)',opts.tol);
pProd = pMarg(A_idx).*pMarg(B_idx)+opts.reg;

pmi = log((pJoint.^(opts.joint_exponent))./pProd);


end
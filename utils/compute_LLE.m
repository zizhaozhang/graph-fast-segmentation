function [Y, M] = compute_LLE(X, neighborhood)

[D,~] = size(X);
N = size(neighborhood,1);
K = max(sum(neighborhood,1));

if(K>D) 
  fprintf(1,'   [note: K>D; regularization will be used]\n'); 
  tol=1e-3; % regularlizer in case constrained fits are ill conditioned
else
%   tol = 0;
  tol= 1e-10; % to prevent ill-condition when neighbors take similar value
end

% W = zeros(K,N);
parfor ii=1:N
% for ii=1:N
   nei_idx = find(neighborhood(:,ii)==1);
%    t = imnoise(X(:,nei_idx),'gaussian'); % add noises to prevent sigularity
   t = X(:,nei_idx);
   z = t - repmat(X(:,ii),1,length(nei_idx)); % shift ith pt to origin
   C = z'*z;                                        % local covariance
   C = C + eye(numel(nei_idx),numel(nei_idx))*tol*trace(C);                   % regularlization (K>D)
   W{ii} = C\ones(numel(nei_idx),1);                           % solve Cw=1
   W{ii}= W{ii}/sum(W{ii});                  % enforce sum(w)=1
end


% STEP 3: COMPUTE EMBEDDING FROM EIGENVECTS OF COST MATRIX M=(I-W)'(I-W)
% fprintf(1,'-->Computing embedding.\n');

% M=eye(N,N); % use a sparse matrix with storage for 4KN nonzero elements
M = sparse(1:N,1:N,ones(1,N),N,N,4*K*N); 
for ii=1:N
   w = W{ii};
   jj = find(neighborhood(:,ii));
   M(ii,jj) = M(ii,jj) - w';
   M(jj,ii) = M(jj,ii) - w;
   M(jj,jj) = M(jj,jj) + w*w';
end
M(isnan(M)) = 0; % force remove nan, a little tricky here
Y = [];
% 
% d = 10;
% 
% % CALCULATION OF EMBEDDING
% options.disp = 0; options.isreal = 1; options.issym = 1; 
% [Y,eigenvals] = eigs(M,d+1,0,options);
% Y = Y(:,2:d+1)'*sqrt(N); % bottom evect is [1,1,1,1...] with eval 0
% Y = Y';
% fprintf(1,'Done.\n');


end
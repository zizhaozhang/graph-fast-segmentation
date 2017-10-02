%% function [W] = buildW_pmi(f_maps,rf,p,opts,samples)
% builds an affinity matrix W for image im based on PMI
% 
% INPUTS
%  f_maps   - NxMxF array of F feature maps for an NxM image
%  rf       - the learned random forest for approximating PMI (unused if ~opts.approximate_PMI)
%  p        - P(A,B) (unused if opts.approximate_PMI)
%  opts     - parameter settings (see setEnvironment)
%  samples   - either the number of samples from the full affinity matrix to
%               compute, or the indices of the full affinity matrix to compute, or empty,
%               in which case the full affinity matrix is computed
%
% OUTPUTS
%  W - affinity matrix
%
% -------------------------------------------------------------------------
% Crisp Boundaries Toolbox
% Phillip Isola, 2014 [phillpi@mit.edu]
% Please email me if you find bugs, or have suggestions or questions
% -------------------------------------------------------------------------

function [W, pmi] = buildW_pmi_sp(f_maps, sp_map, p, rf, opts)
    
%     if (~exist('samples','var'))
%         samples = [];
%     end
    
%     im_size = size(f_maps(:,:,1));
    
    %% get local pixel pairs
%     if (isempty(samples) || size(samples,2)==1)
%         [ii,jj] = getLocalPairs(im_size,[],[],samples);
%     else
%         ii = samples(:,1);
%         jj = samples(:,2);
%     end
    [F, forpmi_eval] = sampleF_dist(sp_map, f_maps, opts.radius_prediction, opts);
    
    %% initialize affinity matrix
%     Npixels = double(forpmi_eval.sp_num*forpmi_eval.sp_num);
    Nsp = double(forpmi_eval.sp_num);
    W = sparse(double(forpmi_eval.ii), double(forpmi_eval.jj), 0, Nsp, Nsp);
    
    %% extract features F
%     [F,F_unary] = extractF(f_maps,ii,jj,opts);
    
    %% evaluate affinities
    if (opts.approximate_PMI)
        pmi = fastRFreg_predict(F,rf);
    else
        pmi = evalPMI(p,F,forpmi_eval.F_unary,forpmi_eval.ii,forpmi_eval.jj,opts);   
    end
    
    w = exp(pmi/opts.sigma);
    W2 = sparse(double(forpmi_eval.ii),double(forpmi_eval.jj),w,Nsp,Nsp);
    W = W+W2;
    W = (W+W'); % we only computed one half of the affinities, now assume they are symmetric
end
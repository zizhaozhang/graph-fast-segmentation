%% function [rf] = learnPMIPredictor(f_maps,p,opts)
% learns a random forest rf that approximates PMI_{\rho}(A,B)
% 
% INPUTS
%  f_maps   - NxMxF array of F feature maps for an NxM image
%  p        - model for P(A,B) (Eqn. 1 in paper)
%  opts     - parameter settings (see setEnvironment)
%
% OUTPUTS
%  rf       - random forest that approximates PMI_{\rho}(A,B)
%
% -------------------------------------------------------------------------
% Crisp Boundaries Toolbox
% Phillip Isola, 2014 [phillpi@mit.edu]
% Please email me if you find bugs, or have suggestions or questions
% -------------------------------------------------------------------------

% function [rf] = learnPMIPredictor(f_maps,p,opts)
function [rf, pmi] = learnPMIPredictor(f_maps_curr, sp_map, forpmi, p, opts)

    
    %%
%     Nsamples = opts.PMI_predictor.Nsamples_learning_PMI_predictor;
%     im_size = size(f_maps(:,:,1));
    if isfield(opts,'radius_pmi');
        [F, forpmi] = sampleF_dist(sp_map, f_maps_curr, opts.radius_pmi, opts);
    end

    %% get all local pairs
%     [ii,jj] = getLocalPairs(im_size,[],[],Nsamples);
    %% extract features
%     [F,F_unary] = extractF(f_maps,ii,jj,opts);
    
    
    %% evaluate affinities
    pmi = evalPMI(p,forpmi.F,forpmi.F_unary,forpmi.ii,forpmi.jj,opts);
    
    %% learn PMI predictor: g(F) --> PMI
    Ntrees = opts.PMI_predictor.Ntrees;
    rf = fastRFreg_train(forpmi.F,pmi,Ntrees);
end
%% function [p, samples] = learnP_A_B(f_maps,opts)
% learns a model p for P(A,B) based on image statistics computed over f_maps
% 
% INPUTS
%  f_maps     - NxMxF array of F feature maps for an NxM image
%  opts       - parameter settings (see setEnvironment)
%
% OUTPUTS
%  p        - model for P(A,B) (Eqn. 1 in paper)
%
% -------------------------------------------------------------------------
% Crisp Boundaries Toolbox
% Phillip Isola, 2014 [phillpi@mit.edu]
% Please email me if you find bugs, or have suggestions or questions
% -------------------------------------------------------------------------

function [p, extra] = learnP_A_B_sp(f_maps_curr,sp_map, opts)
    
    if (strcmp(opts.model_type,'kde'))
        
        %% sample feature pairs {A,B}
%         Nsamples = opts.kde.Nkernels;
        
       
        
%         Nsamples_val = 500;
%         F_val = sampleF(f_maps, opts); % no need to validate, use all of
%         them
        [F, extra] = sampleF_dist(sp_map, f_maps_curr, opts.radius_pab, opts);
        
        %% fit model
        if (~opts.kde.learn_bw)
            p = kde(F',0.05,[],'e');
        else
            F_val = sampleF_dist(sp_map, f_maps_curr, opts.radius_pab_val, opts);
            p = kde(F','lcv',[],'e');

            %f = @(bw,p) nLOO_LL_anis(bw,p);
            f = @(bw,p,F_val) nLOO_LL_anis(bw,p,F_val);
            fminsearch_opts.Display = 'off';%'iter';
            fminsearch_opts.MaxIter = 20;

            reg_min = opts.kde.min_bw; % this regularizes for things like perceptual discriminability, that do not show up in the likelihood fit
                                       %  reduces the impact of
                                       %  outlier channels and noise
            reg_max = opts.kde.max_bw;
            
            for i=1:2 % for some reason repeatedly running fminsearch continues to improve the objective
                bw = getBW(p,1);
                bw_star = fminsearch(@(bw) f(bw,p,F_val), bw(1:size(bw,1)/2), fminsearch_opts);
                bw_star = cat(1,bw_star,bw_star);
                adjustBW(p,min(max(bw_star,reg_min),reg_max));
            end
        end
    else
        error('unrecognized model type');
    end
end

function [H] = nLOO_LL_anis(bw,p,F_val)
    bw = cat(1,bw,bw);
    adjustBW(p,bw);
    H = -evalAvgLogL(p,F_val');
end
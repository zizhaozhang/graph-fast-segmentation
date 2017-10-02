%% function [Ws,im_sizes] = getW(I,opts)
% builds affinity matrices Ws for image I
% 
% INPUTS
%  I          - NxMxC query image
%  opts       - parameter settings (see setEnvironment)
%
% OUTPUTS
%  Ws         - affinity matrices; Ws{i} is the affinity matrix for the image at scale i
%  im_sizes   - im_sizes{i} gives the dimensions of the image at scale i
%               (note: dimensions are num cols x num rows; this is the
%                opposite of matlab's default!)
%
% -------------------------------------------------------------------------
% Crisp Boundaries Toolbox
% Phillip Isola, 2014 [phillpi@mit.edu]
% Please email me if you find bugs, or have suggestions or questions
% -------------------------------------------------------------------------

function [Ws,im_sizes, f_maps] = getW_sp(I, sp_map, opts)
    
    %%
    Ws = [];
    Ws_each_feature_set = [];
    im_sizes = [];
    num_scales = opts.num_scales;
    scale_offset = opts.scale_offset; 
    
    %%
    for s= 1:num_scales % !!!!!!!!!!!!!!!!!!!!!!!!!!
        if (opts.display_progress), fprintf('\n\nProcessing scale %d:\n',s+scale_offset); end
        
        f_maps = [];
        for i=1:length(opts.features.which_features)
            f_maps{i} = getFeatures(double(I)/255,s+scale_offset,opts.features.which_features{i},opts);
        end    
        
%         if s ~= 1 % recompute super
%             ss = 2^(-(s-1));
% %             sp_map = imresize(sp_map,ss,'nearest');
%             sp_map = spresize(sp_map,ss);
%             opts.radius_pmi = opts.radius_pmi * ss;
%             opts.radius_prediction = opts.radius_prediction * ss;
%             opts.radius_pab = opts.radius_pab * ss;
%         end
            
        %%
        for feature_set_iter=1:length(f_maps)
            if (opts.display_progress), fprintf('\nProcessing feature type ''%s'':\n',opts.features.which_features{feature_set_iter}); end
        
            scale = 2^(-(s-1+scale_offset));
            
            f_maps_curr = f_maps{feature_set_iter};
            im_sizes{num_scales-s+1} = [size(f_maps_curr,2),size(f_maps_curr,1)];
            
            if ((s==1) || ~opts.only_learn_on_first_scale) % only learn models from first scale (and assume scale invariance)
                %% learn probability model
                if (opts.display_progress), fprintf('learning image model...'); tic; end
                
         
                [opts.centers, opts.seg_val, opts.D, opts.borderdis] = compute_sp_mapping_info(sp_map,f_maps_curr); % recompute for each scale
                
%                 [ii,jj] = find(any(isnan(opts.seg_val),2));
%                 if ~isempty(ii)
%                         disp('bugs in resize superpixe map');
%                         opts.seg_val(ii,:) = seg_val_last{feature_set_iter}(ii,:);
%                 end
%                 seg_val_last{feature_set_iter} = opts.seg_val;
                
%                 opts.centers = centers; opts.D = D; opts.seg_val = seg_val; opts.borderdis = borderdis;
                
                [p, forpmi] = learnP_A_B_sp(f_maps_curr, sp_map, opts);
                
                if (opts.display_progress), t = toc; fprintf('done: %1.2f sec\n', t); end
%                 %% learn w predictor
                if (opts.approximate_PMI)
                    if (opts.display_progress), fprintf('learning PMI predictor...'); tic; end
                    [rf, pmi] = learnPMIPredictor(f_maps_curr, sp_map, forpmi, p, opts);
                    if (opts.display_progress), t = toc; fprintf('done: %1.2f sec\n', t); end
                else
                    rf = [];
                end
            end
            
            %% build affinity matrix
            if (opts.display_progress), fprintf('building affinity matrix...'); tic; end
            if (strcmp(opts.model_type,'kde'))
                [Ws_each_feature_set{s}{feature_set_iter}, pmi_pre] = buildW_pmi_sp(f_maps_curr, sp_map, p, rf, opts);
            else
                error('unrecognized model type');
            end
            if (opts.display_progress), t = toc; fprintf('done: %1.2f sec\n', t); end
            
            %%
            if (feature_set_iter==1)
                Ws{s} = Ws_each_feature_set{s}{feature_set_iter};
            else
                Ws{s} = Ws{s}.*Ws_each_feature_set{s}{feature_set_iter};
            end
            
        end
    end    

end


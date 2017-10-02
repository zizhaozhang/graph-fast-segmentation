%% function [opts] = setEnvironment(type)
% set parameter options
% 
% INPUTS
%  type - specifies which parameter set to use 
%          e.g., can take on values 'speedy' or 'accurate' 
%          feel free to define your custom types at end of this function
%
% OUTPUTS
%  opts - selected parameters
% 
% -------------------------------------------------------------------------
% Crisp Boundaries Toolbox
% Phillip Isola, 2014 [phillpi@mit.edu]
% Please email me if you find bugs, or have suggestions or questions
% -------------------------------------------------------------------------

function [opts] = setEnvironment()
        
    %% for Multi-class segmentatioon
    % kmeans
    opts.kmeans_K = 11; % 6 is close to best.
    % samping superpixel pair
    opts.samping_weighting = false;
    opts.sampling_ratio = 0.3;
    
    %% for E_global term
    opts.withlle = true;
    opts.mulle = 14; % the best
    opts.NUM_OF_NEIGHBOR = 14; % used for LLE to determinate local neighboor # 10 is good enough
    
    opts.NVEC = 6; % number of eigenvector computed 
    opts.max_eig_dim = 3; % number of eigenvector used for computing eigenHistogram
    opts.if_select_eigs = false;
    opts.eigen_ratio_thre = 0.9;
    
    % build pylon mode
    opts.pwstrength_sigma = 5;
    % Affinity sigma
    opts.sigma = .9;

    
    %% for E_local 
    % sp radius
    opts.radius_pmi = 30;
    opts.radius_prediction = 40;
    opts.radius_pab = 20;
    opts.radius_pab_val = 20;
    %% scales                                                   used throughout code:
    opts.num_scales = 1;                                        % how many image scales to measure affinity over
                                                                %  each subsequent scale is half the size of the one before (in both dimensions)
                                                                %  if opts.num_scales>1, then the method of Maire & Yu 2013 is used for globalization (going from affinty to boundaries);
                                                                %  otherwise regular spectral clustering is used
    opts.scale_offset = 0;                                      % if opts.scale_offset==n then the first n image scales are skipped (first scales are highest resolution)
    
    
    %% features                                                 used in getFeatures.m:
    opts.features.which_features = {'color','var'};             % which features to use?
    opts.features.decorrelate = 0;                              % decorrelate feature channels (done separately for each feature type in which_features)?
    
    
    
    %% model and learning for PMI_{\rho}(A,B)                   used in learnP_A_B.m and buildW_pmi.m:
    opts.model_type = 'kde';                                    % what type of density estimate? (kde refers to kernel density estimation, which is the only method currently supported)
    opts.joint_exponent = 1.25;                                 % exponent \rho for PMI_{\rho} (Eqn. 2 in the paper)
    opts.p_reg = 100;                                           % regularization added to numerator and demoninator of PMI calculation
    
    % kde options
%     opts.kde.Nkernels = 10000;                                  % how many kernels for kde
    opts.kde.kdtree_tol = 0.001;                                % controls how exact is the kde evaluation (kde uses a kdtree to speed it up)
    opts.kde.learn_bw = false;                                  % adapt the bandwidth of the kde kernels to each test image?
    opts.kde.min_bw = 0.01; opts.kde.max_bw = 0.1;              % min and max bandwidths allowed when adapating bandwidth to test image
    
    opts.model_half_space_only = true;                          % when true we model only half the joint {A,B} space and assume symmetry
    
    % options for Eqn. 1 in paper
    opts.sig = 0.25;                                            % variance in pixels on Gaussian weighting function w(d) (see Eqn. 1 in paper)

    % speed up options
    opts.only_learn_on_first_scale = false;                     % setting this to true makes it so kde bandwidths and Affinity predictor are only 
                                                                %  learned on first scale (highest resolution) and assumed to be the same on lower 
                                                                %  resolution scales
                                                                %  (this often works well since image statistics are largely scale invariant)
    
                                                            
    %% approximate PMI with a random forest?                    used in learnPMIpredictor:                                
    opts.approximate_PMI = true;                                % approximate W with a random forest?
    opts.PMI_predictor.Ntrees = 4;                              % how many trees in the random forest
    
    %% other options
    opts.display_progress = false;                           % set to false if you want to suppress all progress printouts
    
    

end
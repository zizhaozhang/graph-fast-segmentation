addpath('./src');
global fucname;

%% path
%semicontour
modelpath = './semicontour_modules/models_sparse_retrain_3_V2/';
fucname = 'edgesDetect_retrain';
global ltmodel;
ltmodel = load('./semicontour_modules/5V2/forest/modelBsds.mat');
ltmodel.model.opts.sharpen = 2;
ltmodel.model.opts.multiscale = 1;
ltmodel.model.opts.nms = 0;
% load model
load([modelpath 'forest/modelBsds.mat']);

model.opts.multiscale=0;          % for top accuracy set multiscale=1
model.opts.sharpen=2;             % for top speed set sharpen=0
model.opts.nTreesEval=8;          % for top speed set nTreesEval=1
model.opts.nThreads=6;            % max number threads for evaluation
model.opts.nms=0;                 % set to true to enable nms


impath = 'E:\natural_image_data\BSR\BSDS500\data\images\test\';
writepath = 'E:\Dropbox\Project\global-local\semicontour_sp';
lis = dir([impath '*.jpg']);

opts = spDetect;
opts.nThreads = 4;  % number of computation threads
opts.k = 256;       % controls scale of superpixels (big k -> big sp)
opts.alpha = .9;    % relative importance of regularity versus data terms
opts.beta = .9;     % relative importance of edge versus color terms
opts.merge = 0.000;     % set to small value to merge nearby superpixels at end

for i = 1:length(lis)
    I = imread(fullfile(impath, lis(i).name));
    [E,~,~,segs]=edgesDetect_retrain(I,model);
    [S,V] = spDetect(I,E,opts); 
    [A,E,U]=spAffinities(S,E,segs,opts.nThreads);
    ucms = U;
    save(['E:\Dropbox\Project\global-local\bsds_semicontour_results\' lis(i).name(1:end-4) '.mat'], 'ucms');
end

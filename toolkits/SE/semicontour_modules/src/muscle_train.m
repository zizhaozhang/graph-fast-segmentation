% Demo for Structured Edge Detector (please see readme.txt first).

%% set opts for training (see edgesTrain.m)
% opts=edgesTrain();                % default options (good settings)
opts.modelDir='models/';          % model will be in models/forest
opts.modelFnm='modelBsds';        % model name
opts.nPos=2*5e5; opts.nNeg=2*5e5;     % decrease to speedup training
opts.useParfor=0;                 % parallelize if sufficient memory
opts.nTrees = 8;
%% train edge detector (~20m/8Gb per tree, proportional to nPos/nNeg)
tic, model=edgesTrain_muscle(opts); toc; % will load model if already trained

%% set detection parameters (can set after training)
model.opts.multiscale=0;          % for top accuracy set multiscale=1
model.opts.sharpen=0;             % for top speed set sharpen=0
model.opts.nTreesEval=8;          % for top speed set nTreesEval=1
model.opts.nThreads=4;            % max number threads for evaluation
model.opts.nms=1;                 % set to true to enable nms

%% evaluate edge detector on BSDS500 (see edgesEval.m)
if(0), edgesEval(model, 'show',1, 'name','' ); end
%% detect edge and visualize results
I = imread('C:\Users\zizhaozhang\Desktop\MATLAB\Projects\cell_data\large_train_SRF\images\train\946 Lgast L1-2.jpg');
I = imresize(I,2);
tic, [E,O,inds,segs] = edgesDetect(I,model); toc
figure(1); im(I); figure; im(E);

% Demo for Structured Edge Detector (please see readme.txt first).

%% set opts for training (see edgesTrain.m)
opts=edgesTrain();                % default options (good settings)
opts.modelDir='models/';          % model will be in models/forest
opts.modelFnm='modelBsds';        % model name
opts.nPos=5e5; opts.nNeg=5e5;     % decrease to speedup training
opts.useParfor=0;                 % parallelize if sufficient memory

%% train edge detector (~20m/8Gb per tree, proportional to nPos/nNeg)
tic, model=edgesTrain(opts); toc; % will load model if already trained

%% set detection parameters (can set after training)
model.opts.multiscale=0;          % for top accuracy set multiscale=1
model.opts.sharpen=2;             % for top speed set sharpen=0
model.opts.nTreesEval=4;          % for top speed set nTreesEval=1
model.opts.nThreads=4;            % max number threads for evaluation
model.opts.nms=0;                 % set to true to enable nms

%% evaluate edge detector on BSDS500 (see edgesEval.m)
if(0), edgesEval(model, 'show',1, 'name','' ); end

%% detect edge and visualize results
I = imread('peppers.png');
tic, E=edgesDetect(I,model); toc
figure(1); im(I); 
figure(2); im(1-E);

root = 'E:\natural_image_data\BSR\BSDS500\data\images\test\';
file_list = dir([root '*.jpg']);

model.opts.nms=-1; model.opts.nThreads=4;
model.opts.multiscale=0; model.opts.sharpen=2;

%% set up opts for spDetect (see spDetect.m)
opts = spDetect;
opts.nThreads = 4;  % number of computation threads
opts.k = 256;       % controls scale of superpixels (big k -> big sp)
opts.alpha = .9;    % relative importance of regularity versus data terms
opts.beta = .9;     % relative importance of edge versus color terms
opts.merge = 0.000;     % set to small value to merge nearby superpixels at end
for i = 1:length(file_list)
   img = imread([root file_list(i).name]);
   [E,~,~,segs]=edgesDetect(img,model);
   [S,V] = spDetect(img,E,opts); 
   [A,E,U]=spAffinities(S,E,segs,opts.nThreads);
%    imwrite(1-E, ['G:\edge_test\SE\' file_list(i).name(1:end-4) '.png']);
   ucm = U;
   assert(size(ucm,1) == size(img,1) & size(ucm,2) == size(img,2))
   save(['../../../SEucm/' file_list(i).name(1:end-4) '.mat'], 'ucm');
end

evaluate_BSDS500('../../../SEucm/')

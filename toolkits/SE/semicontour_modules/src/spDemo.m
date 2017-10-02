% Demo for Sticky Superpixels (please see readme.txt first).

%% load pre-trained edge detection model and set opts (see edgesDemo.m)
% model=load('models/forest/modelBsds'); model=model.model;
model.opts.nms=-1; model.opts.nThreads=4;
model.opts.multiscale=0; model.opts.sharpen=2;

%% set up opts for spDetect (see spDetect.m)
opts = spDetect;
opts.nThreads = 4;  % number of computation threads
opts.k = 1024;       % controls scale of superpixels (big k -> big sp)
opts.alpha = .5;    % relative importance of regularity versus data terms
opts.beta = .9;     % relative importance of edge versus color terms
opts.merge = 0.1;     % set to small value to merge nearby superpixels at end

%% detect and display superpixels (see spDetect.m)
I = imread('peppers.png');
[E,~,~,segs]=edgesDetect(I,model);
% E = imread('C:\Users\zizhaozhang\Desktop\MATLAB\Projects\cell_data\new_training_samples\result_on_small\original\107_TAD_55_edge.bmp');
% E = im2single(E);
tic, [S,V] = spDetect(I,E,opts); toc
figure(1); im(I); figure(2); im(V);

%% compute ultrametric contour map from superpixels (see spAffinities.m)
tic, [A,E,U]=spAffinities(S,E,segs,opts.nThreads); toc
figure(3); im(U); 
figure(4), imshow(E); return
%% compute video superpixels reusing initialization from previous frame
Is=seqIo(which('peds30.seq'),'toImgs'); Vs=single(Is); opts.bounds=0; tic
for i=1:size(Is,4), I=Is(:,:,:,i); E=edgesDetect(I,model);
  [opts.seed,Vs(:,:,:,i)]=spDetect(I,E,opts); end; opts.seed=[]; toc
Vs=uint8(Vs*255); playMovie([Is Vs],15,-10,struct('hasChn',1))

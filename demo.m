
%% Setup
turnon_path(); 
opts = setEnvironment(); 

test_path = './images/';
imist = dir([test_path '*.jpg']);

ID = 2;
img = imread([test_path imist(ID).name]);

%% Main method
% Phase 1
Graphmodel =  obtainGraphModel(img, opts);
% Phase 2
[EV, EVal] = obtainEigs(img, Graphmodel.segments, Graphmodel.centers, opts);
% Phase 3
segmentation = obtainSegment(img, EV, Graphmodel, opts.kmeans_K);

visualization = ucm2colorsegs(segmentation,img,0.1); 

figure(1),
imshow(visualization)
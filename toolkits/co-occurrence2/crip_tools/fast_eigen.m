function [EigVect, EVal] = fast_eigen(W)

addpath('../fast_eigen');

args.A = W;
args.lambdaMin = 0.1;
args.dProj = 100;
Pts = FastEmbedEigPy(args);
EigVect = [];
EVal = [];
end
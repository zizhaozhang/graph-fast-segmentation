function evaluate_BSDS500(savepath, data_path, whichset)
    
    imgDir = fullfile([data_path '/images'], whichset);
    gtDir = fullfile([data_path '/groundTruth'], whichset);
    
    inDir = savepath;
    outDir = fullfile(savepath, 'eval');
    mkdir(outDir);

    MY_RegionBench(imgDir, gtDir, inDir, outDir);
    %MY_BoundaryBench(imgDir, gtDir, inDir, outDir, 99);

    ICG_Plot_eval(outDir);

end

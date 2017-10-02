function ICG_Plot_eval(evalDir,col)
% plot evaluation results.
% Pablo Arbelaez <arbelaez@eecs.berkeley.edu>

if nargin<2, col = 'r'; end

if iscell(evalDir)
    
    open('isoF.fig');
    warning off all;
    
    for i = 1:numel(evalDir)
        switch i
            case 1
                col = 'r';
            case 2
                col ='g';
            case 3
                col = 'm';
            case 4
                col = 'b';
        end
        cevalDir = evalDir{i};
        fwrite(2,sprintf('\n%s\n',cevalDir));
        if exist(fullfile(cevalDir,'eval_bdry_thr.txt'),'file'),

            hold on
            prvals = dlmread(fullfile(cevalDir,'eval_bdry_thr.txt')); % thresh,r,p,f
            f=find(prvals(:,2)>=0.01);
            prvals = prvals(f,:);


            evalRes = dlmread(fullfile(cevalDir,'eval_bdry.txt'));
            if size(prvals,1)>1,
                plot(prvals(1:end,2),prvals(1:end,3),col,'LineWidth',3);
            else
                plot(evalRes(2),evalRes(3),'o','MarkerFaceColor',col,'MarkerEdgeColor',col,'MarkerSize',8);
            end
            hold off

            fprintf('Boundary\n');
            fprintf('ODS: F( %1.4f, %1.4f ) = %1.4f   [th = %1.2f]\n',evalRes(2:4),evalRes(1));
            fprintf('OIS: F( %1.4f, %1.4f ) = %1.4f\n',evalRes(5:7));
            fprintf('Area_PR = %1.4f\n\n',evalRes(8));
        end

        if exist(fullfile(cevalDir,'eval_cover.txt'),'file'),
            evalRes = dlmread(fullfile(cevalDir,'eval_cover.txt'));
            fprintf('Region\n');
            fprintf('GT covering: ODS = %1.4f [th = %1.2f]. OIS = %1.4f. Best = %1.4f\n',evalRes(2),evalRes(1),evalRes(3:4));
            evalRes = dlmread(fullfile(cevalDir,'eval_RI_VOI.txt'));
            fprintf('Rand Index: ODS = %1.4f [th = %1.2f]. OIS = %1.4f.\n',evalRes(2),evalRes(1),evalRes(3));
            fprintf('Var. Info.: ODS = %1.4f [th = %1.2f]. OIS = %1.4f.\n',evalRes(5),evalRes(4),evalRes(6));

        end
    end
else
    fwrite(2,sprintf('\n%s\n',evalDir));
    warning off all;
    if exist(fullfile(evalDir,'eval_bdry_thr.txt'),'file'),
        open('isoF.fig');
        hold on
        prvals = dlmread(fullfile(evalDir,'eval_bdry_thr.txt')); % thresh,r,p,f
        f=find(prvals(:,2)>=0.01);
        prvals = prvals(f,:);


        evalRes = dlmread(fullfile(evalDir,'eval_bdry.txt'));
        if size(prvals,1)>1,
            plot(prvals(1:end,2),prvals(1:end,3),col,'LineWidth',3);
        else
            plot(evalRes(2),evalRes(3),'o','MarkerFaceColor',col,'MarkerEdgeColor',col,'MarkerSize',8);
        end
        hold off

        fprintf('Boundary\n');
        fprintf('ODS: F( %1.4f, %1.4f ) = %1.4f   [th = %1.2f]\n',evalRes(2:4),evalRes(1));
        fprintf('OIS: F( %1.4f, %1.4f ) = %1.4f\n',evalRes(5:7));
        fprintf('Area_PR = %1.4f\n\n',evalRes(8));
    end

    if exist(fullfile(evalDir,'eval_cover.txt'),'file'),
        evalRes = dlmread(fullfile(evalDir,'eval_cover.txt'));
        fprintf('Region\n');
        fprintf('GT covering: ODS = %1.4f [th = %1.2f]. OIS = %1.4f. Best = %1.4f\n',evalRes(2),evalRes(1),evalRes(3:4));
        evalRes = dlmread(fullfile(evalDir,'eval_RI_VOI.txt'));
        fprintf('Rand Index: ODS = %1.4f [th = %1.2f]. OIS = %1.4f.\n',evalRes(2),evalRes(1),evalRes(3));
        fprintf('Var. Info.: ODS = %1.4f [th = %1.2f]. OIS = %1.4f.\n',evalRes(5),evalRes(4),evalRes(6));

    end
end
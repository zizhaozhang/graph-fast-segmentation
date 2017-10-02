function target = closeedgematch(target, initE)

   lis = unique(initE);
   
   for i = 2:length(lis) % exclude 0
      idx = find(initE == lis(i));
      target(idx) = mean(target(idx));
   end
   target = mat2gray(target);
end
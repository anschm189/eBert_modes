%% Check Errors: Debugging function that loops through RBig, saving the largest error it finds
EMax = 0;
for i = 1:nDoF
    R = [RBig{i,1}(:,1:end-1),RBig{i,2},RBig{i,1}(:,end)];
    for j = 1:size(R,1)
        Error = norm(BC(R(j,1:end)'));
        EMax = Error*(Error>EMax) +EMax*(EMax>=Error);
    end
end
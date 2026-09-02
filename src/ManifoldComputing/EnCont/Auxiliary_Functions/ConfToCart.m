function [YCart] = ConfToCart(Y,nDoF)
%FKIN Converts modes in Y to form in cartesian coordinates, YCart 

%% Conversion
YCart = cell(nDoF,2);
for i = 1:nDoF                                                              % Loop through generators
    lY = size(Y{i,1},1);                                                    % Number of modes on i-th generator  
    YCart{i} = cell(lY,1);                                                  
    for j = 1:lY                                                            % Loop through energy levels
        lY_y = size(Y{i,1}{j},1);
        YCart{i}{j} = zeros(lY_y,nDoF*2);
        for k = 1:lY_y                                                      % Convert mode to Cartesian Coordinates
            YCart{i,1}{j}(k,:) = fKin(Y{i,1}{j}(k,1:nDoF));                 % k-th point on j-th mode of i-th generator, for all masses of pendulum
        end
        YCart{i,2}{j} = Y{i,3}{j};                                          % Time along j-th mode on i-th generator 
    end
end  

end

function [ costH1 , costH2 ] = CostFunc( userInput , goalSt )
%COSTFUNC Calculates Cost
%   Uses heuristcs to calculate the node costs to find the best node
    
    % how many tiles are in the wrong positions
%     userInput
%     goalSt
    
    costH1 = sum (sum (~(userInput == goalSt)));
    
    % how many moves for each tile to reach the right position
    
    costH2 = 0;
    
    for lineIn = 1:4
        for colIn = 1:4
            tileIn = userInput (lineIn , colIn);
            if tileIn > 0
                [lineGoal , colGoal] = find (goalSt == tileIn);
                costH2 = costH2 + abs(lineIn - lineGoal) + abs (colIn - colGoal);
            end
        end
    end
%      costH1
%      costH2
end


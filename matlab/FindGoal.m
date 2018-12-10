function [goal,goalSt] = FindGoal( userInput )
%FINDGOAL Find goal state
%   this function finds a goal state if the puzzle is solvable.
%   
    % userInput = [5,1,3,4;2,6,7,8;9,10,12,0;13,14,11,15];
    % counting the board
    uIn=userInput;
    
    vIn= reshape (userInput.', 1, 16);
    
    for r=1:16
        if vIn(r)==0
            vIn(r)=16;
        end
    end
        
    
    iNv=0;
    for i=2:16
        for j=1:(i-1)
            if vIn(i) < vIn(j)
                iNv=iNv+1;
            end
        end
    end
    
    for m=1:4
        for n=1:4
            if uIn(m,n)==0
                cEx=(4-m)+(4-n);
            end
        end
    end
    
    count=iNv+cEx;
%     disp(count);
    % the matrix is odd or even ?
    if mod(count,2)
        goal=0; %1 odd
        disp('The puzzle is not solvable');
        goalSt = [1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 0];
        return;
        %goalSt = userInput;
    else
         goal=1;
        goalSt = [1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 0]; %0 even
    end
end


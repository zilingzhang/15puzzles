function [goal,goalSt] = FindGoal( userInput )
%FINDGOAL Find goal state
%   this function finds a goal state if the puzzle is solvable.
%

    uIn=userInput;
    
    vIn= reshape (userInput.', 1, 16);
    
    for r=1:16
        if vIn(r)==0
            vIn(r)=16;
        end
    end
        
    count1=0;
    for i=2:16
        for j=1:(i-1)
            if vIn(i) < vIn(j)
                count1=count1+1;
            end
        end
    end
    
    % record the location of the empty space
    for m=1:4
        for n=1:4
            if uIn(m,n)==0
                count2=(4-m)+(4-n);
            end
        end
    end
    
    count=count1+count2;
                  
    % the matrix is odd or even ?
    if mod(count,2)
        goal=0; %1 odd
        disp('The puzzle is not solvable');
        goalSt = [1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 0];
        return;
    else
        goal=1; %0 even
        goalSt = [1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 0];
    end
end


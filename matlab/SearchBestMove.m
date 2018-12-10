function [  ] = SearchBestMove( userInput , goalSt )
%SEARCHBESTMOVE search the best move
%   Use heuristics to find next move

	S.node = userInput;
	S.costh1 = 0;
	S.costh2 = 0;
	S.depth = 0;
    S.nodeId = 0;
	S.parentId = 0;
	histList = S;
    openList = S;
    list = S;
	bestNodes = S;
	bestNodes(1).parentId = -1;
    lastOpen = 1;
	x = 0;
	nBest = 2;
	lastHist = 2;
    goalFound=0;
    id = 0;
	loops = 0;
    steps = 1;
    path = [];
	%tic;
	while ~goalFound && loops < 200000
%         histList(S.nodeId+1).node
%         S
		[h1 , h2] = CostFunc (S.node , goalSt);
        if (h1 & h2)
            %find child nodes
            [line, col] = find (S.node == 0);
            %slide left to right
            if col > 1
                x = x + 1;
                list(x).node = S.node;
                list(x).node (line,col) =  S.node (line, col-1);
                list(x).node (line , col-1) = 0;
                [h1 , h2] = CostFunc (list(x).node , goalSt);
                list(x).costh1 = h1;
                list(x).costh2 = h2 + S.depth + 1;
                list(x).depth = S.depth;
 				list(x).nodeId = 0;		%dummy
				list(x).parentId = S.nodeId;
            end
            %slide right to left    if col < 3
            if col < 4
                x = x + 1;
                list(x).node = S.node;
                list(x).node (line,col) =  S.node (line, col+1);
                list(x).node (line , col+1) = 0;
                [h1 , h2] = CostFunc (list(x).node , goalSt);
                list(x).costh1 = h1;
                list(x).costh2 = h2 + S.depth + 1;
                list(x).depth = S.depth;
 				list(x).nodeId = 0;	%dummy
				list(x).parentId = S.nodeId;	%dummy
            end
            %slide up to down
            if line > 1
                x = x + 1;
                list(x).node = S.node;
                list(x).node (line,col) = S.node (line-1, col);
                list(x).node (line-1,col) = 0;
                [h1 , h2] = CostFunc (list(x).node , goalSt);
                list(x).costh1 = h1;
                list(x).costh2 = h2 + S.depth + 1;
                list(x).depth = S.depth;
 				list(x).nodeId = 0;	%dummy
				list(x).parentId = S.nodeId;	%dummy
            end
            %slide down to up
            if line < 4
                x = x + 1;
                list(x).node = S.node;
                list(x).node (line,col) = S.node (line+1, col);
                list(x).node (line+1,col) = 0;
                [h1 , h2] = CostFunc (list(x).node , goalSt);
                list(x).costh1 = h1;
                list(x).costh2 = h2 + S.depth + 1;
                list(x).depth = S.depth;
 				list(x).nodeId = 0;	%dummy
				list(x).parentId = S.nodeId;	%dummy
			end
			
            %If the child node is in history, delete
            [~,y] = size(histList);
            temp = x;
            while y>0
                x = temp;
                while x>0
                    [~ , ~ , v] = find (histList(y).node == list(x).node);
                    if sum(v)==16
                        list(x) = [];
                        temp = temp-1;
                    end
                    x = x-1;
                end
                y = y-1;
            end
            
            %set node ID 
            [~,a] = size (list);
            t = 1;
			while t <= a
                id = id + 1;
                list(t).nodeId=id;
                t = t + 1;
			end
			
			[~,y] = size (list);
            %add child list to open list
            openList (1, lastOpen:lastOpen+y-1) = list;
            lastOpen = lastOpen+y;
            [~,y] = size (openList);
            %find smaller cost
            smallNode = y;
            while y > 1    
                if openList(smallNode).costh2 == openList(y-1).costh2 ...
                   && openList(smallNode).costh1 > openList(y-1).costh1
                    smallNode = y-1;
                elseif openList(smallNode).costh2 > openList(y-1).costh2
                    smallNode = y-1;
                end
                y = y-1;
            end

            %next State node
            S = openList(smallNode);
			S.depth = S.depth + 1;
            
            %include new child list in history list
            [~,y] = size (list);
            histList(1, lastHist:lastHist+y-1 ) = list;
            lastHist = lastHist+y;

            %include best node in closed list
            bestNodes(nBest) = openList(smallNode);
            nBest = nBest+1;
            list = [];
			
            %take off smaller from openList
            openList(smallNode) = [];
            lastOpen = lastOpen -1;
			loops = loops+1;
		else
			%toc
			% print sequence
            goalFound = 1;
			nBest = nBest - 1;
			curNode=bestNodes(nBest).node;
            curNode;
			parent = bestNodes(nBest).parentId;
            preNode = bestNodes(nBest).node;
			while parent >= 0
				v = [];
				while isempty(v) & (parent>=0)
					[~ , ~ , v] = find(bestNodes(nBest).nodeId == parent);
					nBest = nBest - 1; 
				end
				nBest = nBest + 1;
				curNode=bestNodes(nBest).node;
                curNode;
                [rowCur , colCur] = find (curNode == 0);
                [rowPre , colPre] = find (preNode == 0);
                if rowCur==rowPre && colCur-colPre ==1
                    path = [path; 'R'];
                elseif rowCur==rowPre && colPre-colCur ==1
                    path = [path; 'L'];
                elseif colCur==colPre && rowPre-rowCur ==1
                    path = [path; 'U'];
                elseif colCur==colPre && rowCur-rowPre ==1
                    path = [path; 'D'];
                end
				parent = bestNodes(nBest).parentId;
                preNode = bestNodes(nBest).node;
                steps=steps+1;
			end
			loops;
            steps;
            path
        end
    end   
end
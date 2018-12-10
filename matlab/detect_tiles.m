function [totalscore, detected_tiles] = detect_tiles(net,tiles)
    totalscore = 0;
    detected_tiles = zeros([1 16]);
    for i=1:16
        im = tiles(:,:,i);
    %    im = imrotate(im,-90); % TODO, implement auto-right-side-up
    %   figure, imshow(im,[]);
        % Filtering Noise
        im = imbinarize(im,150);
        %se = strel('rectangle',[2,2]);
        im = single(im)*255;
        % Regional Proposal
        [L,nBlobs] = bwlabel(im);
        blobs = regionprops(L);
        bigAreaCount = 0;
        bigAreaIndex = [];
        for j=1:nBlobs         
            if blobs(j).Area > 500 && blobs(j).Centroid(1)>10 && blobs(j).Centroid(1) <230 ...
                    && blobs(j).Centroid(2)>10 && blobs(j).Centroid(2) <230           
                bigAreaCount = bigAreaCount + 1;
                bigAreaIndex = [bigAreaIndex,j];
    %           rectangle('Position',blobs(j).BoundingBox,'EdgeColor','r');
            end
        end    
        if bigAreaCount == 1 % Single Digit
            % CNN digit detection
            im_ = imresize(im,[28 28]);
            res = vl_simplenn(net, gpuArray(im_));        
            scores = squeeze(gather(res(end).x)) ;
            [bestScore, best] = max(scores) ;
            best = best - 1;  % index shifting
            detected = str2num(net.meta.classes.name{best+1})-1;
            detected_tiles(1,i) = detected;
            totalscore = totalscore + bestScore;
    %       title(sprintf('The number is %.f, score %.1f%%',detected, bestScore * 100)) ;     
        elseif bigAreaCount == 2 % Double Digits
            left=zeros(1); right=zeros(1);
            if blobs(bigAreaIndex(1)).Centroid(1)< blobs(bigAreaIndex(2)).Centroid(2)
                left = bigAreaIndex(1);
                right = bigAreaIndex(2);
            else
                left = bigAreaIndex(2);
                right = bigAreaIndex(1);
            end
            leftdigit = imcrop(im,[blobs(left).Centroid(1)-60 blobs(left).Centroid(2)-60 119 119]);       
            leftdigit_ = imresize(leftdigit,[28 28]); 
          % figure,imshow(leftdigit_,[]);
            leftres = vl_simplenn(net, gpuArray(leftdigit_)) ;
            leftscores = squeeze(gather(leftres(end).x)) ;
            [leftbestScore, leftbest] = max(leftscores) ;    
            leftbest = leftbest - 1;
            leftdetected =  str2num(net.meta.classes.name{leftbest+1})-1;
            rightdigit = imcrop(im,[blobs(right).Centroid(1)-60 blobs(right).Centroid(2)-60 119 119]);        
            rightdigit_ = imresize(rightdigit,[28 28]);
          % figure,imshow(rightdigit_,[]);
            rightres = vl_simplenn(net, gpuArray(rightdigit_)) ;
            rightscores = squeeze(gather(rightres(end).x)) ;
            [rightbestScore, rightbest] = max(rightscores) ;    
            rightbest = rightbest - 1;
            rightdetected =  str2num(net.meta.classes.name{rightbest+1})-1;                        
    %       title(sprintf('%.f%.f detected, score %.1f%%',leftdetected,rightdetected, combineScore*100));
            detected_tiles(1,i) = 10 + rightdetected;
            if leftdetected == 1 
                totalscore = totalscore + rightbestScore;
            end
        else % empty tile
    %       title(sprintf('%.f detected, score %.1f%%',0, 100));
            detected_tiles(1,i) = 0;
            totalscore = totalscore +1;
        end
    %   drawnow;
    end
    detected_tiles = reshape(detected_tiles,[4 4])';
end
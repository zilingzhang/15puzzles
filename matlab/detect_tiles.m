function [totalscore, detected_tiles] = detect_tiles(net,tiles,gpu,verbose)
    totalscore = 0;
    detected_tiles = zeros([1 16]);
    for i=1:16
        %% Binarize
        im = tiles(:,:,i);    
        if verbose == 1
            figure, imshow(im,[]);
        end        
        im = imbinarize(im,150);
        im = single(im)*255;
        %% Regional Proposal
        [L,nBlobs] = bwlabel(im);
        blobs = regionprops(L);
        bigAreaCount = 0;
        bigAreaIndex = [];
        for j=1:nBlobs         
            if blobs(j).Area > 500 && blobs(j).Centroid(1)>10 && blobs(j).Centroid(1) <230 ...
                    && blobs(j).Centroid(2)>10 && blobs(j).Centroid(2) <230           
                bigAreaCount = bigAreaCount + 1;
                bigAreaIndex = [bigAreaIndex,j];
               if verbose == 1
                    rectangle('Position',blobs(j).BoundingBox,'EdgeColor','r');
               end
            end
        end
        %% Number Detection
        if bigAreaCount == 1 % Single Digit
            % CNN digit detection
            im_ = imresize(im,[28 28]);
            if gpu == 1
                im_ = gpuArray(im_);
            end
            res = vl_simplenn(net, im_);        
            scores = squeeze(gather(res(end).x)) ;
            [bestScore, best] = max(scores) ;
            best = best - 1;  % index shifting
            detected = str2num(net.meta.classes.name{best+1})-1;
            detected_tiles(1,i) = detected;
            totalscore = totalscore + bestScore;
            if verbose >= 1
                title(sprintf('The number is %.f, score %.1f%%',detected, bestScore * 100)) ;     
            end
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
            if verbose == 2
                figure,imshow(leftdigit_,[]);
            end
            if gpu == 1
                leftdigit_ = gpuArray(leftdigit_);
            end
            leftres = vl_simplenn(net, leftdigit_) ;
            leftscores = squeeze(gather(leftres(end).x)) ;
            [leftbestScore, leftbest] = max(leftscores) ;    
            leftbest = leftbest - 1;
            leftdetected =  str2num(net.meta.classes.name{leftbest+1})-1;
            rightdigit = imcrop(im,[blobs(right).Centroid(1)-60 blobs(right).Centroid(2)-60 119 119]);        
            rightdigit_ = imresize(rightdigit,[28 28]);
            if verbose == 2
                figure,imshow(rightdigit_,[]);
            end
            if gpu == 1
                rightdigit_ = gpuArray(rightdigit_);
            end
            rightres = vl_simplenn(net, rightdigit_) ;
            rightscores = squeeze(gather(rightres(end).x)) ;
            [rightbestScore, rightbest] = max(rightscores) ;    
            rightbest = rightbest - 1;
            rightdetected =  str2num(net.meta.classes.name{rightbest+1})-1;                        
            if verbose >= 1
                combineScore = (leftbestScore+rightbestScore)/2;
                title(sprintf('%.f%.f detected, score %.1f%%',leftdetected,rightdetected, combineScore*100));
            end
            detected_tiles(1,i) = 10 + rightdetected;
            if leftdetected == 1 
                totalscore = totalscore + rightbestScore;
            end
        else % empty tile
            if verbose >= 1
                title(sprintf('%.f detected, score %.1f%%',0, 100));
            end
            detected_tiles(1,i) = 0;
            totalscore = totalscore +1;
        end
        if verbose >=1
            drawnow;
        end
    end
    detected_tiles = reshape(detected_tiles,[4 4])';
end
function orthophoto = find_square(I)    
    I = rgb2gray(I);
    BW = imbinarize(I, graythresh(I));
    %imshow(BW,[]);
    BW = ~BW; % invert the image so we look for a white square

    % Find connected components
    % filtering noise
   %imshow(BW,[]);
    se = strel('rectangle',[10,10]);
    BW = imopen(BW,se);
 %  figure,imshow(BW,[]);
    
    [L,nBlobs] = bwlabel(BW);
    blobs = regionprops(L);

    % Look at the blobs and find the first one that looks like a square.
    fFoundSquare = false; % This will be set to true if a square is found
    for i=1:nBlobs
        if blobs(i).Area < 200000
        continue;
        end

        % Find a point on the boundary of this blob
        [rows,cols] = find(L==i);
        [r0,i0] = min(rows);
        c0 = cols(i0);

        % Get coordinates (row,col) along boundary
        pts = bwtraceboundary(BW, [r0 c0], 'N');

        N = size(pts,1); % Number of points along the boundary
        c = mean(pts); % Get centroid

        % Find the point furthest from centroid
        dp = pts - repmat(c,N,1);
        d = dp(:,1).^2 + dp(:,2).^2;
        [~,i1] = max(d); % Assume that this is a corner
        p1 = pts(i1,:);

        % Get vectors from the first corner to all other points
        r = pts - repmat(p1,N,1);

        % Find the point furthest from first corner
        d = r(:,1).^2 + r(:,2).^2;
        [~,i3] = max(d); % Assume that this is the opposite corner
        p3 = pts(i3,:);

        % Find the points that are the furthest from the line from i1 to i3.
        v = [p3(2)-p1(2); -(p3(1)-p1(1))]; % A vector perpendicular to that line

        % The signed distance from each point p to the line is just dot(v,r)
        d = v(1)*r(:,1) + v(2)*r(:,2);
        [~,i2] = max(d); % Point 2 is to the right of 1->3
        p2 = pts(i2,:);
        [~,i4] = min(d); % Point 3 is to the left of 1->3
        p4 = pts(i4,:);
        % So the order of point is 1,2,3,4 in counterclockwise order

        % Verify that this is a square - there are many ways to do this.
        % We will just check to see if the sides are all about the same length.
        s12 = norm(p1-p2);
        s23 = norm(p2-p3);
        s34 = norm(p3-p4);
        s41 = norm(p4-p1);
        smax = max([s12,s23,s34,s41]);
        sthresh = 0.7; % minimum ratio of lengths
        if (s12/smax > sthresh) && (s23/smax > sthresh) && ...
         (s34/smax > sthresh) && (s41/smax > sthresh)
         fFoundSquare = true;
         break;
        end
    end
    
    if fFoundSquare
       % imshow(I,[]);
        %draw
        points = [p1(2),p1(1);p2(2),p2(1);p3(2),p3(1);p4(2),p4(1)];
     %   patch('Faces',[1 2 3 4],'Vertices',points,'EdgeColor','green','FaceColor','none','LineWidth',2);
     %   drawnow;

        Pts2 = points;
        Pts1 = [960,960;960,0;0,0;0,960];
        tform = fitgeotrans(Pts2,Pts1,'projective');
        registered=imwarp(I,tform,'OutputView', imref2d([960 960]));
        orthophoto = registered;
        %imshow(octophoto);
    end
end

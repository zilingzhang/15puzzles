function tiles = slice_to_tiles(orthophoto)
    tiles = zeros(240,240,16,'single');
    for i=0:3
        for j = 0:3
            tile = imcrop(orthophoto,[1+j*240 1+i*240 239 239]);
            tiles(:,:,j+1+4*i)=tile;
       %     imshow(tiles(:,:,j+1+4*i),[]);
        end
    end   
end
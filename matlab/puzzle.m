clear variables;
close all;
tic()
run(fullfile('..','matconvnet-1.0-beta16', 'matlab', 'vl_setupnn.m')) ;
%% load the trained CNN from MNIST
load('net-epoch-21.mat');
net.layers{end}.type = 'softmax';
%% Move network to GPU Array
net = vl_simplenn_move(net, 'gpu');
%% Read game board image to detect 15 numbers
I = imread(fullfile('Pass','IMG_0231.JPG'));
%% Detect gameboard, get orthophoto
orthophoto = find_square(I);
%% Test 4 orientations
best_orientation_score = 0;
detected_tiles = zeros([4 4]);
for i=0:3
    orthophoto = imrotate(orthophoto,-i*90);
    % Slice into 16 tiles
    tiles = slice_to_tiles(orthophoto);
    % Detect number on 16 tiles
    [candidate_score,candidate_tiles] = detect_tiles(net,tiles);
    if candidate_score > best_orientation_score
        detected_tiles = candidate_tiles;
        best_orientation_score = candidate_score;
    end
end
detected_tiles
toc()
%% A* Algorithms to find optimal steps
tic()
StartGame(detected_tiles);
toc()
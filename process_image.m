
% process_image: Loads and processes an image and convert it to a vector
% for transmittion.
%
% Inputs: 
%   - filename: Image file name
%   - img_x, img_y: Image dimensions
% Outputs:
%   - pixels: Binary image data vector
%   - interleaving: Interleaving pattern used


function [pixels, interleaving] = process_image(image_path, img_x, img_y)
    A = imread(image_path);
    A = imresize(A, [img_x img_y]); % Resize image
    
    if size(A, 3) == 3
        % Convert to grayscale if it is an RGB image
        A_gray = rgb2gray(A);
    else
        % If already grayscale, keep it as is
        A_gray = A;
    end

    pixels = double(A_gray(:))'; % Flatten to 1D
    pixels = (pixels - mean(pixels)) / std(pixels); % Normalize
    
    %figure; imshow(reshape(pixels, img_x, img_y)); %comment of you like
    
    pixels = pixels > 0; % Convert to binary
    
    figure; imshow(reshape(pixels, img_x, img_y)); %comment of you like
    
    interleaving = randperm(length(pixels)); % Randomize
    pixels = pixels(interleaving);
    
    figure; imshow(reshape(pixels, img_x, img_y)); %comment of you like
end
function [ imgs ] = get_img_2d( image_paths, setsize )
%  num, dim
    num = size(image_paths, 1);
    dim = setsize(1) *setsize(2);
    imgs = zeros(num, dim);
    for i= 1: num
        img_tmp = imresize(imread(image_paths{i}), setsize);
        % imshow(img_tmp);
        imgs(i,:) = reshape(rgb2gray(img_tmp), 1, dim);
        
    end
    imgs = 1.0 - double(imgs)/255;
    % imgs = imgs';

end


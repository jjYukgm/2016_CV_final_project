function [ imgs ] = get_img_4d( image_paths, setsize )
% height, width, chennel, 
    num = size(image_paths, 1);
    imgs = zeros(num, setsize(1), setsize(2), 1);
    for i= 1: num
        img_tmp = rgb2gray(imread(image_paths{i}));
        imgs(i,:,:,:) = imresize(img_tmp, setsize);
    end
    imgs = 1 - double(imgs)/255;
    imgs = permute(imgs, [2 3 4 1]);

end


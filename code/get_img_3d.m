function [ imgs ] = get_img_3d( image_paths, setsize )
% height, width, num
    num = size(image_paths, 1);
    imgs = zeros(num, setsize(1), setsize( 2));
    for i= 1: num
        img_tmp = imresize(imread(image_paths{i}), setsize);
        % imshow(img_tmp);
        imgs(i,:,:) = rgb2gray(img_tmp);
        
    end
    imgs = 1.0 - double(imgs)/255;
    imgs = permute(imgs, [2 3 1]);

end


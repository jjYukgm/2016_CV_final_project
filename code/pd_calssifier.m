function [ pred_p_lbl, pred_d_lbl ] = pd_calssifier( bbox, stave, img_id, categories_pitch, categories_duration, pred_p_lbl_n )
% bbox: n by d matrix, d: minx, miny, width, height
    load('cnn_p.mat');
    load('cnn_d.mat');
    num_bbox = size(bbox, 1);
    pred_p_lbl = cell(num_bbox, 1);
    pred_d_lbl = cell(num_bbox, 1);
    unique_p_labels = unique(categories_pitch); 
    num_categories_p = length(unique_p_labels);
    unique_d_labels = unique(categories_duration); 
    num_categories_d = length(unique_d_labels);
    
    bbox_img = zeros(num_bbox, 80* 24);
    for i=1:num_bbox
        tmp = imresize(imcrop(stave{img_id(i)}, bbox(i,:)), [80 24]);
        % imshow(tmp);
        % NN need reshape
        bbox_img(i,:) = reshape(rgb2gray(tmp), 1, 80* 24);
        
    end
    
    % get predict label
    % CNN
%   bbox_img = permute(bbox_img, [2 3 1]);
%     cnn_p_wb = cnnff(cnn_p_wb, bbox_img);
%     predp_lbl = round(cnn_p_wb.o * num_categories_p);% rescle to origin bound
%     
%     cnn_d_wb = cnnff(cnn_d_wb, bbox_img);
%     predd_lbl = round(cnn_d_wb.o * num_categories_d);% rescle to origin bound
    % NN
    bbox_img = 1 - double(bbox_img)/255;
    % predp_lbl = nnpredict(cnn_p_wb, bbox_img);
    predd_lbl = nnpredict(cnn_d_wb, bbox_img);
    
    
    
    % turn the labels to original
    for i = 1:num_bbox
        pred_p_lbl{i} = unique_p_labels{pred_p_lbl_n(i)};
        pred_d_lbl{i} = unique_d_labels{predd_lbl(i)};
    end

end


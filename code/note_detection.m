
function [bboxes , NBPS , image_ids , stave, pred_p_lbl] = .... 
    note_detection( image_path )



% 'test_scn_path' is a string. This directory contains images which may or
%    may not have faces in them. This function should work for the MIT+CMU
%    test set but also for any other images (e.g. class photos)
% 'w' and 'b' are the linear classifier parameters
% 'feature_params' is a struct, with fields
%   feature_params.template_size (probably 36), the number of pixels
%      spanned by each train / test template and
%   feature_params.hog_cell_size (default 6), the number of pixels in each
%      HoG cell. template size should be evenly divisible by hog_cell_size.
%      Smaller HoG cell sizes tend to work better, but they make things
%      slower because the feature dimensionality increases and more
%      importantly the step size of the classifier decreases at test time.

% 'bboxes' is Nx4. N is the number of detections. bboxes(i,:) is
%   [x_min, y_min, x_max, y_max] for detection i. 
%   Remember 'y' is dimension 1 in Matlab!
% 'confidences' is Nx1. confidences(i) is the real valued confidence of
%   detection i.
% 'image_ids' is an Nx1 cell array. image_ids{i} is the image file name
%   for detection i. (not the full path, just 'albert.jpg')

% The placeholder version of this code will return random bounding boxes in
% each test image. It will even do non-maximum suppression on the random
% bounding boxes to give you an example of how to call the function.

% Your actual code should convert each test image to HoG feature space with
% a _single_ call to vl_hog for each scale. Then step over the HoG cells,
% taking groups of cells that are the same size as your learned template,
% and classifying them. If the classification is above some confidence,
% keep the detection and then pass all the detections for an image to
% non-maximum suppression. For your initial debugging, you can operate only
% at a single scale and you can skip calling non-maximum suppression.

%%%%%%%%%%%%%%% 0. input = bbox of staff, img id, img     
%%%%%%%%%%%%%%% 1. stave bbox to search bbox
%%%%%%%%%%%%%%% 2. searchbox 's min x and min y as offset and crop
%%%%%%%%%%%%%%% 3. sliding window
%%%%%%%%%%%%%%% 4. output = note bbox + offset
%% 
% clc;
% clear;
%ori = imread('æ­¡æ???jpg');
% imread('example.png')  
ori = imread(image_path);

scale = 980/size(ori , 2);
ori = imresize(ori,scale); 

gray=rgb2gray(ori);
%?ˆå?å½©è‰²å½±å?è½‰ç°??

BW=edge(gray,'sobel');
%?¨sobel or Cannyæ¼”ç?æ³•å?å¾—å½±?é?ç·?ä¸¦ä?äºŒå???

totc = sum(BW,2);

ind_mat = find(totc>= 500);%æ°´å¹³ç´¯å?æ¨™æ?

output = zeros(size(ind_mat,1)/10 , 4);
NSPS = size(ind_mat,1)/10;

for i = 1 : NSPS
    
    output(i , 1) = 50 ;%left default 50~110
    output(i , 2) = ind_mat(1+10*( i - 1 ) , 1)+1-27;
    output(i , 3) = 870 ;%right default 870~930
    output(i , 4) = 84;
    
end    

num_stave = ceil(NSPS/2);
stave = cell(num_stave, 1);
data_path = '..\data\pattern\';
pattern_path  = fullfile(data_path,'pattern');
xpattern_path = fullfile(data_path,'xpattern');
% test_scn_path = fullfile(data_path,'Stave');
% hold on;
for i = 1:2:NSPS
    stave{ceil(i/2)} = imcrop( ori ,  output(i,:));
    % imshow(stave{ceil(i/2)});
end

% hold off;

%STAVE °ª«× 30 pixel ¤W¤U¦U 27 Á`¦@ 84pixel

feature_params = struct('template_size', 25,'hog_cell_size', 5);
Dim = ceil((feature_params.template_size / feature_params.hog_cell_size))^2 * 31;

pattern = dir( fullfile( pattern_path, '*.jpg' ));
xpattern = dir( fullfile( xpattern_path, '*.jpg' ));


for i = 1:15
    pat = imread( fullfile( pattern_path, pattern(i).name ));
    pat = im2single(pat);
    features_pos(i,:) = reshape( vl_hog(pat, feature_params.hog_cell_size), 1 , Dim);
end

for i = 1:13
    xpat = imread( fullfile( xpattern_path, xpattern(i).name ));
    xpat = im2single(xpat);
    features_neg(i,:) = reshape( ceil(vl_hog( xpat, feature_params.hog_cell_size)), 1, Dim);
end

% test_scenes = dir( fullfile( test_scn_path, '*.jpg' ));

% 
% pattern = im2double(pattern);
% pattern = rgb2gray(pattern);
% xpattern = im2double(xpattern);
% xpattern = rgb2gray(xpattern);

% 
% m=size(pattern,1); 
% n=size(pattern,2); 

%initialize these as empty and incrementally expand them.

% feature_params.hog_cell_size=5;
% cell_size = feature_params.hog_cell_size;
% 
% for i=1:2
% features_pos(i,:) = reshape( vl_hog(pattern(i).name, feature_params.hog_cell_size), 1 , Dim);
% end
% 
% for i=1:6
% features_neg(i,:) = reshape( vl_hog( xpattern(i).name, feature_params.hog_cell_size), 1, Dim);
% end

lambda = 0.0001;
y_pos = ones( size( features_pos,1) , 1);
y_neg = -ones( size( features_neg,1) , 1);
X = [ features_pos ; features_neg]';
Y = [ y_pos ; y_neg];
 
[w , b] = vl_svmtrain( X , Y, lambda);
%% step 3. Examine learned classifier
% You don't need to modify anything in this section. The section first
% evaluates _training_ error, which isn't ultimately what we care about,
% but it is a good sanity check. Your training error should be very low.

fprintf('Initial classifier performance on train data:\n')
confidences = [features_pos; features_neg]*w + b;
label_vector = [ones(size(features_pos,1),1); -1*ones(size(features_neg,1),1)];
[tp_rate, fp_rate, tn_rate, fn_rate] =  report_accuracy( confidences, label_vector );

% Visualize how well separated the positive and negative examples are at
% training time. Sometimes this can idenfity odd biases in your training
% data, especially if you're trying hard negative mining. This
% visualization won't be very meaningful with the placeholder starter code.
non_face_confs = confidences( label_vector < 0);
face_confs     = confidences( label_vector > 0);
figure(2); 
plot(sort(face_confs), 'g'); hold on
plot(sort(non_face_confs),'r'); 
plot([0 size(non_face_confs,1)], [0 0], 'b');
hold off;

% Visualize the learned detector. This would be a good thing to include in
% your writeup!
n_hog_cells = sqrt(length(w) / 31); %specific to default HoG parameters
imhog = vl_hog('render', single(reshape(w, [n_hog_cells n_hog_cells 31])), 'verbose') ;
figure(3); imagesc(imhog) ; colormap gray; set(3, 'Color', [.988, .988, .988])

pause(0.1) %let's ui rendering catch up
hog_template_image = frame2im(getframe(3));
% getframe() is unreliable. Depending on the rendering settings, it will
% grab foreground windows instead of the figure in question. It could also
% return a partial image.
%imwrite(hog_template_image, 'visualizations/hog_template.png')




bboxes = zeros(0,4);
confidences = zeros(0,1);
image_ids = zeros(0,1);

scales = [1,0.9,0.8,0.7,0.6,0.5,0.4,0.3,0.2,0.1,0.05];
bboxesinfo = [];

%%for i=1:length(test_scenes) 

NBPS = zeros(num_stave,1);
%% 
for i=1:num_stave
    %fprintf('Detecting faces in %s\n', test_scenes(i).name)  
%     img = imread( fullfile( test_scn_path, test_scenes(i).name ));   %%read one test scene at a time
    img = stave{i}; 
    img = single(img)/255;
    
    if(size(img,3) > 1)
        img = rgb2gray(img);
    end
    
     cur_bboxes = zeros(0,4);
     cur_confidences = zeros(0,1);
     cur_image_ids = zeros(0,1);   %% img id
 
     for scale = 1% scales   %%1~0.007
         img_scaled = imresize(img, scale);  %%test on various resizes
         [height, width] = size(img_scaled); 
 
         test_features = vl_hog(img_scaled, feature_params.hog_cell_size); 
         ncw = floor( width/ feature_params.hog_cell_size);
         nch = floor( height/ feature_params.hog_cell_size);
 
         tmp = feature_params.template_size / feature_params.hog_cell_size;
 
         nncw = ncw - tmp + 1;  
         nnch = nch - tmp + 1;
 
         Dim1 = tmp^2*31;
         window_feats = zeros(ncw * nch, Dim1);
 
         for x = 1:nncw
             for y = 1:nnch
                 window_feats((x-1)*nnch+ y, :) = reshape(test_features(y:(y+tmp-1), x:(x+tmp-1), :), 1, Dim1);
             end
         end
 
         scores = window_feats * w +b;
         
         indices = find(scores>0.77);
         
         cur_scale_confidences = scores(indices);
 
         detected_x = floor(indices./nnch);
         detected_y = mod(indices, nnch)-1;
         
         % no pred pitch
%          cur_scale_bboxes = [feature_params.hog_cell_size*detected_x+1, ones(size(detected_y,1),1), ...
%          feature_params.hog_cell_size*(detected_x+tmp), 80*ones(size(detected_y,1),1)]./scale;
         % pred pitch
         cur_scale_bboxes = [feature_params.hog_cell_size*detected_x+1, feature_params.hog_cell_size*detected_y+1, ...
         feature_params.hog_cell_size*(detected_x+tmp), feature_params.hog_cell_size*(detected_y+tmp)]./scale;

%          cur_scale_bboxes = [feature_params.hog_cell_size*detected_x+1, feature_params.hog_cell_size*detected_y+1, ...
%          feature_params.hog_cell_size*(detected_x+tmp), feature_params.hog_cell_size*(detected_y+tmp)]./scale;
     
 
         cur_bboxes      = [cur_bboxes;      cur_scale_bboxes];
         
         cur_confidences = [cur_confidences; cur_scale_confidences];
     end
    
    %non_max_supr_bbox can actually get somewhat slow with thousands of
    %initial detections. You could pre-filter the detections by confidence,
    %e.g. a detection with confidence -1.1 will probably never be
    %meaningful. You probably _don't_ want to threshold at 0.0, though. You
    %can get higher recall with a lower threshold. You don't need to modify
    %anything in non_max_supr_bbox, but you can.
    [is_maximum , Nbboxes] = non_max_supr_bbox(cur_bboxes, cur_confidences, size(img));
    NBPS(i,1) = Nbboxes;
    
    cur_confidences = cur_confidences(is_maximum,:);
    cur_bboxes      = cur_bboxes(     is_maximum,:);
    
    cur_image_ids = i*ones(size(cur_bboxes,1), 1);
 
    bboxes      = [bboxes;      cur_bboxes];
    confidences = [confidences; cur_confidences];
    image_ids   = [image_ids;   cur_image_ids];
    
    
%     figure(i)
%     imshow(stave{i});
%     hold on;
%     for k = 1:size(cur_bboxes,1) 
%         
%             cur_bboxes(k,3) = cur_bboxes(k, 3)-cur_bboxes(k,1);
%             cur_bboxes(k,4) = cur_bboxes(k, 4)-cur_bboxes(k,2);
% %           cur_bboxes(k,3) = 25;
% %           cur_bboxes(k,4) = 80;
%           rectangle('Position',cur_bboxes(k,:));
%         
%           %bboxinfo = [ bboxinfo ; cur_bboxes(k,:) ];
%     end
%     hold off;
%     
    


end

% 
num_bb = size(bboxes,1);
pred_p_lbl = zeros(num_bb, 1);
for k = 1:num_bb
        
    pred_p_lbl(k) = 16 - (bboxes(k, 2)-1)/5;
%     bboxes(k,3) = 25;
%     bboxes(k,4) = 25;
    
    bboxes(k,3) = 25;
    bboxes(k,4) = 80;
    
end
    

 
   




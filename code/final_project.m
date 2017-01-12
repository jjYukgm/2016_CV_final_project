
clc;
close all;
clear;
data_path = '../data/';
data_path_pitch = '../data/Pitch';
% categories = {'2_5.0', '2_6.0', '2_7.0', ...
%         '3_1.0', '3_2.0', '3_3.0', '3_4.0', '3_5.0', '3_6.0', '3_7.0', ...
%         '4_1.0', '4_2.0', '4_3.0', '4_4.0', '4_5.0', '4_6.0', '4_7.0', ...
%         '5_1.0', '5_2.0', '5_3.0'};
categories_pitch = {'2_6.0', '2_7.0', ...
        '3_1.0', '3_2.0', '3_3.0', '3_4.0', '3_5.0', '3_6.0', '3_7.0', ...
        '4_1.0', '4_2.0', '4_3.0', '4_4.0', '4_5.0', '4_6.0', '4_7.0'};
enddata_path_duration = '../data/Duration';
categories_duration = {'0.25', '0.50', '1.00', '2.00', '4.00'};
test_paths = 0;
image_path = '../data/testing/Åw¼Ö¹|.jpg';
%% inital note detection
[bbox , num_noteps , image_ids , image, pred_p_lbl_n] = note_detection( image_path );

%% Train the pitch classfier and save it
if ~exist('cnn_p.mat', 'file')
    get_opts.num_per_cat = 20;
%     % CNN
%     opts.alpha = 3 * 10^-5;
%     opts.batchsize = 31;
%     opts.numepochs = 50;
%   NN
%     % unweight
%     get_opts.w = 0;
%     opts.w = 1;
%     opts.batchsize = 45;
%     get_opts.te_ratio = 0.027;
%   weight # data
    get_opts.w = 0;
    opts.w = 1;
    opts.batchsize = 38;% 14cat: 28, 16cat: 38
    get_opts.te_ratio = 0.028;% 14cat: .025, 16cat: .028
    opts.learningRate = 5.5*10^-3;
    opts.numepochs =  500;        %  Number of full sweeps through data
    opts.plot      = 1;         %  enable plotting
    [train_paths, train_labels, test_paths, test_labels] = ... 
        get_image_paths_trte(data_path_pitch, categories_pitch,get_opts);
    [cnn_p_wb, cnnt] = train_classifier2p(train_paths, train_labels, test_paths, test_labels, opts);
    save('cnn_p.mat', 'cnn_p_wb')
end

%% Train the pitch classfier and save it

if ~exist('cnn_d.mat', 'file')
    get_opts.num_per_cat = 38;
    % CNN
    % weight args
%     get_opts.te_ratio = 0.05;
%     opts.batchsize = 20;
%   unweight args
%     get_opts.te_ratio = 0.026;
% %     opts.batchsize = 41;
%     opts.alpha = 1 ;% *10^-4;
%     opts.numepochs = 20;
%   NN
%   weight # data
%     get_opts.w = 1;
%     opts.w = 0;
%     get_opts.te_ratio = 0.05;
%     opts.batchsize = 20;       %  Take a mean gradient step over this many samples
%   unweight
    get_opts.w = 0;% med #
    opts.w = 1;
    get_opts.te_ratio = 0.03;% w=0:0.03; w=2:0.028
    opts.batchsize = 34;% w=0:34; w=2:29
    opts.learningRate = 6.5*10^-3;
    opts.numepochs =  250;        %  Number of full sweeps through data
    opts.plot      = 1;         %  enable plotting
    [train_paths, train_labels, test_paths, test_labels] = ... 
        get_image_paths_trte(enddata_path_duration, categories_duration, get_opts);
    [cnn_d_wb, cnnt] = train_classifier2(train_paths, train_labels, test_paths, test_labels, opts);
    save('cnn_d.mat', 'cnn_d_wb')
end


%% classifier
[pred_p_lbl, pred_d_lbl] = pd_calssifier(bbox, image, image_ids, categories_pitch, categories_duration, pred_p_lbl_n);

%% output: text
			
[ fig, output_str ] = disp_output( num_noteps, pred_p_lbl, pred_d_lbl ,'output_test');

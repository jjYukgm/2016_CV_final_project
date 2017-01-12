function [ nn, labels ] = train_classifier2( train_paths, train_labels, test_paths, test_labels, opts )
% input:
%   train_paths:	n by 1 cells, train path
%   train_labels:	n by 1 cells, train lbl string
%   test_paths:     n by 1 cells
%   test_labels:	n by 1 cells
%   opts:	.alpha  .batchsize  .numepochs
%% reference
% https://github.com/rasmusbergpalm/DeepLearnToolbox

%% 
num_categories = length(unique(train_labels));
insize = [80, 24];% height, weidth
imgs = get_img_2d(train_paths, insize);% num, dim
train_x = imgs;
[train_y, test_y] = labelstr2double(train_labels, test_labels, opts.w);
% train_y = train_y';
imgs = get_img_2d(test_paths, insize);
test_x = imgs;
% test_y = test_y';
[train_x, mu, sigma] = zscore(train_x);
test_x = normalize(test_x, mu, sigma);

rand('state',0)
layer = [size(train_x, 2), 175, 34, num_categories];
nn = nnsetup(layer);

nn.weightPenaltyL2 = 1e-4;  %  L2 weight decay
nn.dropoutFraction = 0.5;   %  Dropout fraction 
nn.activation_function = 'sigm';    %  Sigmoid activation function
nn.learningRate = opts.learningRate; %  Sigm require a lower learning rate
nn.output              = 'softmax';    %  use softmax output


[nn, L] = nntrain(nn, train_x, train_y, opts, test_x, test_y);

[er, bad, labels] = nntest_tako_ver(nn, test_x, test_y);
fig = gcf;
fn = ['NN_' num2str(layer) 'learningRate' num2str(opts.learningRate) '_batchsize' num2str(opts.batchsize) '_#epochs' num2str(opts.numepochs) '.jpg' ];
saveas(fig,fn);
disp(['er' num2str(er) ' bad' num2str(bad')])
% assert(er < 0.1, 'Too big error');

end
function [ dou_labels_tr,  dou_labels_te ] = labelstr2double( str_labels_tr, str_labels_te , opts_w)
%   str_labels_tr: n by 1 cells
%   str_labels_te: n by 1 cells
    str_labels2 = unique(str_labels_tr); 
    
    num_tot = size(str_labels_tr, 1);
    num_categories = length(str_labels2);
    dou_labels_tr = zeros(length(str_labels_tr), num_categories);
    dou_labels_te = zeros(length(str_labels_te), num_categories);
    if opts_w == 1
        for i = 1:num_categories
            num_i = sum(strcmp(str_labels2{i}, str_labels_tr));
            dou_labels_tr( strcmp(str_labels2{i}, str_labels_tr),i) = 0.55 + 0.45*num_tot /num_categories / num_i;% to weight the tr_num
            dou_labels_te( strcmp(str_labels2{i}, str_labels_te),i) =1.0;
        end
    else
        for i = 1:num_categories
            dou_labels_tr( strcmp(str_labels2{i}, str_labels_tr),i) =1.0;% num_tot /num_categories / num_i;% to weight the tr_num
            dou_labels_te( strcmp(str_labels2{i}, str_labels_te),i) =1.0;
        end
    end
    % dou_labels = double(dou_labels)/num_categories;
    dou_labels_tr = double(dou_labels_tr);% /num_categories;
    dou_labels_te = double(dou_labels_te);% /num_categories;
end

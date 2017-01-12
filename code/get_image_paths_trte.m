
function [train_image_paths, train_labels, test_image_paths, test_labels] = ... 
    get_image_paths_trte(data_path, categories, get_opts)

    num_categories = length(categories); %number of scene categories.
    te_num = ceil(num_categories * get_opts.num_per_cat * get_opts.te_ratio);
    tr_num = num_categories * get_opts.num_per_cat - te_num;

    train_image_paths = cell(tr_num, 1);
    test_image_paths = cell(te_num, 1);

    train_labels = cell(num_categories * get_opts.num_per_cat, 1);
    test_labels = cell(num_categories * get_opts.num_per_cat, 1);
    
    j_te = 1;
    j_tr = 1;
    if get_opts.w ==1
       % weight # data
        min_len = 500;
        for i=1:num_categories
           images = dir( fullfile(data_path, categories{i}, '*.jpg'));
           img_len = size(images, 1);
           if(min_len > img_len)
               min_len = img_len;
           end
        end
        for i=1:num_categories
           images = dir( fullfile(data_path, categories{i}, '*.jpg'));
           img_len = size(images, 1);
           te_numpc = ceil(min_len * get_opts.te_ratio);
           tr_ind = randperm(img_len, min_len);
           te_ind = randperm(min_len, te_numpc);
           % te_ind = tr_ind(te_ind);
           for j=1:min_len
               if(any(te_ind == j) )
                   test_image_paths{ j_te} = fullfile(data_path, categories{i}, images(tr_ind(j)).name);
                   test_labels{ j_te} = categories{i};
                   j_te = j_te + 1;
               else
                   train_image_paths{ j_tr} = fullfile(data_path, categories{i}, images(tr_ind(j)).name);
                   train_labels{ j_tr} = categories{i};
                   j_tr = j_tr + 1;
               end
           end
        end 
    elseif get_opts.w ==2
       % weight # data mean
        num_dim_len = zeros(num_categories, 1);
        for i=1:num_categories
           images = dir( fullfile(data_path, categories{i}, '*.jpg'));
           num_dim_len(i) = size(images, 1);
        end
        med_len = median(num_dim_len);
        for i=1:num_categories
           images = dir( fullfile(data_path, categories{i}, '*.jpg'));
           img_len = size(images, 1);
           if med_len > img_len
               med_len = img_len;
           end
           te_numpc = ceil(med_len * get_opts.te_ratio);
           tr_ind = randperm(img_len, med_len);
           te_ind = randperm(med_len, te_numpc);
           % te_ind = tr_ind(te_ind);
           for j=1:med_len
               if(any(te_ind == j) )
                   test_image_paths{ j_te} = fullfile(data_path, categories{i}, images(tr_ind(j)).name);
                   test_labels{ j_te} = categories{i};
                   j_te = j_te + 1;
               else
                   train_image_paths{ j_tr} = fullfile(data_path, categories{i}, images(tr_ind(j)).name);
                   train_labels{ j_tr} = categories{i};
                   j_tr = j_tr + 1;
               end
           end
        end 
    else
        % unweight: overfitting risk
        for i=1:num_categories
           images = dir( fullfile(data_path, categories{i}, '*.jpg'));
           img_len = size(images, 1);
           te_numpc = ceil(img_len * get_opts.te_ratio);
           te_ind = randperm(img_len, te_numpc);
           % te_ind = tr_ind(te_ind);
           for j=1:img_len
               if(any(te_ind == j) )
                   test_image_paths{ j_te} = fullfile(data_path, categories{i}, images(j).name);
                   test_labels{ j_te} = categories{i};
                   j_te = j_te + 1;
               else
                   train_image_paths{ j_tr} = fullfile(data_path, categories{i}, images(j).name);
                   train_labels{ j_tr} = categories{i};
                   j_tr = j_tr + 1;
               end
           end
        end
    end

    
    id = cellfun('length',train_image_paths);
	train_image_paths(id==0)=[];
    id = cellfun('length',train_labels);
	train_labels(id==0)=[];
    id = cellfun('length',test_image_paths);
	test_image_paths(id==0)=[];
    id = cellfun('length',test_labels);
	test_labels(id==0)=[];
end


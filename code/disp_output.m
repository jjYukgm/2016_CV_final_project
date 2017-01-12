function [ fig, output_str ] = disp_output( num_noteps, p_lbl, d_lbl, img_id )
% input:
% num_noteps:    n by 1 matrix, # node per staff
% img_id:       string  matrix
% get notes per staff
offset = 0;
num_staff = size(num_noteps, 1);
output_str = cell(num_staff, 1);% per cell: a staff
figure(1);
set(gcf, 'color', 'white', 'Position', [1 1 1960 1080]);% get large size image
fig = gcf;
fig.PaperPositionMode  = 'auto';

axis off;% 使坐標軸消隱
hold on;
for j = 1:num_staff
    % do output str or show
    str1 = '';% upper
    str2 = '';% medium
    str4 = '';% lower
    for i=1:num_noteps(j)
        p_scale = strsplit(p_lbl{offset + i},'_');
        p_level = str2double(p_scale(1));
        p_scale = num2str(str2double(p_scale(2)));
        d_length = str2double(d_lbl{offset + i});
        % str1: upper label
        if(p_level > 3 )
            str1 = [str1 '‧   '];
        else
            str1 = [str1 '　    '];
        end
        % str2: medium label
        if( d_length < 0.5  )
            str2 = [str2 '\underline{\underline{' p_scale ' }}'];% full-shape with space neighbor
        elseif( d_length < 1 )
            str2 = [str2 '\underline{' p_scale ' }'];% full-shape with space neighbor
        else
            str2 = [str2  p_scale ' '];
        end
        % str4: lower label
        if(p_level < 3 )
            str4 = [str4 '‧   '];
        else
            str4 = [str4 '　   '];
        end
        % length complement
        if(d_length == 2)
            str1 = [str1 '　 '];
            str2 = [str2 '- '];
            str4 = [str4 '　 '];
        elseif(d_length == 4)
            str1 = [str1 '　 　 　 '];
            str2 = [str2 '- - - '];
            str4 = [str4 '　 　 　 '];
        end
        
    end
    offset = offset + num_noteps(j);
    
    % show staff
    h_offset = 1- .5*j/num_staff;
    text('string',str1,'interpreter','tex',...
        'fontsize',9,'units','norm','pos',[.1 h_offset+.03]);
    text('string',str2,'interpreter','latex',...
        'fontsize',20,'units','norm','pos',[.1 h_offset]);
    text('string',str4,'interpreter','tex',...
        'fontsize',9,'units','norm','pos',[.1 h_offset-.025]);
    output_str_tmp = {str1; str2; str4};
    output_str{j} = output_str_tmp;
end
hold off;
saveas(gcf,img_id, 'svg');
% testbench of a staff
%     pred_p_lbl = [ ...
%             '2_1.0'; '2_2.0'; '3_3.0'; '4_4.0'; '2_5.0'; '2_6.0'; '4_7.0'; ...
%             '3_1.0'; '3_2.0'; '3_3.0'; '3_4.0'; '3_5.0'; '3_6.0'; '3_7.0'; ...
%             '4_1.0'; '4_2.0'; '4_3.0'; '2_4.0'; '4_5.0'; '4_6.0'; '4_7.0'  ...
%                 ];
%     pred_d_lbl = [  ...
%                     '0.25'; '0.50'; '1.00'; '2.00'; '4.00'; ...
%                     '0.25'; '0.50'; '1.00'; '2.00'; '4.00'; ...
%                     '0.25'; '0.50'; '1.00'; '2.00'; '4.00'; ...
%                     '0.25'; '0.50'; '1.00'; '2.00'; '4.00'; ...
%                     '0.25'  ...
%                 ];

% h_offset = .9;
% w_offset = .1;
% axis([0 1 0 10]);
% axis ij;% 設置坐標軸的原點在左上角，i為縱坐標，j為橫坐標
% % axis tight;% 以數據的大小為坐標軸的範圍
% %axis equal;
% % axis off;% 使坐標軸消隱
% 
% h = text('string',str1,'interpreter','tex',...
%     'fontsize',15,'units','norm','pos',[w_offset h_offset+.03]);
% h = text('string',str2,'interpreter','latex',...
%     'fontsize',20,'units','norm','pos',[w_offset h_offset]);
% h = text('string',str4,'interpreter','tex',...
%     'fontsize',15,'units','norm','pos',[w_offset h_offset-.025]);
% 
% h = text('string',str2,'interpreter','latex',...
%     'fontsize',20,'units','norm','pos',[.1 1.05]);
end


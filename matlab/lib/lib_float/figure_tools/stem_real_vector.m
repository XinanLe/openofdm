function stem_real_vector(input_real_vector)
%======================================================================================================================%
% Description:
%   stem_real_vector()使用MATLAB的stem函数画出一个实数向量的图形
% Inputs:
%   input_real_vector : 复数行向量或列向量
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2025.03.01
%======================================================================================================================%

%% 入参判断
assert(isvector(input_real_vector), 'Invalid input');


%% 笛卡尔坐标画图
figure();
set(0, 'defaultfigurecolor', 'w');  % 将图片背景设置为白色

x = 0:length(input_real_vector)-1;
stem(x, input_real_vector, "filled",'LineStyle','-','MarkerFaceColor','blue','MarkerEdgeColor','green');
set(gca, 'Box', 'off');  % 去掉图的边框
title('stem画实数');


end


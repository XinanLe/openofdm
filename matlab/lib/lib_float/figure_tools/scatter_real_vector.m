function scatter_real_vector(input_real_vector)
%======================================================================================================================%
% Description:
%   scatter_real_vector()使用MATLAB的scatter函数画出一个实数向量的图形
% Inputs:
%   input_real_vector : 复数行向量或列向量
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2025.03.26
%======================================================================================================================%

%% 入参判断
assert(isvector(input_real_vector), 'Invalid input');


%% 笛卡尔坐标画图
figure('Color', 'white');

x = 0:length(input_real_vector)-1;
scatter(x, input_real_vector, 15, 'blue', 'filled');
set(gca, 'Box', 'off');  % 去掉图的边框
title('stem画实数');


end


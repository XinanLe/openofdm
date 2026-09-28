function stem_complex_vector(input_complex_vector)
%======================================================================================================================%
% Description:
%   stem_complex_vector()使用MATLAB的stem函数画出一个复数向量的笛卡尔坐标和极坐标图形
% Inputs:
%   input_complex_vector : 复数行向量或列向量
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2024.12.03
%======================================================================================================================%

%% 入参判断
assert(isvector(input_complex_vector), 'Invalid input');


%% 笛卡尔坐标画图
figure();
set(0, 'defaultfigurecolor', 'w');  % 将图片背景设置为白色

subplot(2,2,1);
x = 0:length(input_complex_vector)-1;
y = real(input_complex_vector);
stem(x, y, "filled", 'LineStyle','-','MarkerFaceColor','blue','MarkerEdgeColor','green');
set(gca, 'Box', 'off');  % 去掉图的边框
title('笛卡尔坐标-实部');

subplot(2,2,2);
x = 0:length(input_complex_vector)-1;
y = imag(input_complex_vector);
stem(x, y, "filled", 'LineStyle','-','MarkerFaceColor','blue','MarkerEdgeColor','green');
set(gca, 'Box', 'off');  % 去掉图的边框
title('笛卡尔坐标-虚部');


%% 极坐标画图
amplitude = abs(input_complex_vector);
phase = angle(input_complex_vector);

subplot(2,2,3);
x = 0:length(amplitude)-1;
y = amplitude;
stem(x, y, "filled", 'LineStyle','-','MarkerFaceColor','blue','MarkerEdgeColor','green');
set(gca, 'Box', 'off');  % 去掉图的边框
title('极坐标-幅度');

subplot(2,2,4);
x = 0:length(phase)-1;
y = phase;
stem(x, y, "filled", 'LineStyle','-','MarkerFaceColor','blue','MarkerEdgeColor','green');
set(gca, 'Box', 'off');  % 去掉图的边框
title('极坐标-相位');


end


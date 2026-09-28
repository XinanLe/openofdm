function scatter_constellation(input_vector, title_string)
%======================================================================================================================%
% Description:
%   画星座图
% Inputs:
%   input_vector : 复值符号, 格式为向量
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2024.12.01
%======================================================================================================================%

%% 入参判断
assert(isvector(input_vector), 'Input nust be vector.');
if nargin == 1
    title_string = 'Constellation';
end


%% 获取输入向量的实部和虚部
real_vector = real(input_vector);
imag_vector = imag(input_vector);


%% 画图
% fig = figure('Visible','on', 'Color','white', 'Units','pixels', 'Position',[50,50,800,600]);
fig = figure('Color','white');
ax  = axes('Parent', fig);

scatter(ax, real_vector, imag_vector, 8, 'red', 'filled');  % 横轴为实部(同相分量), 纵轴为虚部(正交分量)

ax.Title.String    = '归一化星座图';
ax.Title.FontSize  = 12;
ax.XLabel.String   = 'I路(实部, 同向分量)';
ax.XLabel.FontSize = 12;
ax.YLabel.String   = 'Q路(虚部, 正交分量)';
ax.YLabel.FontSize = 12;

bound = ceil(max([1, max(abs(real_vector)), max(abs(imag_vector))])*2) / 2;
if bound <= 5
    ax.XLim       = [-1.05*bound, 1.05*bound];
    ax.XTick      = -bound : 0.5 : bound;
    ax.XTickLabel = -bound : 0.5 : bound;
end
ax.XAxisLocation = 'origin';

if bound <= 5
    ax.YLim       = [-1.05*bound, 1.05*bound];
    ax.YTick      = -bound : 0.5 : bound;
    ax.YTickLabel = -bound : 0.5 : bound;
end
ax.YAxisLocation = 'origin';


end

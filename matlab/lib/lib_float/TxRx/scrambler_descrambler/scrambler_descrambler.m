function output_data_row = scrambler_descrambler(input_data_row, shift_register)
%======================================================================================================================%
% Description:
%   实现加扰/解扰功能, 扰码多项式为: S(x) = x^7 + x^4 + 1
% Inputs:
%   input_data_row  : 输入比特序列, 行向量
%   shift_register  : 移位寄存器初始值, 行向量, shift_register(1:7)存的是x1,x2,...,x7
% Outputs:
%   output_data_row : 加扰/解扰之后的输出比特序列, 行向量
% Notes:
%   1. 将输入序列全都设置为0, 即可得到加扰序列, 加扰序列和原始数据序列模2加即可得到加扰后的数据序列
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.21
%======================================================================================================================%

%% 入参判断
assert(isrow(input_data_row), 'Input must be row.');  % 要求输入为行向量


%% 参数初始化
% poly = [1, 0, 0, 1, 0, 0, 0, 1];  % 扰码多项式

% % 移位寄存器初始化, shift_register(1:7)存的是x1,x2,...,x7
% shift_register = ones(1, length(poly)-1);

% 加扰/解扰之后的输出比特序列初始化
output_data_row = zeros(1, length(input_data_row));


%% 加扰/解扰流程
for clk = 1:length(input_data_row)
    % 组合逻辑
    sr_in = mod(shift_register(4)+shift_register(7), 2);
    output_data_row(clk) = mod(input_data_row(clk)+sr_in, 2);

    % 时序逻辑
    shift_register(2:end) = shift_register(1:end-1);
    shift_register(1)     = sr_in;
end


end

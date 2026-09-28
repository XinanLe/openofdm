function punctured_bit_row = encoder(input_bit_row, code_rate)
%======================================================================================================================%
% Description:
%   信道编码器
% Inputs:
%   input_bit_row : 输入比特, 行向量
%   code_rate     : 信道编码码率, 支持: 1/2, 2/3, 3/4
% Outputs:
%   punctured_bit_row : 输出比特, 行向量
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.22
%======================================================================================================================%

%% 基本参数初始化
input_bit_num = length(input_bit_row);


%% 64状态转换机, 寄存器初始状态
% register(1:6)表示最左边Tb到最右边Tb
register = zeros(1, 6);


%% 编码
A_bit_row = zeros(1, input_bit_num);
B_bit_row = zeros(1, input_bit_num);
for index1 = 1:input_bit_num
    % 计算输出A和输出B
    A_bit_row(index1) = mod(input_bit_row(index1)+register(2)+register(3)+register(5)+register(6), 2);
    B_bit_row(index1) = mod(input_bit_row(index1)+register(1)+register(2)+register(3)+register(6), 2);

    % 更新寄存器状态
    register(2:end) = register(1:end-1);
    register(1)     = input_bit_row(index1);
end

coded_bit_row = reshape([A_bit_row; B_bit_row], 1, []);


%% 打孔
punctured_bit_row = puncture(coded_bit_row, code_rate);


end

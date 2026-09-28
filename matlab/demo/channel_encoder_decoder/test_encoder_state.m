%======================================================================================================================%
% Description:
%   计算64状态分量编码器的状态转移图
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.22
%======================================================================================================================%

clc;
clear;
close all;


%% 变量初始化
input_bit_num  = 1;
output_bit_num = 2;
register_num   = 6;
state_num      = 2 ^ register_num;

% register(1:6)的权重为2.^(5:-1:0)
FromState_register_dec = repelem((0:state_num-1).', output_bit_num, 1);
ToState_register_dec   = zeros(output_bit_num*state_num, 1);

input_bit_col    = repmat([0;1], state_num, 1);
output_A_bit_col = zeros(output_bit_num*state_num, 1);
output_B_bit_col = zeros(output_bit_num*state_num, 1);


%% 计算64状态分量编码器的状态转移图
for index1 = 1:output_bit_num*state_num
    % 当前寄存器状态
    current_register_bin = dec2bin(FromState_register_dec(index1), 6) - '0';

    % 计算输出A和输出B
    output_A_bit_col(index1) = mod(input_bit_col(index1)+current_register_bin(2)+ ...
        current_register_bin(3)+current_register_bin(5)+current_register_bin(6), 2);
    output_B_bit_col(index1) = mod(input_bit_col(index1)+current_register_bin(1)+ ...
        current_register_bin(2)+current_register_bin(3)+current_register_bin(6), 2);

    % 更新寄存器状态
    next_register_bin(2:6) = current_register_bin(1:5);
    next_register_bin(1)   = input_bit_col(index1);

    ToState_register_dec(index1) = next_register_bin * 2.^(5:-1:0).';
end

FromState_register_bin = dec2bin(FromState_register_dec, 6) - '0';
ToState_register_bin   = dec2bin(ToState_register_dec, 6)   - '0';


%% 计算trellis结构
trellis = struct();

trellis.numInputSymbols  = 2;   % 输入1比特, 共2种输入: 0/1
trellis.numOutputSymbols = 4;   % 输出2比特, 共4种输出, AB: 00/01/10/11
trellis.numStates        = 64;  % 6个寄存器, 共64个状态

% FromState_register_dec是i-1, 输入是j-1, 对应的ToState_register_dec
trellis.nextStates = [ToState_register_dec(1:2:end), ToState_register_dec(2:2:end)];

% A为高位, B为低位, 将AB转换为十进制
output_dec_col = 2*output_A_bit_col + output_B_bit_col;

% FromState_register_dec是i-1, 输入是j-1, 对应的输出
trellis.outputs = [output_dec_col(1:2:end), output_dec_col(2:2:end)];

% 检查trellis结构是否合法
[isok, status] = istrellis(trellis);


%% matlab产生的trellis
trellis_matlab = poly2trellis(7, [133 171]);

assert(sum(sum(abs(trellis.nextStates-trellis_matlab.nextStates))) == 0, '[ERROR] Invalid nextStates');
assert(sum(sum(abs(trellis.outputs   -trellis_matlab.outputs)))    == 0, '[ERROR] Invalid outputs');


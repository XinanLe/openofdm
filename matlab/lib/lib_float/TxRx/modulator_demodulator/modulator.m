function modulated_symbol_row = modulator(input_bit_row, bit_num_per_subcarrier)
%======================================================================================================================%
% Description:
%   调制
% Inputs:
%   input_bit_row   : 输入比特, 行向量
%   bit_num_per_subcarrier : 1-BPSK, 2-QPSK, 4-16QAM, 6-64QAM
% Outputs:
%   modulated_symbol_row : 输出调制符号, 行向量
% Test:
%   bit_num_per_subcarrier = 6;  scatter_constellation(modulator(randi([0,1], 1, 1000*bit_num_per_subcarrier), bit_num_per_subcarrier));
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.22
%======================================================================================================================%

%% 入参判断
assert(isrow(input_bit_row), '[ERROR] Input must be row');  % 要求输入为矩阵


%% 参数初始化
% input_bits_matrix(1,:)表示b0, 是MSB
input_bits_matrix = reshape(input_bit_row, bit_num_per_subcarrier, []);


%% 星座点映射(调制)
if bit_num_per_subcarrier == 1
    I_table = [-1, +1];
    I_index = input_bits_matrix;

    modulated_symbol_row = I_table(I_index+1);
elseif bit_num_per_subcarrier == 2
    I_Q_table = [-1, +1];

    I_index = input_bits_matrix(1,:);
    Q_index = input_bits_matrix(2,:);

    modulated_symbol_row = (I_Q_table(I_index+1) + 1j*I_Q_table(Q_index+1)) / sqrt(2);
elseif bit_num_per_subcarrier == 4
    I_Q_table = [-3, -1, +3, +1];

    I_index = 2.^(1:-1:0) * input_bits_matrix(1:2,:);  % b0,b1
    Q_index = 2.^(1:-1:0) * input_bits_matrix(3:4,:);  % b2,b3

    modulated_symbol_row = (I_Q_table(I_index+1) + 1j*I_Q_table(Q_index+1)) / sqrt(10);
elseif bit_num_per_subcarrier == 6
    I_Q_table = [-7, -5, -1, -3, +7, +5, +1, +3];

    I_index = 2.^(2:-1:0) * input_bits_matrix(1:3,:);  % b0,b1,b2
    Q_index = 2.^(2:-1:0) * input_bits_matrix(4:6,:);  % b3,b4,b5

    modulated_symbol_row = (I_Q_table(I_index+1) + 1j*I_Q_table(Q_index+1)) / sqrt(42);
else
    error('[ERROR] Invalid bit_num_per_subcarrier');
end


end

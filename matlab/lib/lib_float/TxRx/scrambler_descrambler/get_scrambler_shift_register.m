function shift_register = get_scrambler_shift_register(scrambled_bit_row)
%======================================================================================================================%
% Description:
%   根据DATA字段前7个加扰后的比特, 反推扰码器初始移位寄存器状态
% Inputs:
%   scrambled_bit_row : DATA字段前7个加扰后的比特, 行向量, 对应加扰前输入全0
% Outputs:
%   shift_register    : 扰码器初始移位寄存器状态, 行向量, shift_register(1:7)存的是x1,x2,...,x7
% Notes:
%   1. SERVICE字段最低7比特在加扰前固定为0, 因此加扰后的前7比特即为扰码器输出序列
%   2. 扰码多项式为: S(x) = x^7 + x^4 + 1
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.21
%======================================================================================================================%

%% 入参判断
assert(isrow(scrambled_bit_row), 'Input must be row.');  % 要求输入为行向量
assert(length(scrambled_bit_row) == 7, 'Input length must be 7.');


%% 参数初始化
shift_register = zeros(1, 7);


%% 反推移位寄存器初始值
% 根据scrambler_descrambler的实现有:
%   scrambled_bit_row(1) = mod(shift_register(4) + shift_register(7), 2)
%   scrambled_bit_row(2) = mod(shift_register(3) + shift_register(6), 2)
%   scrambled_bit_row(3) = mod(shift_register(2) + shift_register(5), 2)
%   scrambled_bit_row(4) = mod(shift_register(1) + shift_register(4), 2)
%   scrambled_bit_row(5) = mod(scrambled_bit_row(1) + shift_register(3), 2)
%   scrambled_bit_row(6) = mod(scrambled_bit_row(2) + shift_register(2), 2)
%   scrambled_bit_row(7) = mod(scrambled_bit_row(3) + shift_register(1), 2)

shift_register(1) = mod(scrambled_bit_row(7) + scrambled_bit_row(3), 2);
shift_register(2) = mod(scrambled_bit_row(6) + scrambled_bit_row(2), 2);
shift_register(3) = mod(scrambled_bit_row(5) + scrambled_bit_row(1), 2);
shift_register(4) = mod(scrambled_bit_row(4) + shift_register(1), 2);
shift_register(5) = mod(scrambled_bit_row(3) + shift_register(2), 2);
shift_register(6) = mod(scrambled_bit_row(2) + shift_register(3), 2);
shift_register(7) = mod(scrambled_bit_row(1) + shift_register(4), 2);


end
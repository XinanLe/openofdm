%======================================================================================================================%
% Description:
%   测试IEEE802P11的加扰和解扰
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.21
%======================================================================================================================%

clc;
clear;
close all;


%% 寄存器初始化全1, 协议给了结果
spec_result = [0,0,0,0,1,1,1,0, 1,1,1,1,0,0,1,0, 1,1,0,0,1,0,0,1, 0,0,0,0,0,0,1,0, ...
               0,0,1,0,0,1,1,0, 0,0,1,0,1,1,1,0, 1,0,1,1,0,1,1,0, 0,0,0,0,1,1,0,0, ...
               1,1,0,1,0,1,0,0, 1,1,1,0,0,1,1,1, 1,0,1,1,0,1,0,0, 0,0,1,0,1,0,1,0, ...
               1,1,1,1,1,0,1,0, 0,1,0,1,0,0,0,1, 1,0,1,1,1,0,0,0, 1,1,1,1,1,1,1];

assert(sum(abs(scrambler_descrambler(zeros(1,127), ones(1,7)) - spec_result)) == 0, ...
    '[ERROR] Invalid scrambler_descrambler');


%% 任意非零初始状态, 加扰序列每127比特重复
for shift_register_dec = 1:127
    shift_register_bin = dec2bin(shift_register_dec, 7) - '0';

    scrambled_bit_row    = scrambler_descrambler(zeros(1,127*10), shift_register_bin);
    scrambled_bit_matrix = reshape(scrambled_bit_row, 127, []).';

    assert(sum(abs( mean(scrambled_bit_matrix, 1) - scrambled_bit_matrix(1,:) )) == 0, '[ERROR] Invalid repeat property');
end


%% 寄存器初始化随机, 待加扰数据前7个比特固定为0, 可通过加扰后的结果反推寄存器初始化值
for shift_register_dec = 1:127
    shift_register_bin = dec2bin(shift_register_dec, 7) - '0';

    scrambled_bit_row = scrambler_descrambler([zeros(1,7), randi([0,1], 1, 247)], shift_register_bin);

    shift_register_bin_est = get_scrambler_shift_register(scrambled_bit_row(1:7));

    assert(sum(abs(shift_register_bin_est - shift_register_bin)) == 0, '[ERROR] Invalid get_scrambler_shift_register');
end




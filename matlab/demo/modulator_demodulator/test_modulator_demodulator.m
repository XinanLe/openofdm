%======================================================================================================================%
% Description:
%   测试IEEE802P11的调制解调
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.22
%======================================================================================================================%

clc;
clear;
close all;

for bitsPerSubCarrier = [1,2,4,6]  % 每个子载波承载的比特数
%% 原始比特
source_bits = randi([0,1], 1, 1000*bitsPerSubCarrier);


%% 调制
modulated_symbols = modulator(source_bits, bitsPerSubCarrier);


%% 解调
[soft_info_row, hard_bit_row] = de_modulator(modulated_symbols, bitsPerSubCarrier);

assert(sum(abs(source_bits-hard_bit_row)) == 0, '[ERROR] Invalid hard bits');
assert(sum(abs(source_bits-double(soft_info_row < 0))) == 0, '[ERROR] Invalid soft bits');


end


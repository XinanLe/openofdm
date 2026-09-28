%======================================================================================================================%
% Description:
%   测试IEEE802P11的信道交织
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.21
%======================================================================================================================%

clc;
clear;
close all;


for bitsPerSubCarrier = [1,2,4,6]  % 每个子载波承载的比特数
%% 参数初始化
coded_bitNum_per_OFDM = 48 * bitsPerSubCarrier;


%% 信道交织模块输入索引
input_index1 = 1:coded_bitNum_per_OFDM;
input_index0 = input_index1 - 1;


%% 信道交织模块第一次置换
% 子载波级交织, 16列矩阵, 按行写入, 按列读出
% temp_index1 = reshape(input_index1, [], 16).';
% permutation_1st_index1 = reshape(temp_index1, 1, []);
temp_index1 = reshape(input_index1, 16, []).';
permutation_1st_index1 = reshape(temp_index1, 1, []);

% 我代码的理解和协议算出来的是相反的
spec_i = (coded_bitNum_per_OFDM / 16) * mod(input_index0, 16) + floor(input_index0 / 16);

spec_permutation_1st_index1 = zeros(1,coded_bitNum_per_OFDM);
spec_permutation_1st_index1(spec_i+1) = input_index1;

assert(sum(abs(spec_permutation_1st_index1-permutation_1st_index1)) == 0, '[ERROR] Invalid 1st permutation');


%% 信道交织模块第二次置换
if (bitsPerSubCarrier == 1) || (bitsPerSubCarrier == 2)
    interlever_pattern = permutation_1st_index1;  % 不做第二次置换
else
    col_num = max(bitsPerSubCarrier/2, 1);
    row_num = coded_bitNum_per_OFDM / col_num;
    circshiftVal = repelem(-mod((0:(row_num/6-1)).', col_num), 6, 1);

    temp_index1 = reshape(permutation_1st_index1, col_num, []).';

    temp_index2 = zeros(size(temp_index1));
    for row_index1 = 1:row_num
        temp_index2(row_index1,:) = circshift(temp_index1(row_index1,:), circshiftVal(row_index1), 2);
    end

    interlever_pattern = reshape(temp_index2.', 1, []);
end
output_index1 = input_index1(interlever_pattern);


spec_s = max(bitsPerSubCarrier/2, 1);
spec_j = spec_s * floor(spec_i / spec_s) + ...
         mod((spec_i + coded_bitNum_per_OFDM - floor(16 * spec_i / coded_bitNum_per_OFDM)), spec_s);

spec_output_index1 = zeros(1,coded_bitNum_per_OFDM);
spec_output_index1(spec_j+1) = input_index1;


assert(sum(abs(spec_output_index1-output_index1)) == 0, '[ERROR] Invalid 2nd permutation');


%% 信道交织, 接口测试
assert(sum(abs( interleaver_pattern_generation(coded_bitNum_per_OFDM, bitsPerSubCarrier) - ...
    spec_output_index1 )) == 0, '[ERROR] Invalid interleaver_pattern_generation');


end

function interlever_pattern = interleaver_pattern_generation(coded_bitNum_per_OFDM, bit_num_per_subcarrier)
%======================================================================================================================%
% Description:
%   产生信道交织模式
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.21
%======================================================================================================================%

%% 参数初始化
input_index1 = 1:coded_bitNum_per_OFDM;


%% 第一次置换
% 子载波级交织, 16列矩阵, 按行写入, 按列读出
temp_index1 = reshape(input_index1, 16, []).';
permutation_1st_index1 = reshape(temp_index1, 1, []);


%% 信道交织模块第二次置换
if (bit_num_per_subcarrier == 1) || (bit_num_per_subcarrier == 2)
    interlever_pattern = permutation_1st_index1;  % 不做第二次置换
else
    % 按行写进矩阵中, 矩阵的每一行做循环移位, 再按行读出
    col_num = max(bit_num_per_subcarrier/2, 1);
    row_num = coded_bitNum_per_OFDM / col_num;
    circshiftVal = repelem(-mod((0:(row_num/6-1)).', col_num), 6, 1);

    temp_index1 = reshape(permutation_1st_index1, col_num, []).';

    temp_index2 = zeros(size(temp_index1));
    for row_index1 = 1:row_num
        temp_index2(row_index1,:) = circshift(temp_index1(row_index1,:), circshiftVal(row_index1), 2);
    end

    interlever_pattern = reshape(temp_index2.', 1, []);
end


end

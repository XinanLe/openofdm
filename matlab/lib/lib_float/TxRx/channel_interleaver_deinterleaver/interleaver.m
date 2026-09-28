function output_data_row = interleaver(input_data_row, coded_bitNum_per_OFDM, bit_num_per_subcarrier)
%======================================================================================================================%
% Description:
%   信道交织器
% Inputs:
%   input_data_row     : 1个OFDM符号承载的比特序列, 行向量
%   coded_bitNum_per_OFDM : 1个OFDM符号承载的比特数
%   bit_num_per_subcarrier   : 每个子载波承载的比特数, 调制阶数
% Outputs:
%   output_data_row : 信道交织后, 1个OFDM符号承载的比特序列, 行向量
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.21
%======================================================================================================================%

%% 入参判断
assert(isrow(input_data_row), 'Input must be row.');  % 要求输入为行向量


%% 信道交织Step 1: 产生信道交织模式
interlever_pattern = interleaver_pattern_generation(coded_bitNum_per_OFDM, bit_num_per_subcarrier);


%% 信道交织Step 2: 信道交织
output_data_row = input_data_row(interlever_pattern);


end


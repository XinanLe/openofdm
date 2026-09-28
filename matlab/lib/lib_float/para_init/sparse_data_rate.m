function [bit_num_per_subcarrier, code_rate] = sparse_data_rate(data_rate_Mbps, channel_spacing_Mhz)
%======================================================================================================================%
% Description:
%   解析数据速率
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.23
%======================================================================================================================%

%% 参数初始化
data_rate_all_20Mhz = [6, 9, 12, 18, 24, 36, 48, 54];  % Mbps
data_rate_all_10Mhz = data_rate_all_20Mhz / 2;
data_rate_all_5Mhz  = data_rate_all_10Mhz / 2;

bit_num_per_subcarrier_all = [1,   1,   2,   2,   4,   4,   6,   6];
code_rate_all             = [1/2, 3/4, 1/2, 3/4, 1/2, 3/4, 2/3, 3/4];


%% 解析数据速率
if channel_spacing_Mhz == 20
    bit_num_per_subcarrier = bit_num_per_subcarrier_all(data_rate_all_20Mhz == data_rate_Mbps);
    code_rate           = code_rate_all(data_rate_all_20Mhz == data_rate_Mbps);
elseif channel_spacing_Mhz == 10
    bit_num_per_subcarrier = bit_num_per_subcarrier_all(data_rate_all_10Mhz == data_rate_Mbps);
    code_rate           = code_rate_all(data_rate_all_10Mhz == data_rate_Mbps);
elseif channel_spacing_Mhz == 5
    bit_num_per_subcarrier = bit_num_per_subcarrier_all(data_rate_all_5Mhz == data_rate_Mbps);
    code_rate           = code_rate_all(data_rate_all_5Mhz == data_rate_Mbps);
else
    error('[ERROR] Invalid channel_spacing_Mhz');
end


%% 协议计算
% ofdm_duration_us_20Mhz = 4;  % OFDM符号持续时间
% ofdm_duration_us_10Mhz = ofdm_duration_us_20Mhz * 2;
% ofdm_duration_us_5Mhz  = ofdm_duration_us_10Mhz * 2;
% 
% source_bit_num_per_OFDM = 48 * bit_num_per_subcarrier_all .* code_rate_all;
% 
% data_rate_spec_20Mhz = source_bit_num_per_OFDM / ofdm_duration_us_20Mhz;
% data_rate_spec_10Mhz = source_bit_num_per_OFDM / ofdm_duration_us_10Mhz;
% data_rate_spec_5Mhz  = source_bit_num_per_OFDM / ofdm_duration_us_5Mhz;


end

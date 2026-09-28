function [is_parity_error, data_rate_Mbps, PSDU_byte_num] = SIG_source_bit_parse(channel_spacing_Mhz, SIG_source_bit_row)
%======================================================================================================================%
% Description:
%   产生SIGNAL的24比特
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.24
%======================================================================================================================%

% SIGNAL的24比特的各个字段:
%   data_rate(4比特) + reserved(1比特, 值为0) + PSDU字节数(12比特) + 奇偶校验(1比特) + tail(6比特, 值为0)

%% 奇偶校验
is_parity_error = mod(sum(abs(SIG_source_bit_row)), 2);


%% 解析
data_rate_bit_row = SIG_source_bit_row(1:4);

if sum(abs(data_rate_bit_row - [1, 1, 0, 1])) == 0
    data_rate_Mbps = (channel_spacing_Mhz/ 20) * 6;
elseif sum(abs(data_rate_bit_row - [1, 1, 1, 1])) == 0
    data_rate_Mbps = (channel_spacing_Mhz/ 20) * 9;
elseif sum(abs(data_rate_bit_row - [0, 1, 0, 1])) == 0
    data_rate_Mbps = (channel_spacing_Mhz/ 20) * 12;
elseif sum(abs(data_rate_bit_row - [0, 1, 1, 1])) == 0
    data_rate_Mbps = (channel_spacing_Mhz/ 20) * 18;
elseif sum(abs(data_rate_bit_row - [1, 0, 0, 1])) == 0
    data_rate_Mbps = (channel_spacing_Mhz/ 20) * 24;
elseif sum(abs(data_rate_bit_row - [1, 0, 1, 1])) == 0
    data_rate_Mbps = (channel_spacing_Mhz/ 20) * 36;
elseif sum(abs(data_rate_bit_row - [0, 0, 0, 1])) == 0
    data_rate_Mbps = (channel_spacing_Mhz/ 20) * 48;
elseif sum(abs(data_rate_bit_row - [0, 0, 1, 1])) == 0
    data_rate_Mbps = (channel_spacing_Mhz/ 20) * 54;
else
    error('[ERROR] Invalid data_rate_bit_row');
end


PSDU_byte_num_bit_row = SIG_source_bit_row(5 + (1:12));
PSDU_byte_num = PSDU_byte_num_bit_row * 2.^(0:11).';


end

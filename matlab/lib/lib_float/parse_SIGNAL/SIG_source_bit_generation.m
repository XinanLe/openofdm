function SIG_source_bit_row = SIG_source_bit_generation(channel_spacing_Mhz, data_rate_Mbps, PSDU_byte_num)
%======================================================================================================================%
% Description:
%   产生SIGNAL的24比特
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.24
%======================================================================================================================%

% SIGNAL的24比特的各个字段:
%   data_rate(4比特) + reserved(1比特, 值为0) + PSDU字节数(12比特) + 奇偶校验(1比特) + tail(6比特, 值为0)

if data_rate_Mbps == 0
    data_rate_bit_row = [0, 0, 0, 0];
elseif data_rate_Mbps == (channel_spacing_Mhz / 20) * 6
    data_rate_bit_row = [1, 1, 0, 1];
elseif data_rate_Mbps == (channel_spacing_Mhz / 20) * 9
    data_rate_bit_row = [1, 1, 1, 1];
elseif data_rate_Mbps == (channel_spacing_Mhz / 20) * 12
    data_rate_bit_row = [0, 1, 0, 1];
elseif data_rate_Mbps == (channel_spacing_Mhz / 20) * 18
    data_rate_bit_row = [0, 1, 1, 1];
elseif data_rate_Mbps == (channel_spacing_Mhz / 20) * 24
    data_rate_bit_row = [1, 0, 0, 1];
elseif data_rate_Mbps == (channel_spacing_Mhz / 20) * 36
    data_rate_bit_row = [1, 0, 1, 1];
elseif data_rate_Mbps == (channel_spacing_Mhz / 20) * 48
    data_rate_bit_row = [0, 0, 0, 1];
elseif data_rate_Mbps == (channel_spacing_Mhz / 20) * 54
    data_rate_bit_row = [0, 0, 1, 1];
else
    error('[ERROR] Invalid data_rate_Mbps');
end


PSDU_byte_num_bit_row = fliplr(dec2bin(PSDU_byte_num, 12) - '0');

parity_bit = mod(sum([data_rate_bit_row, PSDU_byte_num_bit_row]), 2);

SIG_source_bit_row = [data_rate_bit_row, 0, PSDU_byte_num_bit_row, parity_bit, zeros(1,6)];


end

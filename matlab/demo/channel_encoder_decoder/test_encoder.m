%======================================================================================================================%
% Description:
%   验证信道编码器的正确性
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.23
%======================================================================================================================%

clc;
clear;
close all;

for channel_spacing_Mhz = [20, 10, 5]
    for data_rate_Mbps_20Mhz = [6, 9, 12, 18, 24, 36, 48, 54]
        fprintf(1, 'channel_spacing_Mhz = %d, data_rate_Mbps_20Mhz = %d\n', channel_spacing_Mhz, data_rate_Mbps_20Mhz);
        data_rate_Mbps = data_rate_Mbps_20Mhz * (channel_spacing_Mhz / 20);
        for PSDU_byte_num = [14, 50, 100:500:4095, 4095]  % 12比特
%% 产生原始信息比特
% service(16 bit) + PSDU(PSDU_byte_num*8 bit) + tail(6 bit) + pad(need calculate)
[bit_num_per_subcarrier, code_rate] = sparse_data_rate(data_rate_Mbps, channel_spacing_Mhz);
source_bit_num_per_OFDM = 48 * bit_num_per_subcarrier * code_rate;

service_bit_num = 16;
PSDU_bit_num    = PSDU_byte_num*8;
tail_bit_num    = 6;
service_PSDU_tail_bit_num = service_bit_num + PSDU_bit_num + tail_bit_num;
pad_bit_num     = ceil( service_PSDU_tail_bit_num / source_bit_num_per_OFDM ) * source_bit_num_per_OFDM - ...
    service_PSDU_tail_bit_num;
source_bit_num    = service_bit_num + PSDU_bit_num + tail_bit_num + pad_bit_num;


%% 产生原始信息比特
% 前7比特固定为0, 用于接收端获取加扰器的寄存器初始状态, 后9比特reserved目前设置的全0
service_bit_row = zeros(1, service_bit_num);
PSDU_bit_row    = crc_encoder(randi([0,1], 1, PSDU_bit_num-32), 'CRC32');
tail_bit_row    = zeros(1, tail_bit_num);
pad_bit_row     = zeros(1, pad_bit_num);
data_bit_row    = [service_bit_row, PSDU_bit_row, tail_bit_row, pad_bit_row];


%% 加扰
shift_register_dec       = randi([1,127], 1, 1);
scrambler_shift_register = dec2bin(shift_register_dec, 7) - '0';

scrambled_bit_row = scrambler_descrambler(data_bit_row, scrambler_shift_register);

% 加扰后强制将tail的6比特置0
scrambled_bit_row(service_bit_num+PSDU_bit_num+(1:tail_bit_num)) = 0;


%% 信道编码
punctured_bit_row = encoder(scrambled_bit_row, code_rate);


%% 信道编码调MATLAB库实现
trellis_matlab       = poly2trellis(7, [133 171]);
coded_bit_row_matlab = convenc(scrambled_bit_row.', trellis_matlab).';
punctured_bit_row_matlab = puncture(coded_bit_row_matlab, code_rate);

assert(sum(abs(punctured_bit_row_matlab-punctured_bit_row)) == 0, '[ERROR] Invalid channel encoder');


        end
    end
end


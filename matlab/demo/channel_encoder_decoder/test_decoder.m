%======================================================================================================================%
% Description:
%   验证信道译码器的正确性
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
%% 参数初始化
SNR_dB     = 15;
SNR_linear = 10^(SNR_dB/10);


%% 产生原始信息比特
% service(16 bit) + PSDU(PSDU_byte_num*8 bit) + tail(6 bit) + pad(need calculate)
[bit_num_per_subcarrier, code_rate] = sparse_data_rate(data_rate_Mbps, channel_spacing_Mhz);
coded_bitNum_per_OFDM = 48 * bit_num_per_subcarrier;
source_bit_num_per_OFDM  = 48 * bit_num_per_subcarrier * code_rate;

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


%% 信道交织
punctured_bit_matrix = reshape(punctured_bit_row.', coded_bitNum_per_OFDM, []).';

interlever_pattern = interleaver_pattern_generation(coded_bitNum_per_OFDM, bit_num_per_subcarrier);
interleaved_bit_matrix = punctured_bit_matrix(:, interlever_pattern);

interleaved_bit_row = reshape(interleaved_bit_matrix.', 1, []);


%% 调制
modulated_symbol_row = modulator(interleaved_bit_row, bit_num_per_subcarrier);


%% 加噪声, 等价于频域带内SNR
modulated_symbol_num = length(modulated_symbol_row);

awgn_row       = (randn(1,modulated_symbol_num) + 1j*randn(1,modulated_symbol_num)) / sqrt(2);  % 标准AWGN噪声
awgn_meanPower = (awgn_row * awgn_row') / modulated_symbol_num;  % 噪声平均功率

% 信号平均功率
modulated_symbol_meanPower = (modulated_symbol_row * modulated_symbol_row') / modulated_symbol_num;

% 噪声幅度因子
noise_amplitude_factor = sqrt( modulated_symbol_meanPower / (awgn_meanPower * SNR_linear) );

rx_modulated_symbol_row = modulated_symbol_row + noise_amplitude_factor * awgn_row;


%% 解调
% ln[Pr(bit = 0)/Pr(bit = 1)]
[soft_info_row, hard_bit_row] = de_modulator(rx_modulated_symbol_row, bit_num_per_subcarrier);

% assert(sum(abs( interleaved_bit_row-hard_bit_row )) == 0, '[ERROR] Invalid hard_bit_row');


%% 解信道交织
soft_info_matrix = reshape(soft_info_row.', coded_bitNum_per_OFDM, []).';

interlever_pattern = interleaver_pattern_generation(coded_bitNum_per_OFDM, bit_num_per_subcarrier);

deinterleaved_soft_info_matrix = zeros(size(soft_info_matrix));
deinterleaved_soft_info_matrix(:,interlever_pattern) = soft_info_matrix;

deinterleaved_soft_info_row = reshape(deinterleaved_soft_info_matrix.', 1, []);


%% 信道译码解打孔和去掉pad
% 现在编码码率是1/2
depunctured_soft_info_row = de_puncture(deinterleaved_soft_info_row, code_rate);

decoder_input_soft_info_row = depunctured_soft_info_row(1:end-2*pad_bit_num);


%% 信道译码调MATLAB库实现
trellis_matlab = poly2trellis(7, [133 171]);

if code_rate == 1/2
    traceback_depth = 30;
elseif code_rate == 2/3
    traceback_depth = 45;
elseif code_rate == 3/4
    traceback_depth = 60;
else
    error('[ERROR] Invalid code_rate');
end

% 'term': 从全0状态开始, 在全0状态结束
decoded_bit_row = vitdec(decoder_input_soft_info_row.', trellis_matlab, traceback_depth, 'term', 'unquant').';


%% 解扰
scrambler_shift_register_est = get_scrambler_shift_register(decoded_bit_row(1:7));

descrambled_bit_row = scrambler_descrambler(decoded_bit_row, scrambler_shift_register_est);


%% PSDU
rx_PSDU_bit_row = descrambled_bit_row(service_bit_num + (1:PSDU_bit_num));
crc_error_flag  = crc_decoder(rx_PSDU_bit_row, 'CRC32');


        end
    end
end


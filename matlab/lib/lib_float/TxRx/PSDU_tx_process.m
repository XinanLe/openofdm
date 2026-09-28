function [CP_signal, configs] = PSDU_tx_process(configs)
%======================================================================================================================%
% Description:
%   产生PSDU时域信号
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.24
%======================================================================================================================%

%% 参数初始化
n_fft            = configs.common.n_fft;
% valid_tone_num   = configs.common.valid_tone_num;
% invalid_tone_num = configs.common.invalid_tone_num;
% pilot_tone_num   = configs.common.pilot_tone_num;
data_tone_num    = configs.common.data_tone_num;
CP_sample_num    = configs.common.CP_sample_num;

pilot_tone_index1 = configs.common.pilot_tone_index1;
data_tone_index1  = configs.common.data_tone_index1;

scrambler_shift_register_bin = configs.common.PSDU.scrambler_shift_register_bin;
bit_num_per_subcarrier       = configs.common.PSDU.bit_num_per_subcarrier;
code_rate                    = configs.common.PSDU.code_rate;
coded_bit_num_per_OFDM       = configs.common.PSDU.coded_bit_num_per_OFDM;
% source_bit_num_per_OFDM      = configs.common.PSDU.source_bit_num_per_OFDM;
service_bit_num              = configs.common.PSDU.service_bit_num;
PSDU_bit_num                 = configs.common.PSDU.PSDU_bit_num;
tail_bit_num                 = configs.common.PSDU.tail_bit_num;
pad_bit_num                  = configs.common.PSDU.pad_bit_num;
% source_bit_num               = configs.common.PSDU.source_bit_num;
coded_bit_num                = configs.common.PSDU.coded_bit_num;
ofdm_num                     = configs.common.PSDU.ofdm_num;

pilot_modulated_symbol_matrix = configs.common.PSDU.pilot_modulated_symbol_matrix;


%% 产生原始信息比特
% 前7比特固定为0, 用于接收端获取加扰器的寄存器初始状态, 后9比特reserved目前设置的全0
service_bit_row = zeros(1, service_bit_num);
PSDU_bit_row    = crc_encoder(randi([0,1], 1, PSDU_bit_num-32), 'CRC32');
tail_bit_row    = zeros(1, tail_bit_num);
pad_bit_row     = zeros(1, pad_bit_num);
source_bit_row  = [service_bit_row, PSDU_bit_row, tail_bit_row, pad_bit_row];


%% 加扰
scrambler_output_bit_row = scrambler_descrambler(source_bit_row, scrambler_shift_register_bin);

% 加扰后强制将tail的6比特置0
scrambled_bit_row = scrambler_output_bit_row;
scrambled_bit_row(service_bit_num+PSDU_bit_num+(1:tail_bit_num)) = 0;


%% 信道编码, 打孔
punctured_bit_row = encoder(scrambled_bit_row, code_rate);


%% 信道交织
punctured_bit_matrix = reshape(punctured_bit_row.', coded_bit_num_per_OFDM, ofdm_num).';

interlever_pattern     = interleaver_pattern_generation(coded_bit_num_per_OFDM, bit_num_per_subcarrier);
interleaved_bit_matrix = punctured_bit_matrix(:, interlever_pattern);

interleaved_bit_row = reshape(interleaved_bit_matrix.', 1, coded_bit_num);


%% 调制
data_modulated_symbol_row    = modulator(interleaved_bit_row, bit_num_per_subcarrier);
data_modulated_symbol_matrix = reshape(data_modulated_symbol_row, data_tone_num, ofdm_num).';


%% PSDU频域信号
freq_symbol = zeros(ofdm_num, n_fft);
freq_symbol(:, pilot_tone_index1) = pilot_modulated_symbol_matrix;
freq_symbol(:, data_tone_index1)  = data_modulated_symbol_matrix;


%% IFFT得到时域信号
ifft_input_signal = circshift(freq_symbol, -n_fft/2, 2);

% ifft_output_signal = sqrt(n_fft) * ifft(ifft_input_signal, n_fft, 2);
ifft_output_signal = ifft(ifft_input_signal, n_fft, 2);


%% 产生PSDU信号
CP_signal = [ifft_output_signal(:, end-CP_sample_num+1:end), ifft_output_signal];


%% configs.debug
configs.common.PSDU.PSDU_bit_row   = PSDU_bit_row;
% configs.common.PSDU.source_bit_row = source_bit_row;
if configs.testmat.MATLAB_debug
    configs.debug.tx.PSDU.scrambled_bit_row            = scrambled_bit_row;
    configs.debug.tx.PSDU.punctured_bit_row            = punctured_bit_row;
    configs.debug.tx.PSDU.interleaved_bit_row          = interleaved_bit_row;
    configs.debug.tx.PSDU.data_modulated_symbol_matrix = data_modulated_symbol_matrix;
    configs.debug.tx.PSDU.freq_symbol                  = freq_symbol;
    configs.debug.tx.PSDU.ifft_input_signal            = ifft_input_signal;
    configs.debug.tx.PSDU.ifft_output_signal           = ifft_output_signal;
    configs.debug.tx.PSDU.CP_signal                    = CP_signal;
end


end

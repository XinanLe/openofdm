function [CP_signal, configs] = SIG_tx_process(configs)
%======================================================================================================================%
% Description:
%   产生SIG时域信号
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

bit_num_per_subcarrier  = configs.common.SIG.bit_num_per_subcarrier;
code_rate               = configs.common.SIG.code_rate;
coded_bit_num_per_OFDM  = configs.common.SIG.coded_bit_num_per_OFDM;
% source_bit_num_per_OFDM = configs.common.SIG.source_bit_num_per_OFDM;
% source_bit_num          = configs.common.SIG.source_bit_num;
coded_bit_num           = configs.common.SIG.coded_bit_num;
ofdm_num                = configs.common.SIG.ofdm_num;

source_bit_row                = configs.common.SIG.source_bit_row;
pilot_modulated_symbol_matrix = configs.common.SIG.pilot_modulated_symbol_matrix;


%% 信道编码, 打孔
punctured_bit_row = encoder(source_bit_row, code_rate);


%% 信道交织
punctured_bit_matrix = reshape(punctured_bit_row.', coded_bit_num_per_OFDM, ofdm_num).';

interlever_pattern     = interleaver_pattern_generation(coded_bit_num_per_OFDM, bit_num_per_subcarrier);
interleaved_bit_matrix = punctured_bit_matrix(:, interlever_pattern);

interleaved_bit_row = reshape(interleaved_bit_matrix.', 1, coded_bit_num);


%% 调制
data_modulated_symbol_row    = modulator(interleaved_bit_row, bit_num_per_subcarrier);
data_modulated_symbol_matrix = reshape(data_modulated_symbol_row, data_tone_num, ofdm_num).';


%% SIG频域信号
freq_symbol = zeros(ofdm_num, n_fft);
freq_symbol(:, pilot_tone_index1) = pilot_modulated_symbol_matrix;
freq_symbol(:, data_tone_index1)  = data_modulated_symbol_matrix;


%% IFFT得到时域信号
ifft_input_signal = circshift(freq_symbol, -n_fft/2, 2);

% ifft_output_signal = sqrt(n_fft) * ifft(ifft_input_signal, n_fft, 2);
ifft_output_signal = ifft(ifft_input_signal, n_fft, 2);


%% 产生SIG信号
CP_signal = [ifft_output_signal(:, end-CP_sample_num+1:end), ifft_output_signal];


%% configs.debug
if configs.testmat.MATLAB_debug
    configs.debug.tx.SIG.punctured_bit_row            = punctured_bit_row;
    configs.debug.tx.SIG.interleaved_bit_row          = interleaved_bit_row;
    configs.debug.tx.SIG.data_modulated_symbol_matrix = data_modulated_symbol_matrix;
    configs.debug.tx.SIG.freq_symbol                  = freq_symbol;
    configs.debug.tx.SIG.ifft_input_signal            = ifft_input_signal;
    configs.debug.tx.SIG.ifft_output_signal           = ifft_output_signal;
    configs.debug.tx.SIG.CP_signal                    = CP_signal;
end


end

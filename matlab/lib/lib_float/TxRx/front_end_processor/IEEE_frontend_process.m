function [SIG_pilot_signal_matrix, SIG_data_signal_matrix, PSDU_pilot_signal_matrix, PSDU_data_signal_matrix] = ...
    IEEE_frontend_process(rx_signal_row, SIG_start_index1_est, configs)
%======================================================================================================================%
% Description:
%   前端处理
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.26
%======================================================================================================================%

%% 基本参数初始化
n_fft = configs.common.n_fft;

CP_sample_num   = configs.common.CP_sample_num;
SIG_sample_num  = configs.common.SIG_sample_num;
PSDU_sample_num = configs.common.PSDU_sample_num;
SIG_PSDU_sample_num = SIG_sample_num + PSDU_sample_num;

SIG_ofdm_num  = configs.common.SIG.ofdm_num;
PSDU_ofdm_num = configs.common.PSDU.ofdm_num;
SIG_PSDU_ofdm_num = SIG_ofdm_num + PSDU_ofdm_num;

pilot_tone_index1 = configs.common.pilot_tone_index1;
data_tone_index1  = configs.common.data_tone_index1;


%% 从接收信号中取出SIG/PSDU采样点
rx_SIG_PSDU_signal_row = rx_signal_row(SIG_start_index1_est + (0:SIG_PSDU_sample_num-1));


%% 去CP
rx_SIG_PSDU_signal_matrix = reshape(rx_SIG_PSDU_signal_row, n_fft+CP_sample_num, SIG_PSDU_ofdm_num).';

rx_SIG_PSDU_cpr_signal_matrix = rx_SIG_PSDU_signal_matrix(:, CP_sample_num+(1:n_fft));


% % 理想情况下DEBUG
% assert(sum(sum(abs( rx_SIG_PSDU_cpr_signal_matrix(1:SIG_ofdm_num,:) - ...
%     configs.debug.tx.SIG.ifft_output_signal )))  < 1e-10, '[ERROR] SIG time signal');
% assert(sum(sum(abs( rx_SIG_PSDU_cpr_signal_matrix(SIG_ofdm_num+(1:PSDU_ofdm_num),:) - ...
%     configs.debug.tx.PSDU.ifft_output_signal ))) < 1e-10, '[ERROR] PSDU time signal');


%% 做FFT
% fft_output_signal = fft(rx_SIG_PSDU_cpr_signal_matrix, n_fft, 2) / sqrt(n_fft);  % 逐行做FFT
fft_output_signal = fft(rx_SIG_PSDU_cpr_signal_matrix, n_fft, 2);

FP_signal = circshift(fft_output_signal, n_fft/2, 2);

% % 理想情况下DEBUG
% assert(sum(sum(abs( FP_signal(1:SIG_ofdm_num,:) - ...
%     configs.debug.tx.SIG.freq_symbol )))  < 1e-10, '[ERROR] SIG freq symbols')
% assert(sum(sum(abs( FP_signal(SIG_ofdm_num+(1:PSDU_ofdm_num),:) - ...
%     configs.debug.tx.PSDU.freq_symbol ))) < 1e-10, '[ERROR] PSDU freq symbols')


%% 得到SIG/PSDU的导频和数据
SIG_pilot_signal_matrix = FP_signal(1:SIG_ofdm_num, pilot_tone_index1);
SIG_data_signal_matrix  = FP_signal(1:SIG_ofdm_num, data_tone_index1);

% assert(sum(sum(abs( SIG_pilot_signal_matrix - configs.common.SIG.pilot_modulated_symbol_matrix )))  < 1e-10, ...
%     '[ERROR] SIG pilot');
% assert(sum(sum(abs( SIG_data_signal_matrix  - configs.debug.tx.SIG.data_modulated_symbol_matrix ))) < 1e-10, ...
%     '[ERROR] SIG data');


if PSDU_ofdm_num > 0
    PSDU_pilot_signal_matrix = FP_signal(SIG_ofdm_num+(1:PSDU_ofdm_num), pilot_tone_index1);
    PSDU_data_signal_matrix  = FP_signal(SIG_ofdm_num+(1:PSDU_ofdm_num), data_tone_index1);

    % assert(sum(sum(abs( PSDU_pilot_signal_matrix - configs.common.PSDU.pilot_modulated_symbol_matrix )))  < 1e-10, ...
    %     '[ERROR] PSDU pilot');
    % assert(sum(sum(abs( PSDU_data_signal_matrix  - configs.debug.tx.PSDU.data_modulated_symbol_matrix ))) < 1e-10, ...
    %     '[ERROR] PSDU data');
else
    PSDU_pilot_signal_matrix = [];
    PSDU_data_signal_matrix  = [];
end


end

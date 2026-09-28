function [configs] = IEEE_rx_process(rx_signal, SNR_index, montekarlo_index, configs)
%======================================================================================================================%
% Description:
%   Rx处理流程
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.26
%======================================================================================================================%

%% 参数初始化
frame_type = configs.common.frame_type;
n_fft      = configs.common.n_fft;

results = [];


%% 包检测/定时同步
SIG_start_index1_est = configs.channel.time_offset_front + configs.common.STF_sample_num + ...
    configs.common.LTF_sample_num + 1;


%% 前端处理
[SIG_pilot_signal, SIG_data_signal, PSDU_pilot_signal, PSDU_data_signal] = IEEE_frontend_process( ...
        rx_signal, SIG_start_index1_est, configs);


%% 信道估计



%% 信道均衡
SIG_data_EQ_signal  = SIG_data_signal;
PSDU_data_EQ_signal = PSDU_data_signal;

SIG_CE_signal_abs  = ones(size(SIG_data_EQ_signal));
PSDU_CE_signal_abs = ones(size(PSDU_data_EQ_signal));


%% SIG Rx处理
[results, configs] = SIG_rx_process(SIG_data_EQ_signal, SIG_CE_signal_abs, results, configs);


%% PSDU Rx处理
if strcmp(frame_type, 'IEEE_SOF')
    [results, configs] = PSDU_rx_process(PSDU_data_EQ_signal, PSDU_CE_signal_abs, results, configs);
end


%% 当前仿真结果存储
configs.results{SNR_index,montekarlo_index} = results;


end

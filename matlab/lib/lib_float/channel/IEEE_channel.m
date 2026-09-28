function [rx_signal, configs] = IEEE_channel(tx_signal, sim_index, configs)
%======================================================================================================================%
% Description:
%   RF信道
% Inputs:
%   tx_signal : RF信道输入信号
%   sim_index : awgn_type为1时, 对应SNR索引; awgn_type为2时, 对应信号平均功率索引
%   configs   : 仿真配置参数
% Outputs:
%   tx_signal : RF信道输出信号
%   configs   : 仿真配置参数
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.04.29
%======================================================================================================================%

%% 基本参数初始化
n_fft              = configs.common.n_fft;
sampling_rate_Hz      = configs.common.sampling_rate_Hz;
sampling_duration_s  = configs.common.sampling_duration_s;
subcarrier_spacing_Hz = configs.common.subcarrier_spacing_Hz;

channel_path      = configs.channel.channel_path;
time_offset_front = configs.channel.time_offset_front;
time_offset_end   = configs.channel.time_offset_end;
cfo               = configs.channel.cfo;
ppm               = configs.channel.ppm;
awgn_type         = configs.channel.awgn_type;


%% 计算tx_signal非零元素的起始位置
% RTL比对时, tx_signal是读取DAC文件, 非零元素起始位置不一定是1
norm_tx_signal = abs(tx_signal) / max(abs(tx_signal));
tx_signal_startIndex1 = find(norm_tx_signal > 0.1, 1);


%% 时域卷积信道冲激响应
if channel_path == 1
    normalized_channel_time_response = [1, zeros(1,n_fft-1)];
    normalized_channel_freq_response = fft(normalized_channel_time_response, n_fft) / sqrt(n_fft);

    rx_signal_channel = tx_signal;
else
    [normalized_channel_time_response, normalized_channel_freq_response] = plc_channel_response_generation( ...
        n_fft, subcarrier_spacing_Hz, channel_path);

    rx_signal_channel_cconv = cconv(normalized_channel_time_response, tx_signal, length(tx_signal));

    % 功率保持不变
    tx_LTF1 = tx_signal(tx_signal_startIndex1+0.5*n_fft + (0:n_fft-1));
    tx_LTF1_meanPower = mean(abs(tx_LTF1).^2);

    channel_LTF1 = rx_signal_channel_cconv(tx_signal_startIndex1+0.5*n_fft + (0:n_fft-1));
    channel_LTF1_meanPower = mean(abs(channel_LTF1).^2);

    amplitude_factor  = sqrt( tx_LTF1_meanPower / channel_LTF1_meanPower );
    rx_signal_channel = amplitude_factor * rx_signal_channel_cconv;
end


%% PPDU前后加0
rx_signal_timeOffset  = [zeros(1,time_offset_front), rx_signal_channel, zeros(1,time_offset_end)];
tx_signal_startIndex1 = tx_signal_startIndex1 + time_offset_front;


%% 加CFO
CFO_seq = exp(1j*2*pi*cfo*(0:length(rx_signal_timeOffset)-1)*sampling_duration_s);
rx_signal_CFO = rx_signal_timeOffset .* CFO_seq;


%% 加SFO和SPO, 注意在PPDU前加了随机数量的0, 所以其实无需加SPO了
if ppm ~= 0
    rx_signal_SFO = add_SFO_SPO(rx_signal_CFO, sampling_rate_Hz, ppm, 0);
else
    rx_signal_SFO = rx_signal_CFO;
end


%% 添加AWGN噪声
if awgn_type == 0
    rx_signal_AWGN = rx_signal_SFO;
elseif awgn_type == 1
    rx_signal_AWGN = IEEE_awgn_type1(rx_signal_SFO, sim_index, tx_signal_startIndex1, configs);
else
    error('[ERROR] Invalid awgn_type');
end


%% 信道输出信号
rx_signal = rx_signal_AWGN;


end

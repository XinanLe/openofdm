function output_signal = IEEE_awgn_type1(input_signal, SNR_index, tx_signal_startIndex1, configs)
%======================================================================================================================%
% Description:
%   添加AWGN噪声, type1(配置SNR, 信号+噪声总能量)
% Inputs:
%   input_signal          : 输入信号
%   SNR_index             : 本次仿真的SNR索引
%   tx_signal_startIndex1 : 原始输入信号非零点的起始位置, 用于定位STF2
%   configs               : 仿真配置参数
% Outputs:
%   output_signal : 添加完AWGN噪声的输出信号
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.04.30
%======================================================================================================================%

%% 基本参数初始化
n_fft          = configs.common.n_fft;
valid_tone_num = configs.common.valid_tone_num;

SNR_range = configs.channel.awgn_type1.SNR_range;
SignalNoiseMeanPowerEnable = configs.channel.awgn_type1.SignalNoiseMeanPowerEnable;

input_signal_len = length(input_signal);


%% 加AWGN噪声
SNR_linear = 10 ^ (SNR_range(SNR_index) / 10);  % SNR线性值

std_awgn_noise = (randn(1,input_signal_len) + 1j*randn(1,input_signal_len)) / sqrt(2);  % 标准AWGN噪声
std_awgn_noise_meanPower = (std_awgn_noise * std_awgn_noise') / input_signal_len;  % 全频带平均功率

% 带内平均功率
std_awgn_noise_innerBand_meanPower = std_awgn_noise_meanPower * (valid_tone_num / n_fft);

% 这里不像PLC, 不涉及信号功率减半, 因此不是mean(abs(input_LTF1).^2) / 2
input_LTF1 = input_signal(tx_signal_startIndex1+0.5*n_fft + (0:n_fft-1));
input_LTF1_meanPower = mean(abs(input_LTF1).^2);

% 噪声幅度因子满足:
%   SYNCP3_Input_meanPower / ((noise_amplitude_factor ^ 2) * std_awgn_noise_innerBand_meanPower) = SNR_linear
%   SYNCP3_Input_meanPower = (noise_amplitude_factor ^ 2) * std_awgn_noise_innerBand_meanPower * SNR_linear
%   noise_amplitude_factor = sqrt( SYNCP3_Input_meanPower / (std_awgn_noise_innerBand_meanPower * SNR_linear) )
noise_amplitude_factor = sqrt( input_LTF1_meanPower / (std_awgn_noise_innerBand_meanPower * SNR_linear) );

SignalNoise_signal = input_signal + noise_amplitude_factor * std_awgn_noise;


%% 设置信号噪声平均功率
% voltageAmplitudeFactor
% 电压单位为V, 电阻为50欧
% 当前信号噪声功率为: current_SignalNoiseMeanPower = (active_tone_num / n_fft + noise_amplitude_factor^2) / 50 W
% 即: current_SignalNoiseMeanPower * 1e3 mW
% 即: 10*log10(current_SignalNoiseMeanPower * 1e3) dBm = 10*log10(current_SignalNoiseMeanPower) + 30 dBm
% 若想要将其变成SignalNoiseMeanPower dBm, 需要在SignalNoise_signal乘一个幅度因子amplitudeFactor, 满足:
% 10*log10((amplitudeFactor^2) * current_SignalNoiseMeanPower) + 30 = SignalNoiseMeanPower
% 20*log10(amplitudeFactor) = SignalNoiseMeanPower - 30 - 10*log10(current_SignalNoiseMeanPower)
% amplitudeFactor = 10 ^ ((SignalNoiseMeanPower - 30 - 10*log10(current_SignalNoiseMeanPower)) / 20)

if SignalNoiseMeanPowerEnable
    SignalNoise_LTF1 = SignalNoise_signal(tx_signal_startIndex1+0.5*n_fft + (0:n_fft-1));
    SignalNoise_LTF1_meanPower = mean(abs(SignalNoise_LTF1).^2) / 50;

    amplitudeFactor = 10 ^ ((configs.channel.awgn_type1.SignalNoiseMeanPower - 30 - 10*log10(SignalNoise_LTF1_meanPower)) / 20);
else
    amplitudeFactor = 1;
end
output_signal = amplitudeFactor * SignalNoise_signal;

% Debug: 测试一下STF1的信号噪声功率
output_LTF1 = output_signal(tx_signal_startIndex1+0.5*n_fft + (0:n_fft-1));
output_LTF1_meanPower_W   = mean(abs(output_LTF1).^2) / 50;
output_LTF1_meanPower_dBm = 10*log10(output_LTF1_meanPower_W) + 30;


end

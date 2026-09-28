function output_signal = add_SFO_SPO(input_signal, nominal_sampling_rate, ppm, alpha)
%======================================================================================================================%
% Description:
%   对输入信号加采样时钟偏差(Sampling clock Frequency Offset, SFO)和采样相位偏差(Sampling clock Phase Offset, SPO)
% Inputs:
%   input_signal          : 输入信号, PPDU帧, 行向量
%   nominal_sampling_rate : 标称采样频率, 25e6/75e6 Hz
%   ppm   : SFO
%   alpha : SPO
% Outputs:
%   configs : 仿真配置参数
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2025.12.01
%======================================================================================================================%

%% 基本参数初始化
nominal_sampling_num = length(input_signal);  % 标称采样频率得到的采样点数

actual_sampling_rate = nominal_sampling_rate * (1 + ppm*1e-6);  % 实际采样频率

% 相邻采样点采样时间间隔, 单位: 秒
nominal_Ts = 1 / nominal_sampling_rate;
actual_Ts  = 1 / actual_sampling_rate;

% PPDU帧长, 单位: 秒
PPDU_time = nominal_sampling_num * nominal_Ts;

% 实际采样频率得到的采样点数
actual_sampling_num = floor(PPDU_time/actual_Ts);

% 采样时刻, 单位: 秒
nominal_sampling_time = (0:nominal_sampling_num-1) * nominal_Ts;
actual_sampling_time  = (0:actual_sampling_num-1) * actual_Ts + alpha * actual_Ts;


%% 插值
output_signal = interp1(nominal_sampling_time, input_signal, actual_sampling_time, 'spline', 'extrap');


end
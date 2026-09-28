function [normalized_channel_time_response, normalized_channel_freq_response] = ...
    plc_channel_response_generation(n_fft_DAC, subcarrier_spacing_Hz, channel_path)
%======================================================================================================================%
% Description:
%   产生PLC信道的归一化时域脉冲响应和归一化频域响应
% Inputs:
%   configs : 仿真配置参数
% Outputs:
%   normalized_channel_time_response : 归一化时域脉冲响应
%   normalized_channel_freq_response : 归一化频域响应
% References:
%   1. IEEE Std 1901.1.1(TM)-2020附录A.1.1(只用了参数取值, 公式是错的)
%   2. (2002_Zimmermann) A Multipath Model for The Powerline Channel式(10)
%   3. IEEE Std 1901(TM)-2020附录F.3.3.1(公式(F-1)是对的, 但是alpha(f)的具体表达式没给)
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2025.12.02
%======================================================================================================================%

%% 多径信道响应参数
switch channel_path
    case 4
        d = [200, 222.4, 244.8, 267.5];  % 各个路径的距离(从小到大排列)
        g = [0.64, 0.38, -0.15, 0.05];  % 各个路径的加权因子
        a0 = 3e-5;  % 衰减参数
        a1 = 7.8e-10;  % 衰减参数
        k = 1;  % 衰减因子的指数, 通常取值为集合[0.5, 1]
    case 5
        d = [100, 130, 160, 190, 300];
        g = [0.09, -0.012, 0.012, -0.012, 0.022];
        a0 = 0;
        a1 = 1.65e-9;
        k = 1;
    case 17
        d = [150.8, 152.3, 172, 210.4, 230, 258, 294, 370, 400, 435, 468, 494, 534, 581, 632, 1070, 1224];
        g = [-0.15, 0.165, 0.032, -0.014, -0.035, -0.035, -0.03, 0.015, 0.022, 0.04, 0.02, ...
            -0.015, 0.0865, -0.062, -0.083, 0.05, -0.035];
        a0 = 0;
        a1 = 2.8e-9;
        k = 1;
    otherwise
        error('[ERROR] Do not support this path number at yet.');
end
epsilon = 4;  % 绝缘材料的介电常数(取值参考CQUPT的代码)
C0 = 3e8;  % 光速
tau = d * sqrt(epsilon) / C0;  % 各个路径的时延


%% PLC信道频域响应, 公式参考论文"(2002_Zimmermann) A Multipath Model for The Powerline Channel"式(10)
f = (0:n_fft_DAC-1) * subcarrier_spacing_Hz;  % 频率, 单位Hz
alpha_f = a0 + a1*(f.^k);  % 可能是这一项导致代码和IEEE Std 1901.1.1(TM)-2020附录A.1.1不一致
channel_freq_response_all_path = (g.') .* exp(-alpha_f.*(d.')) .* exp(-1j*2*pi*f.*(tau.'));  % 每一行对应一条路径
channel_freq_response = sum(channel_freq_response_all_path, 1);  % 所有行相加

normalized_channel_freq_response = channel_freq_response / sqrt(channel_freq_response*channel_freq_response');

% % Debug
% figure();  set(0, 'defaultfigurecolor', 'white');
% plot(10*log10(abs(normalized_channel_freq_response))+20, '-blue', 'LineWidth', 1);  grid on;
% axis = gca;  % 获取当前的坐标轴对象(看MATLAB文档: Axes属性)
% axis.Title.String = [num2str(channel_path), '径信道的频域响应'];
% axis.XLabel.String = 'Frequency Samples';
% axis.YLabel.String = '|H(f)| in dB';


%% PLC信道时域冲激响应
normalized_channel_time_response = sqrt(n_fft_DAC) * ifft(normalized_channel_freq_response, n_fft_DAC);

% % Debug
% figure();  set(0, 'defaultfigurecolor', 'white');
% plot(abs(normalized_channel_time_response), '-red', 'LineWidth', 1);  grid on;
% axis = gca;  % 获取当前的坐标轴对象(看MATLAB文档: Axes属性)
% axis.Title.String = [num2str(channel_path), '径信道的时域响应'];
% axis.XLabel.String = 'Time Samples';
% axis.YLabel.String = '|h(t)| in linear';


end

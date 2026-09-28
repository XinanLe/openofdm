function configs = parameters_init_allFrame(configs)
%======================================================================================================================%
% Description:
%   parameters_init_allFrame()实现仿真参数初始化, 这里的参数都是无需修改代码的
% Inputs:
%   configs : 仿真配置参数
% Outputs:
%   configs : 仿真配置参数
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2024.11.15
%======================================================================================================================%

%% SIGNAL参数配置
configs.common.SIG.bit_num_per_subcarrier = 1;
configs.common.SIG.code_rate              = 1/2;

configs.common.SIG.coded_bit_num_per_OFDM  = 48;
configs.common.SIG.source_bit_num_per_OFDM = 24;

configs.common.SIG.source_bit_num = 24;
configs.common.SIG.coded_bit_num  = 48;

configs.common.SIG.ofdm_num = 1;

configs.common.SIG.source_bit_row = SIG_source_bit_generation(configs.common.channel_spacing_Mhz, ...
    configs.common.PSDU.data_rate_Mbps, configs.common.PSDU.byte_num);


%% STF参数
configs.tx.STF.ofdm_repeat_num = 4;


%% SIGNAL和PSDU的pilot内容
scrambled_bit_col  = scrambler_descrambler(zeros(1,127*2), ones(1,7)).';
pilot_polarity_col = scrambled_bit_col * (-2) + 1;  % 0变成1, 1变成-1

configs.common.SIG.pilot_modulated_symbol_matrix  = [1, 1, 1, -1];  % pilot_polarity_col(1)是1

% 2:127, 1:127, 1:127, ...
configs.common.PSDU.pilot_modulated_symbol_matrix = ...
    [1, 1, 1, -1] .* pilot_polarity_col(mod(1:configs.common.PSDU.ofdm_num, 127) + 1);


%% 公共参数
configs.common.sampling_rate_Hz      = (configs.common.channel_spacing_Mhz * 1e6);
configs.common.sampling_duration_s   = 1 / configs.common.sampling_rate_Hz;
configs.common.subcarrier_spacing_Hz = (configs.common.channel_spacing_Mhz * 1e6) / configs.common.n_fft;

configs.common.invalid_tone_index0 = [-configs.common.n_fft/2 : -27, 0, 27 : configs.common.n_fft/2-1];
configs.common.pilot_tone_index0   = [-21, -7, 7, 21];
configs.common.data_tone_index0    = setdiff(-configs.common.n_fft/2 : configs.common.n_fft/2-1, ...
    [configs.common.invalid_tone_index0, configs.common.pilot_tone_index0]);

configs.common.invalid_tone_index1 = configs.common.invalid_tone_index0 + configs.common.n_fft/2 + 1;
configs.common.pilot_tone_index1   = configs.common.pilot_tone_index0   + configs.common.n_fft/2 + 1;
configs.common.data_tone_index1    = configs.common.data_tone_index0    + configs.common.n_fft/2 + 1;

configs.common.CP_sample_num   = configs.common.n_fft / 4;
configs.common.STF_sample_num  = 2.5 * configs.common.n_fft;
configs.common.LTF_sample_num  = 2.5 * configs.common.n_fft;
configs.common.SIG_sample_num  = configs.common.SIG.ofdm_num  * (configs.common.CP_sample_num + configs.common.n_fft);
configs.common.PSDU_sample_num = configs.common.PSDU.ofdm_num * (configs.common.CP_sample_num + configs.common.n_fft);
configs.common.PPDU_sample_num = configs.common.STF_sample_num + configs.common.LTF_sample_num + ...
    configs.common.SIG_sample_num + configs.common.PSDU_sample_num;

configs.common.PPDU_time_us = configs.common.PPDU_sample_num / configs.common.channel_spacing_Mhz;


end

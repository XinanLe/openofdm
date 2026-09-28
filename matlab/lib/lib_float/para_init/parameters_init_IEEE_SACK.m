function configs = parameters_init_IEEE_SACK(configs)
%======================================================================================================================%
% Description:
%   计算IEEE_SACK帧的字段, 不可修改
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.03.27
%======================================================================================================================%

%% 公共参数
configs.common.n_fft            = 64;
configs.common.valid_tone_num   = 52;
configs.common.invalid_tone_num = 12;
configs.common.pilot_tone_num   = 4;
configs.common.data_tone_num    = 48;


%% PSDU
configs.common.PSDU.data_rate_Mbps               = 0;
configs.common.PSDU.byte_num                     = 0;
configs.common.PSDU.scrambler_shift_register_dec = [];
configs.common.PSDU.scrambler_shift_register_bin = [];

configs.common.PSDU.bit_num_per_subcarrier  = 0;
configs.common.PSDU.code_rate               = [];
configs.common.PSDU.coded_bit_num_per_OFDM  = [];
configs.common.PSDU.source_bit_num_per_OFDM = [];
configs.common.PSDU.service_bit_num         = 0;
configs.common.PSDU.PSDU_bit_num            = 0;
configs.common.PSDU.tail_bit_num            = 0;
configs.common.PSDU.pad_bit_num             = 0;
configs.common.PSDU.source_bit_num          = 0;
configs.common.PSDU.coded_bit_num           = 0;
configs.common.PSDU.ofdm_num                = 0;


end

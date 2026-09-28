function configs = parameters_init_IEEE_SOF(configs)
%======================================================================================================================%
% Description:
%   计算IEEE_SOF帧的字段, 不可修改
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.24
%======================================================================================================================%

%% 公共参数
configs.common.n_fft            = 64;
configs.common.valid_tone_num   = 52;
configs.common.invalid_tone_num = 12;
configs.common.pilot_tone_num   = 4;
configs.common.data_tone_num    = 48;


%% PSDU
% service(16 bit) + PSDU(byte_num*8 bit) + tail(6 bit) + pad(need calculate)

% bit_num_per_subcarrier : 每个子载波承载的比特数, 调制阶数
% code_rate              : 信道编码码率
[configs.common.PSDU.bit_num_per_subcarrier, configs.common.PSDU.code_rate] = sparse_data_rate( ...
    configs.common.PSDU.data_rate_Mbps, configs.common.channel_spacing_Mhz);

% 每个OFDM符号承载的编码后比特数
configs.common.PSDU.coded_bit_num_per_OFDM = configs.common.data_tone_num * ...
    configs.common.PSDU.bit_num_per_subcarrier;

% PSDU每个OFDM符号承载的原始比特数
configs.common.PSDU.source_bit_num_per_OFDM = configs.common.PSDU.coded_bit_num_per_OFDM * ...
    configs.common.PSDU.code_rate;

configs.common.PSDU.service_bit_num = 16;
configs.common.PSDU.PSDU_bit_num    = 8 * configs.common.PSDU.byte_num;
configs.common.PSDU.tail_bit_num    = 6;
service_PSDU_tail_bit_num           = configs.common.PSDU.service_bit_num + ...
    configs.common.PSDU.PSDU_bit_num + configs.common.PSDU.tail_bit_num;
configs.common.PSDU.pad_bit_num     = ceil(service_PSDU_tail_bit_num / configs.common.PSDU.source_bit_num_per_OFDM) * ...
    configs.common.PSDU.source_bit_num_per_OFDM - service_PSDU_tail_bit_num;
configs.common.PSDU.source_bit_num  = configs.common.PSDU.service_bit_num + configs.common.PSDU.PSDU_bit_num + ...
    configs.common.PSDU.tail_bit_num + configs.common.PSDU.pad_bit_num;
configs.common.PSDU.coded_bit_num   = configs.common.PSDU.source_bit_num / configs.common.PSDU.code_rate;

% PSDU的OFDM符号数量
configs.common.PSDU.ofdm_num = configs.common.PSDU.source_bit_num / configs.common.PSDU.source_bit_num_per_OFDM;
assert(configs.common.PSDU.ofdm_num == configs.common.PSDU.coded_bit_num / configs.common.PSDU.coded_bit_num_per_OFDM, ...
    '[ERROR] Invalid PSDU ofdm_num');


end

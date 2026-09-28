function [results, configs] = PSDU_rx_process(data_EQ_signal, CE_signal_abs, results, configs)
%======================================================================================================================%
% Description:
%   PSDU接收端处理
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.28
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

scrambler_shift_register_bin = configs.common.PSDU.scrambler_shift_register_bin;
bit_num_per_subcarrier       = configs.common.PSDU.bit_num_per_subcarrier;
code_rate                    = configs.common.PSDU.code_rate;
coded_bit_num_per_OFDM       = configs.common.PSDU.coded_bit_num_per_OFDM;
% source_bit_num_per_OFDM      = configs.common.PSDU.source_bit_num_per_OFDM;
service_bit_num              = configs.common.PSDU.service_bit_num;
PSDU_bit_num                 = configs.common.PSDU.PSDU_bit_num;
PSDU_bit_row                 = configs.common.PSDU.PSDU_bit_row;
tail_bit_num                 = configs.common.PSDU.tail_bit_num;
pad_bit_num                  = configs.common.PSDU.pad_bit_num;
% source_bit_num               = configs.common.PSDU.source_bit_num;
coded_bit_num                = configs.common.PSDU.coded_bit_num;
ofdm_num                     = configs.common.PSDU.ofdm_num;

PSDU_traceback_depth = configs.rx.turbo_decoder.PSDU_traceback_depth;


%% 解调
data_EQ_signal_row = reshape(data_EQ_signal.', 1, []);
CE_signal_abs_row  = reshape(CE_signal_abs.', 1, []);

if configs.rx.ChannelEstimation.enable && configs.rx.ChannelEqualization.enable
    if strcmp(configs.rx.ChannelEqualization.method, 'phase')
        % 信道均衡只补phase
        [soft_info_depunctured_row, ~] = de_modulator_phase(data_EQ_signal_row, CE_signal_abs_row, bit_num_per_subcarrier);
    elseif strcmp(configs.rx.ChannelEqualization.method, 'amp_phase')
        % 信道均衡amp和phase都补
        [soft_info_depunctured_row, ~] = de_modulator(data_EQ_signal_row, bit_num_per_subcarrier);
    else
        error('[ERROR] Invalid ChannelEqualization method');
    end
else
    [soft_info_depunctured_row, ~] = de_modulator(data_EQ_signal_row, bit_num_per_subcarrier);
end

soft_info_demodu_row = soft_info_depunctured_row;

% assert(sum(abs( double(soft_info_demodu_row<0)-configs.debug.tx.PSDU.interleaved_bit_row )) == 0, ...
%     '[ERROR] PSDU de-modulator');


%% 解信道交织
soft_info_demodu_matrix = reshape(soft_info_demodu_row, coded_bit_num_per_OFDM, ofdm_num).';

interlever_pattern     = interleaver_pattern_generation(coded_bit_num_per_OFDM, bit_num_per_subcarrier);
soft_info_deinterleaved_matrix = zeros(ofdm_num, coded_bit_num_per_OFDM);
soft_info_deinterleaved_matrix(:, interlever_pattern) = soft_info_demodu_matrix;

soft_info_deinterleaved_row = reshape(soft_info_deinterleaved_matrix.', 1, coded_bit_num);

% assert(sum(abs( double(soft_info_deinterleaved_row<0)-configs.debug.tx.PSDU.punctured_bit_row )) == 0, ...
%     '[ERROR] PSDU de-interlever');


%% 解打孔, 去掉pad比特
% 现在编码码率是1/2
soft_info_depunctured_row  = de_puncture(soft_info_deinterleaved_row, code_rate);

% 去掉pad比特
soft_info_decoderInput_row = soft_info_depunctured_row(1:end-2*pad_bit_num);


%% 信道译码
trellis = poly2trellis(7, [133 171]);
decoded_bit_row = vitdec(soft_info_decoderInput_row.', trellis, PSDU_traceback_depth, 'term', 'unquant').';


%% 解扰
scrambler_shift_register_est = get_scrambler_shift_register(decoded_bit_row(1:7));

descrambled_bit_row = scrambler_descrambler(decoded_bit_row, scrambler_shift_register_est);


%% 仿真结果统计
rx_PSDU_bit_row = descrambled_bit_row(service_bit_num + (1:PSDU_bit_num));

results.PSDU_bit_error_number = sum(abs( rx_PSDU_bit_row - PSDU_bit_row ));

if results.PSDU_bit_error_number == 0
    results.PSDU_block_error_num = 0;
else
    results.PSDU_block_error_num = 1;
end

results.PSDU_CRC_error_num = crc_decoder(rx_PSDU_bit_row, 'CRC32');


end

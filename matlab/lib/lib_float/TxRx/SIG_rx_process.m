function [results, configs] = SIG_rx_process(data_EQ_signal, CE_signal_abs, results, configs)
%======================================================================================================================%
% Description:
%   SIG接收端处理
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.28
%======================================================================================================================%

%% 参数初始化
bit_num_per_subcarrier  = configs.common.SIG.bit_num_per_subcarrier;
% code_rate               = configs.common.SIG.code_rate;
coded_bit_num_per_OFDM  = configs.common.SIG.coded_bit_num_per_OFDM;
% source_bit_num_per_OFDM = configs.common.SIG.source_bit_num_per_OFDM;
% source_bit_num          = configs.common.SIG.source_bit_num;
source_bit_row          = configs.common.SIG.source_bit_row;
coded_bit_num           = configs.common.SIG.coded_bit_num;
ofdm_num                = configs.common.SIG.ofdm_num;

SIG_traceback_depth = configs.rx.turbo_decoder.SIG_traceback_depth;


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

% % 这里取负则软信息表示ln[Pr(bit = 1)/Pr(bit = 0)]
% soft_info_demodu = -soft_info_row;
% hard_bits_demodu = double(soft_info_demodu > 0);
% assert(sum(abs( hard_bits_demodu-configs.debug.tx.SIG.interleaved_bit_row )) == 0, '[ERROR] de-modulator');

soft_info_demodu_row = soft_info_depunctured_row;

% assert(sum(abs( double(soft_info_demodu_row<0)-configs.debug.tx.SIG.interleaved_bit_row )) == 0, ...
%     '[ERROR] SIG de-modulator');


%% 解信道交织
soft_info_demodu_matrix = reshape(soft_info_demodu_row, coded_bit_num_per_OFDM, ofdm_num).';

interlever_pattern     = interleaver_pattern_generation(coded_bit_num_per_OFDM, bit_num_per_subcarrier);
soft_info_deinterleaved_matrix = zeros(ofdm_num, coded_bit_num_per_OFDM);
soft_info_deinterleaved_matrix(:, interlever_pattern) = soft_info_demodu_matrix;

soft_info_deinterleaved_row = reshape(soft_info_deinterleaved_matrix.', 1, coded_bit_num);

% assert(sum(abs( double(soft_info_deinterleaved_row<0)-configs.debug.tx.SIG.punctured_bit_row )) == 0, ...
%     '[ERROR] SIG de-interlever');


%% 解打孔
% % 现在编码码率是1/2
% soft_info_depunctured_row  = de_puncture(soft_info_deinterleaved_row, code_rate);
% soft_info_decoderInput_row = soft_info_depunctured_row;

% 透传, SIG的码率为1/2, 原始信息比特不涉及pad
soft_info_decoderInput_row = soft_info_deinterleaved_row;


%% 信道译码
trellis = poly2trellis(7, [133 171]);
decoded_bit_row = vitdec(soft_info_decoderInput_row.', trellis, SIG_traceback_depth, 'term', 'unquant').';


%% 仿真结果统计
results.SIG_bit_error_number = sum(abs( decoded_bit_row - source_bit_row ));

if results.SIG_bit_error_number == 0
    results.SIG_block_error_num = 0;
else
    results.SIG_block_error_num = 1;
end


end

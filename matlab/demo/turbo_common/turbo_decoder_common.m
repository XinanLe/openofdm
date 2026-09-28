function [decode_bits, performed_iteration_num] = turbo_decoder_common(soft_info, decoder_type, max_iteration_num, ...
    iteration_termination_enable, PB_type, code_rate, spec_version, signal_type)
%======================================================================================================================%
% Description:
%   Turbo译码器
% Inputs:
%   soft_info         : 单PB块的软信息, 行向量
%   decoder_type      : 译码算法类型, {'MAX-Log-MAP-CQUPT', 'MAX-Log-MAP', 'Log-MAP'}
%   max_iteration_num : 译码算法最大迭代次数, 值为0.5的倍数, 0.5表示半迭代
%   iteration_termination_enable : 译码算法是否配置提前迭代终止
%   PB_type           : PB类型
%   code_rate         : 信道编码码率, {'1/2', '16/18'}
%   spec_version      : 协议版本
%   signal_type       : {'FC', 'PL'}用于确定提前迭代终止时是否需要解扰
% Outputs:
%   decode_bits             : 译码结果
%   performed_iteration_num : Turbo译码器实际的迭代次数
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2025.10.11
%======================================================================================================================%

% 若配置提前迭代终止, 则需要配置CRC类型(IEEE1901的PL是CRC32, 别的都是CRC24), 以及译码结果是否需要解扰后做CRC校验
%   FC/PHR  : 任何协议都无需解扰
%   PL/PSDU : SG1P0/SG2P0/IEEE1901需要解扰, SPG1P0/SPG2P0无需解扰

if iteration_termination_enable
    if strcmp(signal_type, 'FC') || strcmp(signal_type, 'PHR')
        descreambleFlag = 0;
        CRCType = 'CRC24';
    elseif strcmp(signal_type, 'PL') || strcmp(signal_type, 'PSDU')
        if strcmp(spec_version, 'SG1P0') || strcmp(spec_version, 'SG2P0')
            descreambleFlag = 1;
            CRCType = 'CRC24';
        elseif strcmp(spec_version, 'IEEE1901')
            descreambleFlag = 1;
            CRCType = 'CRC32';
        elseif strcmp(spec_version, 'SPG1P0') || strcmp(spec_version, 'SPG2P0')
            descreambleFlag = 0;
            CRCType = 'CRC24';
        else
            error('[ERROR] Invalid Spec');
        end
    else
        error('[ERROR] Invalid Signal Type');
    end

    if strcmp(decoder_type, 'MAX-Log-MAP-CQUPT')
        [decode_bits, performed_iteration_num] = turbo_decoder_common_MAX_Log_MAP_CQUPT( ...
            soft_info, PB_type, code_rate, max_iteration_num, spec_version, CRCType, descreambleFlag);
    elseif strcmp(decoder_type, 'MAX-Log-MAP')
        [decode_bits, performed_iteration_num] = turbo_decoder_common_MAX_Log_MAP( ...
            soft_info, PB_type, code_rate, max_iteration_num, spec_version, CRCType, descreambleFlag);
    elseif strcmp(decoder_type, 'Log-MAP')
        [decode_bits, performed_iteration_num] = turbo_decoder_common_Log_MAP( ...
            soft_info, PB_type, code_rate, max_iteration_num, spec_version, CRCType, descreambleFlag);
    else
        error('Invalid decoder_type');
    end
else
    if strcmp(decoder_type, 'MAX-Log-MAP-CQUPT')
        [decode_bits, performed_iteration_num] = turbo_decoder_common_MAX_Log_MAP_CQUPT( ...
            soft_info, PB_type, code_rate, max_iteration_num, spec_version);
    elseif strcmp(decoder_type, 'MAX-Log-MAP')
        [decode_bits, performed_iteration_num] = turbo_decoder_common_MAX_Log_MAP( ...
            soft_info, PB_type, code_rate, max_iteration_num, spec_version);
    elseif strcmp(decoder_type, 'Log-MAP')
        [decode_bits, performed_iteration_num] = turbo_decoder_common_Log_MAP( ...
            soft_info, PB_type, code_rate, max_iteration_num, spec_version);
    else
        error('Invalid decoder_type');
    end
end


end

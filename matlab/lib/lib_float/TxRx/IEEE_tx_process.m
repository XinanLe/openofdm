function [tx_signal, configs] = IEEE_tx_process(configs)
%======================================================================================================================%
% Description:
%   Tx处理流程
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.24
%======================================================================================================================%

%% 参数初始化
frame_type = configs.common.frame_type;


%% STF时域信号
[STF_CP_signal, configs] = STF_tx_process(configs);


%% LTF时域信号
[LTF_CP_signal, configs] = LTF_tx_process(configs);


%% SIGNAL时域信号
[SIG_CP_signal, configs] = SIG_tx_process(configs);


%% PSDU时域信号
if strcmp(frame_type, 'IEEE_SOF')
    [PSDU_CP_signal, configs] = PSDU_tx_process(configs);
else
    PSDU_CP_signal = [];
end


%% PPDU帧
tx_signal = [STF_CP_signal, LTF_CP_signal, reshape(SIG_CP_signal.', 1, []), reshape(PSDU_CP_signal.', 1, [])];

if configs.testmat.MATLAB_debug
    configs.debug.tx.tx_signal = tx_signal;
end

assert(length(tx_signal) == configs.common.PPDU_sample_num, '[ERROR] Invalid PPDU_sample_num');


end

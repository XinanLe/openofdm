function [CP_signal, configs] = STF_tx_process(configs)
%======================================================================================================================%
% Description:
%   产生STF时域信号
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.24
%======================================================================================================================%

%% 参数初始化
n_fft = configs.common.n_fft;

ofdm_repeat_num = configs.tx.STF.ofdm_repeat_num;


%% 频域调制符号
freq_symbol = [0,     0, 0, 0, 0,     0, 0, 0, ...
               1+1i,  0, 0, 0, -1-1i, 0, 0, 0, ...
               1+1i,  0, 0, 0, -1-1i, 0, 0, 0, ...
               -1-1i, 0, 0, 0, 1+1i,  0, 0, 0, ...
               0,     0, 0, 0, -1-1i, 0, 0, 0, ...
               -1-1i, 0, 0, 0, 1+1i,  0, 0, 0, ...
               1+1i,  0, 0, 0, 1+1i,  0, 0, 0, ...
               1+1i,  0, 0, 0, 0,     0, 0, 0] * sqrt(13/6);


%% IFFT得到时域信号
ifft_input_signal = circshift(freq_symbol, -n_fft/2);

% ifft_output_signal = sqrt(n_fft) * ifft(ifft_input_signal, n_fft, 2);
ifft_output_signal = ifft(ifft_input_signal, n_fft, 2);
assert(matrix_row_same_check(reshape(ifft_output_signal, [], ofdm_repeat_num).') == 1, ...
    '[ERROR] invalid STF repeat structure');


%% 产生STF信号
CP_signal = [ifft_output_signal(n_fft/2+1:n_fft), ifft_output_signal, ifft_output_signal];


%% configs.debug
if configs.testmat.MATLAB_debug
    configs.debug.tx.STF.freq_symbol        = freq_symbol;
    configs.debug.tx.STF.ifft_input_signal  = ifft_input_signal;
    configs.debug.tx.STF.ifft_output_signal = ifft_output_signal;
    configs.debug.tx.STF.CP_signal          = CP_signal;
end


end

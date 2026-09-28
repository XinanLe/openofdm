function [CP_signal, configs] = LTF_tx_process(configs)
%======================================================================================================================%
% Description:
%   产生LTF时域信号
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.24
%======================================================================================================================%

%% 参数初始化
n_fft = configs.common.n_fft;


%% 频域调制符号
freq_symbol = [0,  0,  0,  0,  0,  0,  1,  1, ...
              -1, -1,  1,  1, -1,  1, -1,  1, ...
               1,  1,  1,  1,  1, -1, -1,  1, ...
               1, -1,  1, -1,  1,  1,  1,  1, ...
               0,  1, -1, -1,  1,  1, -1,  1, ...
              -1,  1, -1, -1, -1, -1, -1,  1, ...
               1, -1, -1,  1, -1,  1, -1,  1, ...
               1,  1,  1,  0,  0,  0,  0,  0];


%% IFFT得到时域信号
ifft_input_signal = circshift(freq_symbol, -n_fft/2);

% ifft_output_signal = sqrt(n_fft) * ifft(ifft_input_signal, n_fft, 2);
ifft_output_signal = ifft(ifft_input_signal, n_fft, 2);


%% 产生LTF信号
CP_signal = [ifft_output_signal(n_fft/2+1:n_fft), ifft_output_signal, ifft_output_signal];


%% configs.debug
if configs.testmat.MATLAB_debug
    configs.debug.tx.LTF.freq_symbol        = freq_symbol;
    configs.debug.tx.LTF.ifft_input_signal  = ifft_input_signal;
    configs.debug.tx.LTF.ifft_output_signal = ifft_output_signal;
    configs.debug.tx.LTF.CP_signal          = CP_signal;
end


end

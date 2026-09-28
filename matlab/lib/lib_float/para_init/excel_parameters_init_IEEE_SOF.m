function configs = excel_parameters_init_IEEE_SOF(configs)
%======================================================================================================================%
% Description:
%   配置IEEE_SOF帧的字段, 可修改
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.24
%======================================================================================================================%

%% PSDU
% 20 MHz: [6,   9,    12, 18,  24, 36, 48, 54  ]
% 10 MHz: [3,   4.5,  6,  9,   12, 18, 24, 27  ]
% 5  MHz: [1.5, 2.25, 3,  4.5, 6,  9,  12, 13.5]
configs.common.PSDU.data_rate_Mbps = 18;

configs.common.PSDU.byte_num = 100;  % SIGNAL的12比特字段, 范围限制0:4095, 由于存在CRC32, 范围限制5:4095

% shift_register(1:7)存的是x1,x2,...,x7, 要求是非零随机值
configs.common.PSDU.scrambler_shift_register_dec = randi([1,127],1,1);
configs.common.PSDU.scrambler_shift_register_bin = ...
    fliplr(dec2bin(configs.common.PSDU.scrambler_shift_register_dec, 7) - '0');


end

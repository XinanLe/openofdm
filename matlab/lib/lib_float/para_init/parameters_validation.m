function parameters_validation(configs)
%======================================================================================================================%
% Description:
%   configs的参数校验
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.04
%======================================================================================================================%

% 多次仿真需关闭画图
if configs.simu.montekarlo_num > 3 && configs.testmat.plot_enable
    error('[ERROR] Dismatch between montekarlo_num and plot_enable');
end

if strcmp(configs.common.frame_type, 'IEEE_SOF')
    assert(configs.common.PSDU.byte_num >= 5 && configs.common.PSDU.byte_num <= 4095, '[ERROR] Invalid PSDU byte_num');
end


end

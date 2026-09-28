function error_flag = crc_decoder(input_data_row, crc_type)
%======================================================================================================================%
% Description:
%   调用MATLAB函数库对输入比特序列做CRC校验
% Inputs:
%   input_data_row : 输入比特序列, 行向量
%   crc_type       : CRC类型, {'CRC32', 'CRC24'}
% Outputs:
%   error_flag : CRC校验结果, 0-CRC校验通过; 1-CRC校验未通过
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2025.09.08
%======================================================================================================================%

%% 输入参数判断
assert(isrow(input_data_row), 'Input must be row.');  % 要求输入为行向量


%% 产生生成多项式
switch crc_type
    case 'CRC32'
        poly = 'z^32 + z^26 + z^23 + z^22 + z^16 + z^12 + z^11 + z^10 + z^8 + z^7 + z^5 + z^4 + z^2 + z + 1';
    otherwise
        error('[ERROR] Invalid crc_type');
end


%% CRC校验
crcdetector     = comm.CRCDetector(poly, 'InitialConditions', true(1,32), ...
    'FinalXOR', true(1,32), 'DirectMethod', true);
[~, error_flag] = crcdetector(input_data_row.');  % MATLAB库函数输入为列向量


end

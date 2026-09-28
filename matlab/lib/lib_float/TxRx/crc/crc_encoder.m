function output_data_row = crc_encoder(input_data_row, crc_type)
%======================================================================================================================%
% Description:
%   调用MATLAB函数库对输入比特序列添加CRC校验比特
% Inputs:
%   input_data_row : 输入比特序列, 行向量
%   crc_type       : CRC类型, {'CRC32', 'CRC24'}
% Outputs:
%   output_data_row : 输出比特序列, 行向量, CRC校验比特加在输入比特序列之后
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2025.09.08
%======================================================================================================================%

%% 入参判断
assert(isrow(input_data_row), 'Input must be row.');  % 要求输入为行向量


%% 生成多项式
switch crc_type
    case 'CRC32'
        poly = 'z^32 + z^26 + z^23 + z^22 + z^16 + z^12 + z^11 + z^10 + z^8 + z^7 + z^5 + z^4 + z^2 + z + 1';
    otherwise
        error('[ERROR] Invalid crc_type');
end


%% 添加CRC
crcgenerator    = comm.CRCGenerator(poly, 'InitialConditions', true(1,32), ...
    'FinalXOR', true(1,32), 'DirectMethod', true);
output_data_row = crcgenerator(input_data_row.');  % MATLAB库函数输入输出都是列向量
output_data_row = output_data_row.';


end

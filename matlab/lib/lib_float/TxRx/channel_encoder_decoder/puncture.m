function punctured_bit_row = puncture(coded_bit_row, code_rate)
%======================================================================================================================%
% Description:
%   信道编码的打孔
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.22
%======================================================================================================================%

%% 打孔
if code_rate == 1/2
    punctured_bit_row = coded_bit_row;
elseif code_rate == 2/3
    % 每一行都是A0,B0,A1,B1,...,A5,B5
    coded_bit_matrix = reshape(coded_bit_row, 12, []).';

    % 打掉B1,B3,B5
    punctured_index1 = [4,8,12];

    % 打孔
    punctured_bit_matrix = coded_bit_matrix;
    punctured_bit_matrix(:,punctured_index1) = [];
    punctured_bit_row = reshape(punctured_bit_matrix.', 1, []);
elseif code_rate == 3/4
    % 每一行都是A0,B0,A1,B1,...,A8,B8
    coded_bit_matrix = reshape(coded_bit_row, 18, []).';

    % 打掉B1,A2,B4,A5,B7,A8
    punctured_index1 = [4,5,10,11,16,17];

    % 打孔
    punctured_bit_matrix = coded_bit_matrix;
    punctured_bit_matrix(:,punctured_index1) = [];
    punctured_bit_row = reshape(punctured_bit_matrix.', 1, []);
else
    error('[ERROR] Invalid code_rate');
end


end

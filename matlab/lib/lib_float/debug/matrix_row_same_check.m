function check_result = matrix_row_same_check(input_matrix)
%======================================================================================================================%
% Description:
%   判断输入矩阵的每一行是否都一样
% Inputs:
%   input_matrix : 
% Outputs:
%   check_result : 1-所有行都一样; 存在不一样的行
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.03.25
%======================================================================================================================%

check_result = 1;

row_num = size(input_matrix, 1);
for row_index1 = 2:row_num
    if sum(abs( input_matrix(row_index1,:) - input_matrix(1,:) )) ~= 0
        check_result = 0;
        break;
    end
end


end

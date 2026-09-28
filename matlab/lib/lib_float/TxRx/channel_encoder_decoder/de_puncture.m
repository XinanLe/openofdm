function depunctured_soft_info_row = de_puncture(soft_info_row, code_rate)
%======================================================================================================================%
% Description:
%   信道编码的解打孔
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.22
%======================================================================================================================%

%% 解打孔
if code_rate == 1/2
    depunctured_soft_info_row = soft_info_row;
elseif code_rate == 2/3
    % 每一行都是A0,B0,A1,B1,...,A5,B5打掉B1,B3,B5后的软信息
    coded_soft_info_matrix = reshape(soft_info_row, 9, []).';

    % 打掉B1,B3,B5
    punctured_index1 = [4,8,12];
    remain_index1    = setdiff(1:12, punctured_index1);

    % 解打孔
    depunctured_soft_info_matrix = zeros(size(coded_soft_info_matrix,1), 12);
    depunctured_soft_info_matrix(:,remain_index1) = coded_soft_info_matrix;
    depunctured_soft_info_row = reshape(depunctured_soft_info_matrix.', 1, []);
elseif code_rate == 3/4
    % 每一行都是A0,B0,A1,B1,...,A8,B8打掉B1,A2,B4,A5,B7,A8后的软信息
    coded_soft_info_matrix = reshape(soft_info_row, 12, []).';

    % 打掉B1,A2,B4,A5,B7,A8
    punctured_index1 = [4,5,10,11,16,17];
    remain_index1    = setdiff(1:18, punctured_index1);

    % 解打孔
    depunctured_soft_info_matrix = zeros(size(coded_soft_info_matrix,1), 18);
    depunctured_soft_info_matrix(:,remain_index1) = coded_soft_info_matrix;
    depunctured_soft_info_row = reshape(depunctured_soft_info_matrix.', 1, []);
else
    error('[ERROR] Invalid code_rate');
end


end

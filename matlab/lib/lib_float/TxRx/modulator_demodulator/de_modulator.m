function [soft_info_row, hard_bit_row] = de_modulator(input_symbol_row, bit_num_per_subcarrier)
%======================================================================================================================%
% Description:
%   解调
% Inputs:
%   input_symbol_row : 输入复值符号, 行向量
%   bit_num_per_subcarrier  : 1-BPSK, 2-QPSK, 4-16QAM, 6-64QAM
% Outputs:
%   hard_bit_row : 硬判决结果, 行向量
%   soft_info_row : 软信息, 行向量, ln[Pr(bit = 0)/Pr(bit = 1)]
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.22
%======================================================================================================================%

%% 入参判断
assert(isrow(input_symbol_row), 'Input must be row.');  % 要求输入为行向量


%% 基本参数初始化
symbols_len = length(input_symbol_row);


%% 解调
% soft_info_matrix(1,:)和hard_bits_matrix(1,:)对应b0
soft_info_matrix = zeros(bit_num_per_subcarrier, symbols_len);
hard_bits_matrix = zeros(bit_num_per_subcarrier, symbols_len);
switch bit_num_per_subcarrier
    case 1
        hard_bits_matrix(1, :) = double( real(input_symbol_row) > 0 );

        soft_info_matrix(1, :) = -real(input_symbol_row);
    case 2
        hard_bits_matrix(1, :) = double( real(input_symbol_row) > 0 );
        hard_bits_matrix(2, :) = double( imag(input_symbol_row) > 0 );

        soft_info_matrix(1, :) = -real(input_symbol_row);  % b0
        soft_info_matrix(2, :) = -imag(input_symbol_row);  % b1
    case 4
        hard_bits_matrix(1, :) = double( real(input_symbol_row) > 0 );
        hard_bits_matrix(2, :) = double( abs(real(input_symbol_row)) < 2/sqrt(10) );
        hard_bits_matrix(3, :) = double( imag(input_symbol_row) > 0 );
        hard_bits_matrix(4, :) = double( abs(imag(input_symbol_row)) < 2/sqrt(10) );

        soft_info_matrix(1, :) = -real(input_symbol_row);                   % b0
        soft_info_matrix(2, :) = abs(real(input_symbol_row)) - 2/sqrt(10);  % b1
        soft_info_matrix(3, :) = -imag(input_symbol_row);                   % b2
        soft_info_matrix(4, :) = abs(imag(input_symbol_row)) - 2/sqrt(10);  % b3
    case 6
        % 通过与门限4/sqrt(42)的关系, 区分使用门限2与门限6的索引
        real_index_thres2 = find(abs(real(input_symbol_row)) < 4/sqrt(42));
        real_index_thres6 = setdiff(1:symbols_len, real_index_thres2);
        imag_index_thres2 = find(abs(imag(input_symbol_row)) < 4/sqrt(42));
        imag_index_thres6 = setdiff(1:symbols_len, imag_index_thres2);

        hard_bits_matrix(1, :) = double( real(input_symbol_row) > 0 );
        hard_bits_matrix(2, :) = double( abs(real(input_symbol_row)) < 4/sqrt(42) );
        hard_bits_matrix(3, real_index_thres2) = double( abs(real(input_symbol_row(real_index_thres2))) > 2/sqrt(42) );
        hard_bits_matrix(3, real_index_thres6) = double( abs(real(input_symbol_row(real_index_thres6))) < 6/sqrt(42) );

        hard_bits_matrix(4, :) = double( imag(input_symbol_row) > 0 );
        hard_bits_matrix(5, :) = double( abs(imag(input_symbol_row)) < 4/sqrt(42) );
        hard_bits_matrix(6, imag_index_thres2) = double( abs(imag(input_symbol_row(imag_index_thres2))) > 2/sqrt(42) );
        hard_bits_matrix(6, imag_index_thres6) = double( abs(imag(input_symbol_row(imag_index_thres6))) < 6/sqrt(42) );

        soft_info_matrix(1, :) = -real(input_symbol_row);                                                      % b1
        soft_info_matrix(2, :) = abs(real(input_symbol_row)) - 4/sqrt(42);                                     % b2
        soft_info_matrix(3, real_index_thres2) = 2/sqrt(42) - abs(real(input_symbol_row(real_index_thres2)));  % b3
        soft_info_matrix(3, real_index_thres6) = abs(real(input_symbol_row(real_index_thres6))) - 6/sqrt(42);
        
        soft_info_matrix(4, :) = -imag(input_symbol_row);                                                      % b4
        soft_info_matrix(5, :) = abs(imag(input_symbol_row)) - 4/sqrt(42);                                     % b5
        soft_info_matrix(6, imag_index_thres2) = 2/sqrt(42) - abs(imag(input_symbol_row(imag_index_thres2)));  % b6
        soft_info_matrix(6, imag_index_thres6) = abs(imag(input_symbol_row(imag_index_thres6))) - 6/sqrt(42);
    otherwise
        error('[ERROR] Invalid bit_num_per_subcarrier');
end

soft_info_row = reshape(soft_info_matrix, 1, []);
hard_bit_row = reshape(hard_bits_matrix, 1, []);


end

function [turbo_decode_bits, performed_iteration_num] = turbo_decoder_common_MAX_Log_MAP_CQUPT(turbo_input_soft_info, ...
    PB_type, code_rate, max_iteration_num, spec_version, crc_type, descreambleFlag)
%======================================================================================================================%
% Description:
%   MAX-Log-MAP的Turbo译码
% Inputs:
%   turbo_input_soft_info : 对数似然比(Logarithmic Likelihood Ratios, LLRs), 长度为Turbo编码输出的比特数, 行向量 
%       Channel LLRs should be expressed in the form Channel_LLR = ln[Pr(bit = 1)/Pr(bit = 0)]
%   PB_type : PB类型, {16, 136, 520}
%   code_rate : 信道编码码率, {'1/2', '16/18'}
%   max_iterations : 最大迭代次数, 值为0.5的倍数, 0.5表示半迭代
%   spec_version : 协议版本
%   crc_type : CRC类型, 协议支持{'CRC32', 'CRC24'}, 此参数为可选参数(控帧制可配, 载荷数据有加扰无法配置), 用于提前终止迭代
% Outputs:
%   turbo_decode_bits : Turbo译码输出比特, 行向量
%   performed_iteration_num : 实际的迭代次数, 值为0.5的倍数, 0.5表示半迭代
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2025.09.06
%======================================================================================================================%

%% 入参判断
assert(round(max_iteration_num*2)/2 == max_iteration_num, 'Iterations must be a multiple of 0.5');


%% 基本参数初始化
decode_len = PB_type * 8;  % Turbo译码的输出比特数

% Turbo码内交织模式
[turbo_interleve_pattern, half_turbo_interleve_pattern] = turbo_interlever_common(1:decode_len, PB_type, spec_version);


%% 帧控制模块: 若配置了CRC-aided early termination, 且硬判决通过了CRC校验, 则提前终止迭代
if nargin == 7
    turbo_decode_bits = double(turbo_input_soft_info(1:decode_len) > 0);  % 系统比特的硬判决

    if descreambleFlag
        descreamble_turbo_decode_bits = scrambler_descrambler_common(turbo_decode_bits, spec_version);
    else
        descreamble_turbo_decode_bits = turbo_decode_bits;
    end

    % 0-CRC校验通过; 1-CRC校验未通过
    CRC_error_flag = crc_decoder_common(descreamble_turbo_decode_bits, crc_type, spec_version);
    if CRC_error_flag == 0
        performed_iteration_num = 0;
        return;
    end
end


%% 解复用
channel_llrs_decoder1 = zeros(3, decode_len/2);
channel_llrs_decoder1(1,:) = turbo_input_soft_info(1:2:decode_len);  % 分量译码器1的系统比特u1
channel_llrs_decoder1(2,:) = turbo_input_soft_info(2:2:decode_len);  % 分量译码器1的系统比特u2

% 对系统比特做Turbo码内交织
temp = turbo_input_soft_info(1:decode_len);
interleve_temp = temp(turbo_interleve_pattern);

channel_llrs_decoder2 = zeros(3, decode_len/2);
channel_llrs_decoder2(1,:) = interleve_temp(1:2:end);  % 分量译码器2的系统比特u1
channel_llrs_decoder2(2,:) = interleve_temp(2:2:end);  % 分量译码器2的系统比特u2

if strcmp(code_rate, '1/2')
    channel_llrs_decoder1(3,:) = turbo_input_soft_info(decode_len+1:2:end);  % 分量译码器1的校验比特p
    channel_llrs_decoder2(3,:) = turbo_input_soft_info(decode_len+2:2:end);  % 分量译码器2的校验比特q
elseif strcmp(code_rate, '4/5')  % puncturing掉的比特的信道LLR为0
    if strcmp(spec_version, 'SG1P0') || strcmp(spec_version, 'SG2P0')
        channel_llrs_decoder1(3, mod(1:decode_len/2,4)==0) = turbo_input_soft_info(decode_len+1:2:end);
        channel_llrs_decoder2(3, mod(1:decode_len/2,4)==0) = turbo_input_soft_info(decode_len+2:2:end);
    else
        error('[ERROR] Do not support this standard version');
    end
elseif strcmp(code_rate, '16/18')  % puncturing掉的比特的信道LLR为0
    if strcmp(spec_version, 'SG1P0') || strcmp(spec_version, 'SG2P0')
        channel_llrs_decoder1(3, mod(1:decode_len/2,8)==0) = turbo_input_soft_info(decode_len+1:2:end);
        channel_llrs_decoder2(3, mod(1:decode_len/2,8)==0) = turbo_input_soft_info(decode_len+2:2:end);
    elseif strcmp(spec_version, 'IEEE1901') || strcmp(spec_version, 'SPG1P0') || strcmp(spec_version, 'SPG2P0')
        channel_llrs_decoder1(3, mod(1:decode_len/2,8)==1) = turbo_input_soft_info(decode_len+1:2:end);
        channel_llrs_decoder2(3, mod(1:decode_len/2,8)==1) = turbo_input_soft_info(decode_len+2:2:end);
    else
        error('[ERROR] Do not support this standard version');
    end
else
    error('[ERROR] Invalid code rate');
end


%% 迭代译码初始化
% 判决LLR和外部信息格式相同
% 第1行表示ln[Pr(bit = 01)/Pr(bit = 00)], 第2行表示ln[Pr(bit = 10)/Pr(bit = 00)], 第3行表示ln[Pr(bit = 11)/Pr(bit = 00)]
external_information_decoder1 = zeros(3, decode_len/2);  % 分量译码器1的外部信息, 交织后传给分量译码器2
external_information_decoder2 = zeros(3, decode_len/2);  % 分量译码器2的外部信息, 解交织后传给分量译码器1

% 注意分量译码器1和分量译码器2的alpha和beta不能共用
% 对每个分量编码器而言初始状态和终止状态相同, 均取决于输入的数据, 而两个分量编码的输入数据不同
alpha_decoder1(1:8, 1) = -3 * log(2);  % 分量译码器1的alpha, 起始状态不确定, 假设8种状态等概率出现
beta_decoder1(1:8, 1)  = -3 * log(2);  % 分量译码器1的beta, 终止状态不确定, 假设8种状态等概率出现

alpha_decoder2(1:8, 1) = -3 * log(2);  % 分量译码器2的alpha, 起始状态不确定, 假设8种状态等概率出现
beta_decoder2(1:8, 1)  = -3 * log(2);  % 分量译码器2的beta, 终止状态不确定, 假设8种状态等概率出现


%% 迭代获取软信息(CRC-aided early termination)
for iteration_index = 1:ceil(max_iteration_num)
    % 分量译码器1译码
    [decision_llrs, external_information_decoder1, alpha_decoder1, beta_decoder1] = ...
        constituent_decoder(channel_llrs_decoder1, external_information_decoder1, alpha_decoder1, beta_decoder1);

    % 分量译码器1判决
    if nargin == 7
        turbo_decode_bits = decision_maker(decision_llrs);  % 分量译码器1的判决

        if descreambleFlag
            descreamble_turbo_decode_bits = scrambler_descrambler_common(turbo_decode_bits, spec_version);
        else
            descreamble_turbo_decode_bits = turbo_decode_bits;
        end

        % 0-CRC校验通过; 1-CRC校验未通过
        CRC_error_flag = crc_decoder_common(descreamble_turbo_decode_bits, crc_type, spec_version);
        if CRC_error_flag == 0
            performed_iteration_num = iteration_index - 0.5;
            return;
        end
    end

    if iteration_index <= floor(max_iteration_num)
        % 分量译码器1的外部信息交织后用于分量译码器2, 这里的交织需要结合外部信息的含义, 首先是所有的值都需要半交织, 
        % 然后只有10和01才需要交换位置, 00和11交换u1和u2之后还是本身所以不用交换
        temp = reshape(external_information_decoder1(1:2,:), 1, []);
        interleve_temp = temp(turbo_interleve_pattern);
        external_information_decoder2(1, :) = interleve_temp(1:2:end);
        external_information_decoder2(2, :) = interleve_temp(2:2:end);
        external_information_decoder2(3, :) = external_information_decoder1(3, half_turbo_interleve_pattern);

        % 分量译码器2译码
        [decision_llrs, external_information_decoder2, alpha_decoder2, beta_decoder2] = ...
            constituent_decoder(channel_llrs_decoder2, external_information_decoder2, alpha_decoder2, beta_decoder2);

        % 分量译码器2的判决LLR解交织
        temp = reshape(decision_llrs(1:2,:), 1, []);
        deinterleve_temp = zeros(1, decode_len);
        deinterleve_temp(turbo_interleve_pattern) = temp;
        decision_llrs(1,:) = deinterleve_temp(1:2:end);
        decision_llrs(2,:) = deinterleve_temp(2:2:end);
        decision_llrs(3, half_turbo_interleve_pattern) = decision_llrs(3,:);

        % 分量译码器2判决
        if nargin == 7
            turbo_decode_bits = decision_maker(decision_llrs);  % 分量译码器2的判决

            if descreambleFlag
                descreamble_turbo_decode_bits = scrambler_descrambler_common(turbo_decode_bits, spec_version);
            else
                descreamble_turbo_decode_bits = turbo_decode_bits;
            end

            % 0-CRC校验通过; 1-CRC校验未通过
            CRC_error_flag = crc_decoder_common(descreamble_turbo_decode_bits, crc_type, spec_version);
            if CRC_error_flag == 0
                performed_iteration_num = iteration_index;
                return;
            end
        end

        % 分量译码器2的外部信息解交织后用于分量译码器1
        temp = reshape(external_information_decoder2(1:2,:), 1, []);
        deinterleve_temp = zeros(1, decode_len);
        deinterleve_temp(turbo_interleve_pattern) = temp;
        external_information_decoder1(1,:) = deinterleve_temp(1:2:end);
        external_information_decoder1(2,:) = deinterleve_temp(2:2:end);
        external_information_decoder1(3, half_turbo_interleve_pattern) = external_information_decoder2(3,:);
    end
end


%% 软信息判决
turbo_decode_bits = decision_maker(decision_llrs);
performed_iteration_num = max_iteration_num;


end


function [decision_llrs, external_information_output, alpha_output, beta_output] = ...
    constituent_decoder(channel_llrs, external_information_input, alpha_input, beta_input)
%======================================================================================================================%
% Description:
%   MAX-log-MAP算法的分量译码器
% Inputs:
%   channel_llrs : 信道LLR
%   external_information_input : 输入的外部信息, 来自上一次迭代
%   alpha_input : 输入的alpha, 来自上一次迭代
%   beta_input : 输入的beta, 来自上一次迭代
% Outputs:
%   decision_llrs : 判决LLR
%   external_information_output : 输出的外部信息, 用于下一次迭代
%   alpha_output : 输出的alpha, 用于下一次迭代
%   beta_output : 输出的beta, 用于下一次迭代
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2025.01.02
%======================================================================================================================%

%% 基本参数初始化
time_len = size(channel_llrs, 2);  % 译码输出的比特数为time_len的2倍

channel_llrs_u1 = channel_llrs(1,:);  % 系统比特u1
channel_llrs_u2 = channel_llrs(2,:);  % 系统比特u2
channel_llrs_parity = channel_llrs(3,:);  % 校验比特


%% Step 1: 更新gamma
% 第一维表示状态S(k-1), 第二维表示输入为00,01,10,11时对应的状态S(k)(并不表示真实的状态值), 第三维表示时间k
gamma = zeros(8, 4, time_len);
for k = 1:time_len
    % 状态S(k-1)为1, 输入(u1u2)为00时, 输出为0;
    % 状态S(k-1)为1, 输入(u1u2)为01时, 输出为1;
    % 状态S(k-1)为1, 输入(u1u2)为10时, 输出为1;
    % 状态S(k-1)为1, 输入(u1u2)为11时, 输出为0;
    gamma(1,1,k) = (-channel_llrs_u1(k)-channel_llrs_u2(k)-channel_llrs_parity(k));
    gamma(1,2,k) = external_information_input(1,k) + (-channel_llrs_u1(k)+channel_llrs_u2(k)+channel_llrs_parity(k));
    gamma(1,3,k) = external_information_input(2,k) + ( channel_llrs_u1(k)-channel_llrs_u2(k)+channel_llrs_parity(k));
    gamma(1,4,k) = external_information_input(3,k) + ( channel_llrs_u1(k)+channel_llrs_u2(k)-channel_llrs_parity(k));

    % 状态S(k-1)为2, 输入(u1u2)为00时, 输出为1;
    % 状态S(k-1)为2, 输入(u1u2)为01时, 输出为0;
    % 状态S(k-1)为2, 输入(u1u2)为10时, 输出为0;
    % 状态S(k-1)为2, 输入(u1u2)为11时, 输出为1;
    gamma(2,1,k) = (-channel_llrs_u1(k)-channel_llrs_u2(k)+channel_llrs_parity(k));
    gamma(2,2,k) = external_information_input(1,k) + (-channel_llrs_u1(k)+channel_llrs_u2(k)-channel_llrs_parity(k));
    gamma(2,3,k) = external_information_input(2,k) + ( channel_llrs_u1(k)-channel_llrs_u2(k)-channel_llrs_parity(k));
    gamma(2,4,k) = external_information_input(3,k) + ( channel_llrs_u1(k)+channel_llrs_u2(k)+channel_llrs_parity(k));

    gamma(3,1,k) = gamma(1,1,k);
    gamma(3,2,k) = gamma(1,2,k);
    gamma(3,3,k) = gamma(1,3,k);
    gamma(3,4,k) = gamma(1,4,k);

    gamma(4,1,k) = gamma(2,1,k);
    gamma(4,2,k) = gamma(2,2,k);
    gamma(4,3,k) = gamma(2,3,k);
    gamma(4,4,k) = gamma(2,4,k);

    gamma(5,1,k) = gamma(1,1,k);
    gamma(5,2,k) = gamma(1,2,k);
    gamma(5,3,k) = gamma(1,3,k);
    gamma(5,4,k) = gamma(1,4,k);

    gamma(6,1,k) = gamma(2,1,k);
    gamma(6,2,k) = gamma(2,2,k);
    gamma(6,3,k) = gamma(2,3,k);
    gamma(6,4,k) = gamma(2,4,k);

    gamma(7,1,k) = gamma(1,1,k);
    gamma(7,2,k) = gamma(1,2,k);
    gamma(7,3,k) = gamma(1,3,k);
    gamma(7,4,k) = gamma(1,4,k);

    gamma(8,1,k) = gamma(2,1,k);
    gamma(8,2,k) = gamma(2,2,k);
    gamma(8,3,k) = gamma(2,3,k);
    gamma(8,4,k) = gamma(2,4,k);
end


%% Step 2: 更新alpha
alpha = zeros(8, time_len+1);
alpha(:,1) = alpha_input;
for k = 2:time_len+1
    alpha(1,k) = max([gamma(1,1,k-1)+alpha(1,k-1), gamma(5,2,k-1)+alpha(5,k-1), gamma(7,3,k-1)+alpha(7,k-1), gamma(3,4,k-1)+alpha(3,k-1)]);
    alpha(2,k) = max([gamma(3,1,k-1)+alpha(3,k-1), gamma(7,2,k-1)+alpha(7,k-1), gamma(5,3,k-1)+alpha(5,k-1), gamma(1,4,k-1)+alpha(1,k-1)]);
    alpha(3,k) = max([gamma(5,1,k-1)+alpha(5,k-1), gamma(1,2,k-1)+alpha(1,k-1), gamma(3,3,k-1)+alpha(3,k-1), gamma(7,4,k-1)+alpha(7,k-1)]);
    alpha(4,k) = max([gamma(7,1,k-1)+alpha(7,k-1), gamma(3,2,k-1)+alpha(3,k-1), gamma(1,3,k-1)+alpha(1,k-1), gamma(5,4,k-1)+alpha(5,k-1)]);
    alpha(5,k) = max([gamma(4,1,k-1)+alpha(4,k-1), gamma(8,2,k-1)+alpha(8,k-1), gamma(6,3,k-1)+alpha(6,k-1), gamma(2,4,k-1)+alpha(2,k-1)]);
    alpha(6,k) = max([gamma(2,1,k-1)+alpha(2,k-1), gamma(6,2,k-1)+alpha(6,k-1), gamma(8,3,k-1)+alpha(8,k-1), gamma(4,4,k-1)+alpha(4,k-1)]);
    alpha(7,k) = max([gamma(8,1,k-1)+alpha(8,k-1), gamma(4,2,k-1)+alpha(4,k-1), gamma(2,3,k-1)+alpha(2,k-1), gamma(6,4,k-1)+alpha(6,k-1)]);
    alpha(8,k) = max([gamma(6,1,k-1)+alpha(6,k-1), gamma(2,2,k-1)+alpha(2,k-1), gamma(4,3,k-1)+alpha(4,k-1), gamma(8,4,k-1)+alpha(8,k-1)]);

    % the normalization term
    alpha(:,k) = alpha(:,k) - max(alpha(:,k));
end


%% Step 3: 更新beta
beta = zeros(8, time_len+1);
beta(:, time_len+1) = beta_input;
for k = time_len:-1:1
    beta(1,k) = max([gamma(1,1,k)+beta(1,k+1), gamma(1,2,k)+beta(3,k+1), gamma(1,3,k)+beta(4,k+1), gamma(1,4,k)+beta(2,k+1)]);
    beta(2,k) = max([gamma(2,1,k)+beta(6,k+1), gamma(2,2,k)+beta(8,k+1), gamma(2,3,k)+beta(7,k+1), gamma(2,4,k)+beta(5,k+1)]);
    beta(3,k) = max([gamma(3,1,k)+beta(2,k+1), gamma(3,2,k)+beta(4,k+1), gamma(3,3,k)+beta(3,k+1), gamma(3,4,k)+beta(1,k+1)]);
    beta(4,k) = max([gamma(4,1,k)+beta(5,k+1), gamma(4,2,k)+beta(7,k+1), gamma(4,3,k)+beta(8,k+1), gamma(4,4,k)+beta(6,k+1)]);
    beta(5,k) = max([gamma(5,1,k)+beta(3,k+1), gamma(5,2,k)+beta(1,k+1), gamma(5,3,k)+beta(2,k+1), gamma(5,4,k)+beta(4,k+1)]);
    beta(6,k) = max([gamma(6,1,k)+beta(8,k+1), gamma(6,2,k)+beta(6,k+1), gamma(6,3,k)+beta(5,k+1), gamma(6,4,k)+beta(7,k+1)]);
    beta(7,k) = max([gamma(7,1,k)+beta(4,k+1), gamma(7,2,k)+beta(2,k+1), gamma(7,3,k)+beta(1,k+1), gamma(7,4,k)+beta(3,k+1)]);
    beta(8,k) = max([gamma(8,1,k)+beta(7,k+1), gamma(8,2,k)+beta(5,k+1), gamma(8,3,k)+beta(6,k+1), gamma(8,4,k)+beta(8,k+1)]);

    % the normalization term
    beta(:,k) = beta(:,k) - max(beta(:,k));
end


%% Step 4: 计算LLR
% decision_llrs(1,:) = ln[Pr(bit = 01)/Pr(bit = 00)]
% decision_llrs(2,:) = ln[Pr(bit = 10)/Pr(bit = 00)]
% decision_llrs(3,:) = ln[Pr(bit = 11)/Pr(bit = 00)]
decision_llrs = zeros(3, time_len);
for k = 1:time_len
    LLR_zero = max([alpha(1,k)+gamma(1,1,k)+beta(1,k+1), ...
                    alpha(2,k)+gamma(2,1,k)+beta(6,k+1), ...
                    alpha(3,k)+gamma(3,1,k)+beta(2,k+1), ...
                    alpha(4,k)+gamma(4,1,k)+beta(5,k+1), ...
                    alpha(5,k)+gamma(5,1,k)+beta(3,k+1), ...
                    alpha(6,k)+gamma(6,1,k)+beta(8,k+1), ...
                    alpha(7,k)+gamma(7,1,k)+beta(4,k+1), ...
                    alpha(8,k)+gamma(8,1,k)+beta(7,k+1)]);

    decision_llrs(1,k) = max([alpha(1,k)+gamma(1,2,k)+beta(3,k+1), ...
                              alpha(2,k)+gamma(2,2,k)+beta(8,k+1), ...
                              alpha(3,k)+gamma(3,2,k)+beta(4,k+1), ...
                              alpha(4,k)+gamma(4,2,k)+beta(7,k+1), ...
                              alpha(5,k)+gamma(5,2,k)+beta(1,k+1), ...
                              alpha(6,k)+gamma(6,2,k)+beta(6,k+1), ...
                              alpha(7,k)+gamma(7,2,k)+beta(2,k+1), ...
                              alpha(8,k)+gamma(8,2,k)+beta(5,k+1)]) - LLR_zero;

    decision_llrs(2,k) = max([alpha(1,k)+gamma(1,3,k)+beta(4,k+1), ...
                              alpha(2,k)+gamma(2,3,k)+beta(7,k+1), ...
                              alpha(3,k)+gamma(3,3,k)+beta(3,k+1), ...
                              alpha(4,k)+gamma(4,3,k)+beta(8,k+1), ...
                              alpha(5,k)+gamma(5,3,k)+beta(2,k+1), ...
                              alpha(6,k)+gamma(6,3,k)+beta(5,k+1), ...
                              alpha(7,k)+gamma(7,3,k)+beta(1,k+1), ...
                              alpha(8,k)+gamma(8,3,k)+beta(6,k+1)]) - LLR_zero;

    decision_llrs(3,k) = max([alpha(1,k)+gamma(1,4,k)+beta(2,k+1), ...
                              alpha(2,k)+gamma(2,4,k)+beta(5,k+1), ...
                              alpha(3,k)+gamma(3,4,k)+beta(1,k+1), ...
                              alpha(4,k)+gamma(4,4,k)+beta(6,k+1), ...
                              alpha(5,k)+gamma(5,4,k)+beta(4,k+1), ...
                              alpha(6,k)+gamma(6,4,k)+beta(7,k+1), ...
                              alpha(7,k)+gamma(7,4,k)+beta(3,k+1), ...
                              alpha(8,k)+gamma(8,4,k)+beta(8,k+1)]) - LLR_zero;
end


%% 结果整理
% alpha和beta传出去作为下一次迭代使用
alpha_output = alpha(:, time_len+1);
beta_output = beta(:, 1);

% 外部信息传出去作为下一次迭代使用
external_information_output(1,:) = decision_llrs(1,:) - external_information_input(1,:) - 2*channel_llrs_u2;
external_information_output(2,:) = decision_llrs(2,:) - external_information_input(2,:) - 2*channel_llrs_u1;
external_information_output(3,:) = decision_llrs(3,:) - external_information_input(3,:) - 2*(channel_llrs_u1+channel_llrs_u2);


end




function decode_bits = decision_maker(decision_llrs)
%======================================================================================================================%
% Description:
%   判决器
% Inputs:
%   decision_llrs : 判决LLR
% Outputs:
%   decode_bits : 判决比特
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2025.01.02
%======================================================================================================================%

%% 基本参数初始化
time_len = size(decision_llrs,2);
decode_len = 2 * time_len;  % Turbo译码的输出比特数


%% 通过判决LLR译码
decode_bits = zeros(1, decode_len);
for k = 1:time_len
    % find the biggest index per column
    [~, index] = max(decision_llrs(:,k));

    % output
    if decision_llrs(index,k) <= 0
        decode_bits(2*k-1) = 0;
        decode_bits(2*k) = 0;
    elseif index == 1
        decode_bits(2*k-1) = 0;
        decode_bits(2*k) = 1;
    elseif index == 2
        decode_bits(2*k-1) = 1;
        decode_bits(2*k) = 0;
    elseif index == 3
        decode_bits(2*k-1) = 1;
        decode_bits(2*k) = 1;
    end
end


end
function output_data_row = turbo_encoder_common(input_data_row, PB_type, code_rate, spec_version)
%======================================================================================================================%
% Description:
%   Turbo编码器
% Inputs:
%   input_data_row : 输入比特序列, 行向量
%   PB_type        : PB类型
%   code_rate      : 信道编码码率, {'1/2', '16/18'}
%   spec_version   : 协议版本
% Outputs:
%   output_data_row : Turbo编码后的输出比特序列, 行向量
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2025.09.06
%======================================================================================================================%

%% Step 1: 通过分量编码器产生校验比特p
% 不同协议的分量编码器只是支持的PB类型不同, 实现相同, 所以spec_version无需传进分量编码器中
u1 = input_data_row(1:2:end);
u2 = input_data_row(2:2:end);
p  = constituent_encoder_common(u1, u2, PB_type);


%% Step 2: Turbo交织器
[interleved_input_data_row, ~] = turbo_interlever_common(input_data_row, PB_type, spec_version);


%% Step 3: 通过分量编码器产生校验比特q
interleved_u1 = interleved_input_data_row(1:2:end);
interleved_u2 = interleved_input_data_row(2:2:end);
q = constituent_encoder_common(interleved_u1, interleved_u2, PB_type);


%% Step 4: 对校验比特打孔
if strcmp(code_rate, '1/2')
    puncturing_p = p;
    puncturing_q = q;
elseif strcmp(code_rate, '4/5')
    if strcmp(spec_version, 'SG1P0') || strcmp(spec_version, 'SG2P0')
        puncturing_p = p( mod(1:length(p), 4) == 0 );
        puncturing_q = q( mod(1:length(q), 4) == 0 );
    else
        error('[ERROR] Do not support this standard version');
    end
elseif strcmp(code_rate, '16/18')
    if strcmp(spec_version, 'SG1P0') || strcmp(spec_version, 'SG2P0')
        puncturing_p = p( mod(1:length(p), 8) == 0 );
        puncturing_q = q( mod(1:length(q), 8) == 0 );
    elseif strcmp(spec_version, 'IEEE1901') || strcmp(spec_version, 'SPG1P0') || strcmp(spec_version, 'SPG2P0')
        puncturing_p = p( mod(1:length(p), 8) == 1 );
        puncturing_q = q( mod(1:length(q), 8) == 1 );
    else
        error('[ERROR] Do not support this standard version');
    end
else
    error('[ERROR] Invalid code rate');
end


%% 输出数据
output_data_row = [input_data_row, reshape([puncturing_p; puncturing_q], 1, [])];


end




function out_ENC = constituent_encoder_common(u1, u2, PB_type)
%======================================================================================================================%
% Description:
%   8状态分量编码器
%======================================================================================================================%

%% 基本参数初始化
len = length(u1);


%% Step 1: 寄存器初始状态
register_s1 = [0, 0, 0];


%% Step 2: 获取编码结束的末状态
x0 = zeros(1, len);
for index = 1:len
    % 保留旧的寄存器状态
    register_s1_old = register_s1;

    % 计算输出数据
    x0(index) = mod(u1(index) + u2(index) + register_s1_old(3), 2);

    % 计算新的寄存器状态
    register_s1_new(1) = mod(u1(index) + u2(index) + x0(index), 2);
    register_s1_new(2) = mod(u1(index) + u2(index) + register_s1_old(1), 2);
    register_s1_new(3) = mod(u2(index) + register_s1_old(2) + x0(index), 2);

    % 更新寄存器
    register_s1 = register_s1_new;
end


%% Step 3: 重新定义寄存器初始状态
if (PB_type == 16) || (PB_type == 72) || (PB_type == 520)
    M = [0, 0, 1; 1, 0, 1; 1, 1, 1];
elseif (PB_type == 40) || (PB_type == 264)
    M = [1, 0, 1; 1, 1, 1; 1, 1, 0];
elseif PB_type == 136
    M = [0, 1, 1; 1, 0, 0; 0, 1, 0];
else
    error('[ERROR] Invalid PB_type');
end
register_s2 = mod(register_s1 * M, 2);


%% Step 4: 获取校验位
out_ENC = zeros(1, len);
register_s3 = register_s2;
for index = 1:len
    % 保留旧的寄存器状态
    register_s3_old = register_s3;

    % 计算输出数据
    out_ENC(index) = mod(u1(index) + u2(index) + register_s3_old(3), 2);

    % 计算新的寄存器状态
    register_s3_new(3) = mod(u2(index) + register_s3_old(2) + out_ENC(index), 2);
    register_s3_new(2) = mod(u1(index) + u2(index) + register_s3_old(1), 2);
    register_s3_new(1) = mod(u1(index) + u2(index) + out_ENC(index), 2);

    % 更新寄存器
    register_s3 = register_s3_new;
end


%% assert校验
assert(sum(abs(register_s3 - register_s2)) == 0, '[Error] register state');


end


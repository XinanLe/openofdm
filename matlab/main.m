%======================================================================================================================%
% Description:
%   IEEE 802.11 a/g/n主函数
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.24
%======================================================================================================================%

clc;
clear;
close all;

%% 仿真初始化
% 将文件夹及子文件夹添加到路径(说明: addpath('./folder_name')只将文件夹添加到路径)
addpath(genpath('./lib'));

% 创建文件夹results, 用于存储仿真结果, 若文件夹已经存在则将其清空
if strcmp(get(0,'Diary'), 'on')  % 若当前日志记录开启, 则关闭日志记录
    diary off;
end
results_folderPath = fullfile(pwd, 'main_results');
if isfolder(results_folderPath)
    rmdir(results_folderPath, 's');  % 's'表示删除文件夹及子文件夹
end
mkdir(results_folderPath);

% 打开仿真日志记录
% 若日志文件 sim_diary.txt 不存在, 创建sim_diary.txt文件
% 若日志文件 sim_diary.txt 存在, 首先将其清空, 再记录本次仿真日志
log_filePath = fullfile(pwd, 'main_results', 'sim_diary.txt');
if exist(log_filePath, "file")
    fid = fopen(log_filePath, 'w');
    fclose(fid);
end
diary ./main_results/sim_diary.txt;  % 指定日志文件
if strcmp(get(0,'Diary'), 'off')  % 若当前日志记录关闭, 则开启日志记录
    diary on;
end

% 随机种子初始化
rng('default');
rng(2^10);


%% 参数初始化
configs = [];
configs = excel_parameters_init_allFrame(configs);
if strcmp(configs.common.frame_type, 'IEEE_SOF')
    configs = excel_parameters_init_IEEE_SOF(configs);
    configs = parameters_init_IEEE_SOF(configs);
elseif strcmp(configs.common.frame_type, 'IEEE_SACK')
    configs = excel_parameters_init_IEEE_SACK(configs);
    configs = parameters_init_IEEE_SACK(configs);
else
    error('[ERROR] Invalid Frame Type');
end
configs = parameters_init_allFrame(configs);
parameters_validation(configs);


%% 仿真
configs = IEEE_simu_process(configs);


%% 仿真结果存储
configs_filePath = fullfile(pwd, 'main_results', 'configs.mat');
save(configs_filePath, 'configs');


%% 仿真结束初始化
close all;

if strcmp(get(0,'Diary'), 'on')  % 若当前日志记录开启, 则关闭日志记录
    diary off;
end

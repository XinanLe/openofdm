%======================================================================================================================%
% Description:
%   删除代码中的result目录
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2025.11.17
%======================================================================================================================%

clc;
clear;
close all;


%% 初始化
addpath(genpath('./lib'));
addpath(genpath('./demo'));
addpath(genpath('./main_check_folder'));
addpath(genpath('./main_performance_folder'));

rmpath(genpath('./lib'));
rmpath(genpath('./demo'));
rmpath(genpath('./main_check_folder'));
rmpath(genpath('./main_performance_folder'));

% 若当前日志记录开启, 则关闭日志记录
if strcmp(get(0,'Diary'), 'on')
    diary off;
end

% 关闭所有打开的文件, 有时fopen打开文件后, 未执行fclose
fclose('all');


%% 删除results目录
all_clear_path = {
    fullfile(pwd, 'main_results');
    fullfile(pwd, 'main_performance_results')
};

for clear_path_index = 1:size(all_clear_path,1)
    curr_clear_path = all_clear_path{clear_path_index};

    if isfolder(curr_clear_path)
        rmdir(curr_clear_path, 's');  % 's'表示删除文件夹及子文件夹
    end
end


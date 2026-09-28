function configs = IEEE_simu_process(configs)
%======================================================================================================================%
% Description:
%   实现单次配置的Tx/Rx仿真过程, 并做结果统计
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.24
%======================================================================================================================%

%% 仿真参数初始化
SNR_range = configs.channel.awgn_type1.SNR_range;  % SNR范围
SNR_num   = length(SNR_range);  % SNR数量
montekarlo_num = configs.simu.montekarlo_num;  % 每个SNR点的蒙特卡洛仿真次数


%% 新建图窗
if configs.testmat.plot_enable
    configs.testmat.fig = figure('Visible','on', 'Color','white', 'Units','pixels', 'Position',[50,50,800,600]);
end


%% 仿真
configs.results = cell(SNR_num, montekarlo_num);
for SNR_index = 1:SNR_num
    fprintf(1, '\t Simulation Progress: SNR(%d / %d)\n', SNR_index, SNR_num);  % 进度条打印

    for montekarlo_index = 1:montekarlo_num
        %% 进度条打印
        if mod(montekarlo_index, 500) == 0
            fprintf(1, '\t\t Simulation Progress: MonteKarlo(%d / %d)\n', montekarlo_index, montekarlo_num);
        end


        %% Tx处理流程
        [tx_signal, configs] = IEEE_tx_process(configs);


        %% RF信道
        [rx_signal, configs] = IEEE_channel(tx_signal, SNR_index, configs);


        %% Rx处理流程
        [configs] = IEEE_rx_process(rx_signal, SNR_index, montekarlo_index, configs);


    end
end


%% 关闭图窗
close(configs.testmat.fig);
drawnow;


end


function plot_rx_signal(rx_signal, isPacketDetectionSuccess, SIG_start_index1_est, configs)
%======================================================================================================================%
% Description:
%   画接收信号以及包检测结果
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.08.29
%======================================================================================================================%

%% 参数初始化
% rx_STF_sample_num  = configs.common.rx_STF_sample_num;
rx_LTF_sample_num  = configs.common.rx_LTF_sample_num;
rx_SIG_sample_num  = configs.common.rx_SIG_sample_num;
rx_PHR_sample_num  = configs.common.rx_PHR_sample_num;
rx_PSDU_sample_num = configs.common.rx_PSDU_sample_num;
rx_PSS_sample_num  = configs.common.rx_PSS_sample_num;

LTF_start_index1_est  = SIG_start_index1_est - rx_LTF_sample_num;
PHR_start_index1_est  = SIG_start_index1_est + rx_SIG_sample_num;
PSDU_start_index1_est = PHR_start_index1_est + rx_PHR_sample_num;
frame_end_index1_est  = PSDU_start_index1_est + rx_PSDU_sample_num + rx_PSS_sample_num - 1;


%% 画图1: 模
fig = configs.testmat.fig;
clf(fig);

ax = subplot(2,2,1, 'Parent', fig);
plot(ax, 1:length(rx_signal), abs(rx_signal), '-', 'Color','blue', 'LineWidth',1, 'DisplayName','rx signal');
hold(ax, 'on');
grid(ax, 'off');

ax.Title.String    = 'module of rx signal';
ax.Title.FontSize  = 12;
ax.XLabel.String   = 'Sample';
ax.XLabel.FontSize = 12;
ax.YLabel.String   = 'Modulu';
ax.YLabel.FontSize = 12;

ax.XLim = [1, length(rx_signal)];

if isPacketDetectionSuccess
    xline(ax, LTF_start_index1_est,  '--', 'Color','black',   'LineWidth', 1, 'DisplayName','LTF start');
    xline(ax, SIG_start_index1_est,  '--', 'Color','red',     'LineWidth', 1, 'DisplayName','SIG start');
    xline(ax, PHR_start_index1_est,  '--', 'Color','green',   'LineWidth', 1, 'DisplayName','PHR start');
    xline(ax, PSDU_start_index1_est, '--', 'Color','cyan',    'LineWidth', 1, 'DisplayName','PSDU start');
    xline(ax, frame_end_index1_est,  '--', 'Color','magenta', 'LineWidth', 1, 'DisplayName','frame end');
end

legend(ax, 'show');
ax.Legend.FontSize = 6;


%% 画图2: 相位
% fig = configs.testmat.fig;
% clf(fig);

ax = subplot(2,2,2, 'Parent', fig);
% plot(ax, 1:length(rx_signal), angle(rx_signal), '-', 'Color','blue', 'LineWidth',1, 'DisplayName','rx signal');
plot(ax, 1:length(rx_signal), unwrap(angle(rx_signal)), '-', 'Color','blue', 'LineWidth',1, 'DisplayName','rx signal');
hold(ax, 'on');
grid(ax, 'off');

ax.Title.String    = 'unwrap(angle()) of rx signal';
ax.Title.FontSize  = 12;
ax.XLabel.String   = 'Sample';
ax.XLabel.FontSize = 12;
ax.YLabel.String   = 'unwrap(angle())';
ax.YLabel.FontSize = 12;

ax.XLim = [1, length(rx_signal)];

if isPacketDetectionSuccess
    xline(ax, LTF_start_index1_est,  '--', 'Color','black',   'LineWidth', 1, 'DisplayName','LTF start');
    xline(ax, SIG_start_index1_est,  '--', 'Color','red',     'LineWidth', 1, 'DisplayName','SIG start');
    xline(ax, PHR_start_index1_est,  '--', 'Color','green',   'LineWidth', 1, 'DisplayName','PHR start');
    xline(ax, PSDU_start_index1_est, '--', 'Color','cyan',    'LineWidth', 1, 'DisplayName','PSDU start');
    xline(ax, frame_end_index1_est,  '--', 'Color','magenta', 'LineWidth', 1, 'DisplayName','frame end');
end

legend(ax, 'show');
ax.Legend.FontSize = 6;


%% 画图3: 实部
% fig = configs.testmat.fig;
% clf(fig);

ax = subplot(2,2,3, 'Parent', fig);
plot(ax, 1:length(rx_signal), real(rx_signal), '-', 'Color','blue', 'LineWidth',1, 'DisplayName','rx signal');
hold(ax, 'on');
grid(ax, 'off');

ax.Title.String    = 'Real of rx signal';
ax.Title.FontSize  = 12;
ax.XLabel.String   = 'Sample';
ax.XLabel.FontSize = 12;
ax.YLabel.String   = 'Real(I-phase)';
ax.YLabel.FontSize = 12;

ax.XLim = [1, length(rx_signal)];

if isPacketDetectionSuccess
    xline(ax, LTF_start_index1_est,  '--', 'Color','black',   'LineWidth', 1, 'DisplayName','LTF start');
    xline(ax, SIG_start_index1_est,  '--', 'Color','red',     'LineWidth', 1, 'DisplayName','SIG start');
    xline(ax, PHR_start_index1_est,  '--', 'Color','green',   'LineWidth', 1, 'DisplayName','PHR start');
    xline(ax, PSDU_start_index1_est, '--', 'Color','cyan',    'LineWidth', 1, 'DisplayName','PSDU start');
    xline(ax, frame_end_index1_est,  '--', 'Color','magenta', 'LineWidth', 1, 'DisplayName','frame end');
end

legend(ax, 'show');
ax.Legend.FontSize = 6;


%% 画图4: 虚部
% fig = configs.testmat.fig;
% clf(fig);

ax = subplot(2,2,4, 'Parent', fig);
plot(ax, 1:length(rx_signal), real(rx_signal), '-', 'Color','blue', 'LineWidth',1, 'DisplayName','rx signal');
hold(ax, 'on');
grid(ax, 'off');

ax.Title.String    = 'Imag of rx signal';
ax.Title.FontSize  = 12;
ax.XLabel.String   = 'Sample';
ax.XLabel.FontSize = 12;
ax.YLabel.String   = 'Imag(Q-phase)';
ax.YLabel.FontSize = 12;

ax.XLim = [1, length(rx_signal)];

if isPacketDetectionSuccess
    xline(ax, LTF_start_index1_est,  '--', 'Color','black',   'LineWidth', 1, 'DisplayName','LTF start');
    xline(ax, SIG_start_index1_est,  '--', 'Color','red',     'LineWidth', 1, 'DisplayName','SIG start');
    xline(ax, PHR_start_index1_est,  '--', 'Color','green',   'LineWidth', 1, 'DisplayName','PHR start');
    xline(ax, PSDU_start_index1_est, '--', 'Color','cyan',    'LineWidth', 1, 'DisplayName','PSDU start');
    xline(ax, frame_end_index1_est,  '--', 'Color','magenta', 'LineWidth', 1, 'DisplayName','frame end');
end

legend(ax, 'show');
ax.Legend.FontSize = 6;


%% 保存图片
if strcmp(configs.testmat.fig_type, 'fig')
    savefig(fig, fullfile(configs.testmat.result_path, 'Rx_signal.fig'));
elseif strcmp(configs.testmat.fig_type, 'png')
    exportgraphics(fig, fullfile(configs.testmat.result_path, 'Rx_signal.png'), 'Resolution', 300);
else
    error('[ERROR] Invalid fig_type');
end


end

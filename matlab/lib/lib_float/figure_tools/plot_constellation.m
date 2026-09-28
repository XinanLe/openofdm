function plot_constellation(SIG_data_FP_signal, PHR_data_FP_signal, PSDU_data_FP_signal, ...
    channelEstimation_freq_signal, results, configs)
%======================================================================================================================%
% Description:
%   画信道均衡后的星座图
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.09.02
%======================================================================================================================%

%% 参数初始化
PSDU_ofdm_num  = configs.tx.PSDU.PSDU_ofdm_num;


%% 'amp-phase'均衡
[SIG_data_EQ_signal, PHR_data_EQ_signal, PSDU_data_EQ_signal, ~, ~, ~] = ChannelEqualization_method_amp_phase( ...
    SIG_data_FP_signal, PHR_data_FP_signal, PSDU_data_FP_signal, channelEstimation_freq_signal, configs);

real_SIG_row = real(reshape(SIG_data_EQ_signal.', 1, []));
imag_SIG_row = imag(reshape(SIG_data_EQ_signal.', 1, []));

real_PHR_row = real(reshape(PHR_data_EQ_signal.', 1, []));
imag_PHR_row = imag(reshape(PHR_data_EQ_signal.', 1, []));

real_PSDU_row = real(reshape(PSDU_data_EQ_signal.', 1, []));
imag_PSDU_row = imag(reshape(PSDU_data_EQ_signal.', 1, []));

if configs.rx.EVM.enable
    SIG_EVM_percent  = results.EVM.SIG_EVM_percent;
    SIG_EVM_dB       = results.EVM.SIG_EVM_dB;
    PHR_EVM_percent  = results.EVM.PHR_EVM_percent;
    PHR_EVM_dB       = results.EVM.PHR_EVM_dB;
    PSDU_EVM_percent = results.EVM.PSDU_EVM_percent;
    PSDU_EVM_dB      = results.EVM.PSDU_EVM_dB;
    SIG_PHR_PSDU_EVM_percent = results.EVM.SIG_PHR_PSDU_EVM_percent;
    SIG_PHR_PSDU_EVM_dB      = results.EVM.SIG_PHR_PSDU_EVM_dB;
    SIG_string  = sprintf('SIG EVM: %.2f%%, %.2f (dB); Total EVM: %.2f%%, %.2f (dB)', ...
        SIG_EVM_percent, SIG_EVM_dB, SIG_PHR_PSDU_EVM_percent, SIG_PHR_PSDU_EVM_dB);
    PHR_string  = sprintf('PHR EVM: %.2f%%, %.2f (dB); Total EVM: %.2f%%, %.2f (dB)', ...
        PHR_EVM_percent, PHR_EVM_dB, SIG_PHR_PSDU_EVM_percent, SIG_PHR_PSDU_EVM_dB);
    PSDU_string = sprintf('PSDU EVM: %.2f%%, %.2f (dB); Total EVM: %.2f%%, %.2f (dB)', ...
        PSDU_EVM_percent, PSDU_EVM_dB, SIG_PHR_PSDU_EVM_percent, SIG_PHR_PSDU_EVM_dB);
end


%% 画图1: SIG星座图
fig = configs.testmat.fig;
clf(fig);
ax = axes('Parent', fig);

scatter(ax, real_SIG_row, imag_SIG_row, 8, 'red', 'filled');  % 横轴为实部(同相分量), 纵轴为虚部(正交分量)

if configs.rx.EVM.enable
    ax.Title.String = ['SIG归一化星座图, ', SIG_string];
else
    ax.Title.String = 'SIG归一化星座图';
end
ax.Title.FontSize  = 12;
ax.XLabel.String   = 'I路(实部, 同向分量)';
ax.XLabel.FontSize = 12;
ax.YLabel.String   = 'Q路(虚部, 正交分量)';
ax.YLabel.FontSize = 12;

SIG_bound = ceil(max([1, max(abs(real_SIG_row)), max(abs(imag_SIG_row))])*2) / 2;
if SIG_bound <= 5
    ax.XLim       = [-1.05*SIG_bound, 1.05*SIG_bound];
    ax.XTick      = -SIG_bound : 0.5 : SIG_bound;
    ax.XTickLabel = -SIG_bound : 0.5 : SIG_bound;
end
ax.XAxisLocation = 'origin';

if SIG_bound <= 5
    ax.YLim       = [-1.05*SIG_bound, 1.05*SIG_bound];
    ax.YTick      = -SIG_bound : 0.5 : SIG_bound;
    ax.YTickLabel = -SIG_bound : 0.5 : SIG_bound;
end
ax.YAxisLocation = 'origin';

if strcmp(configs.testmat.fig_type, 'fig')
    savefig(fig, fullfile(configs.testmat.result_path, 'SIG_constellation.fig'));
elseif strcmp(configs.testmat.fig_type, 'png')
    exportgraphics(fig, fullfile(configs.testmat.result_path, 'SIG_constellation.png'), 'Resolution', 300);
else
    error('[ERROR] Invalid fig_type');
end


%% 画图2: PHR星座图
fig = configs.testmat.fig;
clf(fig);
ax = axes('Parent', fig);

scatter(ax, real_PHR_row, imag_PHR_row, 8, 'red', 'filled');  % 横轴为实部(同相分量), 纵轴为虚部(正交分量)

if configs.rx.EVM.enable
    ax.Title.String = ['PHR归一化星座图, ', PHR_string];
else
    ax.Title.String = 'PHR归一化星座图';
end
ax.Title.FontSize  = 12;
ax.XLabel.String   = 'I路(实部, 同向分量)';
ax.XLabel.FontSize = 12;
ax.YLabel.String   = 'Q路(虚部, 正交分量)';
ax.YLabel.FontSize = 12;

PHR_bound = ceil(max([1, max(abs(real_PHR_row)), max(abs(imag_PHR_row))])*2) / 2;
if PHR_bound <= 5
    ax.XLim       = [-1.05*PHR_bound, 1.05*PHR_bound];
    ax.XTick      = -PHR_bound : 0.5 : PHR_bound;
    ax.XTickLabel = -PHR_bound : 0.5 : PHR_bound;
end
ax.XAxisLocation = 'origin';

if PHR_bound <= 5
    ax.YLim       = [-1.05*PHR_bound, 1.05*PHR_bound];
    ax.YTick      = -PHR_bound : 0.5 : PHR_bound;
    ax.YTickLabel = -PHR_bound : 0.5 : PHR_bound;
end
ax.YAxisLocation = 'origin';

if strcmp(configs.testmat.fig_type, 'fig')
    savefig(fig, fullfile(configs.testmat.result_path, 'PHR_constellation.fig'));
elseif strcmp(configs.testmat.fig_type, 'png')
    exportgraphics(fig, fullfile(configs.testmat.result_path, 'PHR_constellation.png'), 'Resolution', 300);
else
    error('[ERROR] Invalid fig_type');
end


%% 画图3: PSDU星座图
if PSDU_ofdm_num > 0
    fig = configs.testmat.fig;
    clf(fig);
    ax = axes('Parent', fig);

    scatter(ax, real_PSDU_row, imag_PSDU_row, 8, 'red', 'filled');  % 横轴为实部(同相分量), 纵轴为虚部(正交分量)

    if configs.rx.EVM.enable
        ax.Title.String = ['PSDU归一化星座图, ', PSDU_string];
    else
        ax.Title.String = 'PSDU归一化星座图';
    end
    ax.Title.FontSize  = 12;
    ax.XLabel.String   = 'I路(实部, 同向分量)';
    ax.XLabel.FontSize = 12;
    ax.YLabel.String   = 'Q路(虚部, 正交分量)';
    ax.YLabel.FontSize = 12;

    PSDU_bound = ceil(max([1, max(abs(real_PSDU_row)), max(abs(imag_PSDU_row))])*2) / 2;
    if PSDU_bound <= 5
        ax.XLim       = [-1.05*PSDU_bound, 1.05*PSDU_bound];
        ax.XTick      = -PSDU_bound : 0.5 : PSDU_bound;
        ax.XTickLabel = -PSDU_bound : 0.5 : PSDU_bound;
    end
    ax.XAxisLocation = 'origin';

    if PSDU_bound <= 5
        ax.YLim       = [-1.05*PSDU_bound, 1.05*PSDU_bound];
        ax.YTick      = -PSDU_bound : 0.5 : PSDU_bound;
        ax.YTickLabel = -PSDU_bound : 0.5 : PSDU_bound;
    end
    ax.YAxisLocation = 'origin';

    if strcmp(configs.testmat.fig_type, 'fig')
        savefig(fig, fullfile(configs.testmat.result_path, 'PSDU_constellation.fig'));
    elseif strcmp(configs.testmat.fig_type, 'png')
        exportgraphics(fig, fullfile(configs.testmat.result_path, 'PSDU_constellation.png'), 'Resolution', 300);
    else
        error('[ERROR] Invalid fig_type');
    end
end


end

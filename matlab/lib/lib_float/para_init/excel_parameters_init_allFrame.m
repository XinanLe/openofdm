function configs = excel_parameters_init_allFrame(configs)
%======================================================================================================================%
% Description:
%   所有帧都要配置这些字段, 可修改
%**********************************************************************************************************************%
% Author: lixinan                                                                                      Date: 2026.03.25
%======================================================================================================================%

%% 仿真和测试向量
configs.simu.montekarlo_num = 1;  % 每个SNR点的蒙特卡洛仿真次数

configs.testmat.MATLAB_debug  = 1;   % MATLAB中间数据记录, configs.debug
configs.testmat.result_path   = fullfile(pwd, 'main_results');  % 仿真结果存储目录
configs.testmat.plot_enable   = 0;   % 是否画图
configs.testmat.fig           = [];  % 避免频繁的创建figure, 仅在仿真开始创建, fig = figure();
configs.testmat.fig_type      = 'fig';  % 支持保存格式'fig'和'png'
configs.testmat.fix_enable    = 0;  % 使能开关, 定点仿真


%% Tx公共参数配置
% RF_SG1P0帧类型:
%   'IEEE_SOF'  : STF + LTF + SIG + PSDU
%   'IEEE_SACK' : STF + LTF + SIG
configs.common.frame_type = 'IEEE_SOF';

% 信道间隔支持: 20/10/5 MHz
configs.common.channel_spacing_Mhz = 20;


%% 信道参数配置
% 信道路径数: 1-AWGN信道; 4/5/17-多径信道
configs.channel.channel_path = 1;

% PPDU帧前后加0的采样点数
configs.channel.time_offset_front = 0;
configs.channel.time_offset_end   = 0;

% 载波频率偏差, 单位: Hz
configs.channel.cfo = 0;

% 采样时钟频率偏差, 以当前采样率基准
% 若以采样率75MHz为基准, SFO为x PPM, 则对应绝对SFO为75*x Hz, 则以150MHz为基准, SFO为x/2
configs.channel.ppm = 0;

% 0 : 不加AWGN噪声
% 1 : 配置SNR, 信号+噪声总能量
configs.channel.awgn_type = 0;

configs.channel.awgn_type1.SNR_range = 30;  % 仿真的SNR范围(行向量)
configs.channel.awgn_type1.SignalNoiseMeanPowerEnable = 0;   % 0-不使能信号噪声功率控制; 1-使能信号噪声功率控制
configs.channel.awgn_type1.SignalNoiseMeanPower       = 17;  % dBm


% %% Rx包检测参数
% configs.rx.PacketDetection.enable = 1;  % 0-不做包检测; 1-做包检测
% 
% % FFT开窗提前比例, 范围[0,1], 默认ratio = 0.5, 即FFT开窗位于可用区间中间
% % window_advanced_num = window_advanced_ratio * (rx_GI_num-rx_RI_num)
% configs.rx.PacketDetection.window_advanced_ratio = 0.5;
% 
% configs.rx.PacketDetection.method = 1;
% 
% % method1
% % 对rx_signal尝试不同CFO补偿(CFO_search_min_Hz:CFO_search_step_Hz:CFO_search_max_Hz), 再做STF/LTF包检测
% configs.rx.PacketDetection.method1.CFO_search_min_Hz  = -15e3;
% configs.rx.PacketDetection.method1.CFO_search_max_Hz  =  15e3;
% configs.rx.PacketDetection.method1.CFO_search_step_Hz =   3e3;
% 
% % STF固定5个OFDM, Option1/2/3每个符号重复8/4/2次, STF重复短块40/20/10, 默认取值32/16/8
% configs.rx.PacketDetection.method1.STF_metric_block_ratio    = 0.8;   % 计算STF metric的短块数量
% configs.rx.PacketDetection.method1.STF_peak_metric_threshold = 0.15;  % STF metric的门限(理想情况下metric最大值为1)
% configs.rx.PacketDetection.method1.STF_peak_backoff_ratio    = 0.8;   % 最大STF metric的回退比例, 用于寻找STF的位置
% 
% configs.rx.PacketDetection.method1.LTF_search_start_nfft    = 1;  % STF附近搜索LTF的范围
% configs.rx.PacketDetection.method1.LTF_search_end_nfft      = 7;  % STF附近搜索LTF的范围
% configs.rx.PacketDetection.method1.LTF_global_search_enable = 1;  % 全局搜索LTF使能
% configs.rx.PacketDetection.method1.LTF_peak_to_median_metric_threshold = 4;  % 搜索LTF的门限
% 
% configs.rx.PacketDetection.method1.CFOCompensation_enable = 1;  % 0-包检测后不做粗CFO补偿; 1-包检测后做粗CFO补偿
% 
% 
% %% Rx CFO估计/补偿参数
% configs.rx.CFOEstimation.enable = 1;
% configs.rx.CFOEstimation.method = 2;  % 1/3-重复LTF相位差计算CFO(仅高SNR有效); 2-STF+LTF的CFO/timing联合粗细搜索
% 
% % CFO估计method2
% % CFO频率粗细网格匹配搜索, 并联合考虑包检测的残余定时偏差
% configs.rx.CFOEstimation.method2.large_CFO_range_min  = -5e3;  % 粗搜索下界, Hz
% configs.rx.CFOEstimation.method2.large_CFO_range_max  =  5e3;  % 粗搜索上界, Hz
% configs.rx.CFOEstimation.method2.large_CFO_range_step = 100;   % 粗搜索步长, Hz
% configs.rx.CFOEstimation.method2.small_CFO_range_span = 1000;  % 细搜索半径, Hz
% configs.rx.CFOEstimation.method2.small_CFO_range_step = 10;    % 细搜索步长, Hz
% 
% % timing搜索范围单位为rx_n_fft, 粗搜索默认rx_n_fft/4(GI长度), 细搜索在粗搜索的sample级timing附近继续搜索
% configs.rx.CFOEstimation.method2.large_timing_range_span_ratio = 1/4;
% configs.rx.CFOEstimation.method2.small_timing_range_span_ratio = 1/32;
% 
% 
% configs.rx.CFOCompensation.enable = 1;
% configs.rx.CFOCompensation.method = 1;
% 
% 
% %% Rx PPM估计/补偿参数
% configs.rx.PPMEstimation.enable = 1;
% 
% % 1-逐OFDM pilot timing-offset估计后拟合timing drift
% % 2-LTF参考 + 全帧pilot联合PPM/残余CFO相干搜索(低SNR优先)
% configs.rx.PPMEstimation.method = 2;
% 
% % method1
% configs.rx.PPMEstimation.method1.tau_search_range_span = 0.50;   % tau搜索半径, 单位为spec sample
% configs.rx.PPMEstimation.method1.tau_search_range_step = 0.001;  % tau搜索步长, 单位为spec sample
% configs.rx.PPMEstimation.method1.reliability_thres     = 0.20;   % tau搜索可靠性门限
% 
% % 至少需要足够多的OFDM observation才估PPM；短SACK/短PSDU若不满足会自动旁路补偿。
% configs.rx.PPMEstimation.method1.observation_num_thres = 8;
% 
% % pilot tone-set轮换会使不同tone-set存在固定测量bias；拟合时加入tone-set fixed effect消除该偏置。
% configs.rx.PPMEstimation.method1.cancel_tone_set_bias_enable = 1;
% 
% % Robust weighted LS参数。
% configs.rx.PPMEstimation.method1.huber_k             = 2.5;
% configs.rx.PPMEstimation.method1.huber_iteration_num = 3;
% configs.rx.PPMEstimation.method1.min_fit_dof         = 4;
% 
% % PPM可靠性保护。
% configs.rx.PPMEstimation.method1.max_abs_ppm            = 200;
% configs.rx.PPMEstimation.method1.min_slope_significance = 2.5;
% configs.rx.PPMEstimation.method1.max_fit_rmse_sample    = 0.08;
% 
% % method2
% % method2不使用PSS。LTF只用于全带宽信道相位参考，SIG/PHR/PSDU pilot用于长时间基线PPM估计。
% % 粗搜索：PPM与CFO补偿后的残余CFO联合搜索。
% % 搜索范围刻意大于最终允许补偿范围：若低SNR噪声把峰值推到物理允许范围之外，则直接判失败而不是卡在边界。
% configs.rx.PPMEstimation.method2.large_ppm_range_min  = -150;  % ppm
% configs.rx.PPMEstimation.method2.large_ppm_range_max  =  150;  % ppm
% configs.rx.PPMEstimation.method2.large_ppm_range_step =    5;  % ppm
% configs.rx.PPMEstimation.method2.large_residual_CFO_range_span = 500;  % Hz
% configs.rx.PPMEstimation.method2.large_residual_CFO_range_step =  20;  % Hz
% 
% % 细搜索：在粗搜索峰值附近继续细化。
% configs.rx.PPMEstimation.method2.small_ppm_range_span = 20;   % ppm
% configs.rx.PPMEstimation.method2.small_ppm_range_step = 0.5;  % ppm
% configs.rx.PPMEstimation.method2.small_residual_CFO_range_span = 30;  % Hz
% configs.rx.PPMEstimation.method2.small_residual_CFO_range_step =  2;  % Hz
% 
% % 可靠性保护。低SNR下宁可不补偿，也不使用不稳定的PPM估计值。
% configs.rx.PPMEstimation.method2.observation_num_thres = 12;
% configs.rx.PPMEstimation.method2.max_abs_ppm           = 200;
% configs.rx.PPMEstimation.method2.min_global_coherence      = 0.02;
% configs.rx.PPMEstimation.method2.high_confidence_coherence = 0.50;
% 
% % 当全帧相干度不足以进入high-confidence分支时，只允许明显的大PPM通过，防止低SNR噪声峰造成反向补偿。
% configs.rx.PPMEstimation.method2.low_snr_min_abs_ppm = 80;
% configs.rx.PPMEstimation.method2.low_snr_min_peak_to_median_ratio = 1.08;
% configs.rx.PPMEstimation.method2.low_snr_min_score_gain_vs_zero_dB = 0.25;
% 
% 
% configs.rx.PPMCompensation.enable = 1;
% configs.rx.PPMCompensation.method = 1;
% configs.rx.PPMCompensation.min_abs_ppm = 1;  % 小于此值不执行重采样
% 
% 
% %% Rx导频相位追踪参数
% % 粗CFO补偿后不再估计/二次补偿小残余频偏, 这里只在FFT后的频域做phase tracking
% configs.rx.PilotPhaseTracking.enable = 1;
% 
% % 1: 逐OFDM公共相位补偿
% configs.rx.PilotPhaseTracking.method = 1;
% 
% % method1
% configs.rx.PilotPhaseTracking.method1.reliability_thres = 0.20;
% 
% 
% %% Rx SNR估计参数
% configs.rx.SNREstimation.enable = 1;  % 0-不做SNR估计; 1-做SNR估计
% 
% % 'all'      : 所有SNR估计方法都做
% % 'PLCRTL'   : by PLC RTL, 只有2个LTF时这种方法无效
% % 'RenPaper' : by (2009_RenGuangliang) SNR Estimation Algorithm Based on 
% %                   the Preamble for OFDM Systems in Frequency Selective Channels
% configs.rx.SNREstimation.method = 'RenPaper';


%% Rx信道估计参数
configs.rx.ChannelEstimation.enable = 0;  % 0-不做信道估计; 1-做信道估计

% 0-'LS only';
% 1-'LS + Frequency Smoothing';
% 2-'LS + Time Domain Denoising'
configs.rx.ChannelEstimation.method = 2;


% method1
%   weight : 频域平滑的权重, 正负频率分开平滑
% configs.rx.ChannelEstimation.method1.weight = [1, 2, 1];
% configs.rx.ChannelEstimation.method1.weight = [1, 4, 6, 4, 1];
configs.rx.ChannelEstimation.method1.weight = [1, 6, 15, 20, 15, 6, 1];


% method2
%   DC_fit_tone_num            : DC左右各使用DC_fit_tone_num个有效子载波, 用于DC的拟合
%   virtual_phase_fit_tone_num : 左右各使用virtual_phase_fit_tone_num个边缘子载波, 外推虚拟子载波的相位(幅度不变)
%   time_window_divisor        : 时域固定窗长为spec_n_fft/time_window_divisor
configs.rx.ChannelEstimation.method2.DC_fit_tone_num = 1;
configs.rx.ChannelEstimation.method2.virtual_phase_fit_tone_num = 4;
configs.rx.ChannelEstimation.method2.time_window_divisor = 4;


%% Rx信道均衡参数
configs.rx.ChannelEqualization.enable = 0;  % 0-不做信道均衡; 1-做信道均衡

configs.rx.ChannelEqualization.method = 'amp_phase';  % 'amp_phase'和'phase'


% %% Rx计算EVM
% configs.rx.EVM.enable = 1;  % 0-不计算EVM; 1-计算EVM
% configs.rx.EVM.method = 1;  % 只有方法1, 为后续代码演进预留接口


%% Rx Turbo译码参数
% traceback_depth : 
configs.rx.turbo_decoder.SIG_traceback_depth = 15;

% 应该要跟code_rate相关
configs.rx.turbo_decoder.PSDU_traceback_depth = 60;


%% MATLAB比对, 此段代码不修改
% RTL比对, 按要求将文件分开放, current_RTL_result_path是matlab产生的文件, current_RTL_case_path是RTL给matlab的文件
configs.testmat.RTL_debug               = 0;
configs.testmat.RTL_compare_enable      = 0;   % RxCompare回调TxCompare时, 原始数据要加载, 不需要compare
configs.testmat.current_RTL_mpdu_idx    = 0;   % 当前case的MPDU索引, 从0开始编号
configs.testmat.current_RTL_chip_idx    = 0;   % 当前case的Chip索引, 从0开始编号
configs.testmat.current_RTL_pass_flag   = 0;   % 0-当前Case比对没有通过, 1-当前Case比对通过(所有比对节点均通过)
configs.testmat.current_RTL_result_path = [];  % ./matlab_dir/chip_X_mpdu_X的绝对路径
configs.testmat.current_RTL_case_path   = [];  % ./compare_dir/chip_X_mpdu_X的绝对路径


end

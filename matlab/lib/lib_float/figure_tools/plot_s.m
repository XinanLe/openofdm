function plot_s(in, varargin)
% 画频谱图 by 邢智博
%if nargin < 2
%    fs = 80;
%end
if isempty(varargin)
    fs = 80;
    fig_num = [];
    sub_num = 2;
    sub_idx = 1;
else
    if nargin==2
        fs = varargin{1};
        fig_num = [];
        sub_num = 2;
        sub_idx = 1;
    elseif nargin==3
        fs = varargin{1};
        fig_num = varargin{2};
        sub_num = 2;
        sub_idx = 1;
    elseif nargin>=4
        fs = varargin{1};
        fig_num = varargin{2};
        sub_num = varargin{3};
        sub_idx = varargin{4};
        assert(sub_idx<=sub_num/2);
    end
end

if ~real(in)
    in = in(:,1)+in(:,2)*1i;
end

in_pow = abs(in).^2;
in_pow_max = max(in_pow);
in_pow_mean = mean(in_pow);
papr = 10*log10(in_pow_max) - 10*log10(in_pow_mean);

if isempty(fig_num)
    figure;
else
    figure(fig_num);
end

t = (0:length(in)-1)/fs;
subplot(sub_num,1,(sub_idx-1)*2+1);plot(t, real(in));hold on;plot(t, imag(in));hold off;grid on;
title(['mean\_I:' num2str(mean(real(in)),'%.6f') ' mean\_Q:' num2str(mean(imag(in)),'%.6f') ' mean\_pow: ' num2str(10*log10(mean(abs(in).^2)),'%.2f') ' papr:' num2str(papr,'%.2f')]);
xlabel('sampling point(us)');ylabel('value');

fft_len = fs*100;

if length(in) < fft_len
    [pxif, fif] = pwelch(in, ones(1,length(in)), 0, length(in), fs, 'power', 'two-sided');
else
    [pxif, fif] = pwelch(in, ones(1,fft_len), 0, fft_len, fs, 'power', 'two-sided');
%     [pxif, fif] = pwelch(in, [], [], [], fs);
end

loc = find(pxif==0);
pxif(loc) = 10^(-500/10);

if 0
    pxif_tmp = 10*log10((fftshift(pxif)));
    [~, max_loc] = max(pxif_tmp);
    pxif_tmp = pxif_tmp - pxif_tmp(max_loc);
else
    pxif_tmp = 10*log10((fftshift(pxif)));
end

subplot(sub_num,1,(sub_idx-1)*2+2);plot(fif-fs/2, pxif_tmp);grid on;
xlabel('frequency(MHz)');
%ylabel('psd(dB/Hz)');
ylabel('amplitude(dB)');
%ylim([-Inf,Inf]);
return;
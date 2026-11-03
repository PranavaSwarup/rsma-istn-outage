%% FIG2_CHECK  Sanity check of the system model against the paper's Fig. 2
% K = 3, alpha_c = 0.4, alpha_1 = alpha_2 = alpha_3 = 0.2, gc_th = gp_th = 0.4
% RSMA user k is the generic (unordered) user, as in the paper's analysis.
% Paper's Fig. 2 simulation points (read off the published plot; the 5 dBW,
% T = 3 value 8.74e-3 is quoted in the paper's text):
%   T = 1 : 0.55 @ 10 dBW,  0.145 @ 15 dBW,  0.047 @ 20 dBW
%   T = 2 : 0.15 @  5 dBW,  8.7e-3 @ 10 dBW, 4.95e-4 @ 15 dBW
%   T = 3 : 0.35 @  0 dBW,  8.74e-3 @ 5 dBW, 1.4e-4 @ 10 dBW
clear; clc;
p = istn_params();
p.alpha_p = [0.2 0.2 0.2];
PsdB = -10:5:20;
N    = 2e6;            % T = 3 points below ~1e-5 need N >= 1e7

ref = { [10 0.55; 15 0.145; 20 0.047], ...
        [5 0.15; 10 8.7e-3; 15 4.95e-4], ...
        [0 0.35; 5 8.74e-3; 10 1.4e-4] };

nz = @(v) v ./ (v > 0);               % 0 -> NaN (dropped from log plot)
figure('Color','w'); hold on; grid on; box on;
if exist('theme','file') || exist('theme','builtin'), theme(gcf,'light'); end   % R2025a+ dark mode hides black markers
mk = {'o','x','s'};
for T = 1:3
    [OP, A1, A2] = rsma_outage(PsdB, T, N, p);
    fprintf('T=%d  ours: ', T); fprintf('%.2e  ', OP); fprintf('\n');
    for r = 1:size(ref{T},1)
        i = find(PsdB == ref{T}(r,1));
        fprintf('       %2d dBW: ours %.2e  paper %.2e  (ratio %.2f)\n', ...
                ref{T}(r,1), OP(i), ref{T}(r,2), OP(i)/ref{T}(r,2));
    end
    semilogy(PsdB, nz(OP), ['k' mk{T}], 'MarkerSize', 7);
    semilogy(PsdB, nz(min(A1+A2,1)), 'b-', PsdB, nz(max(A1,A2)), 'r--');
end
set(gca,'YScale','log'); ylim([1e-6 1.5]);
xlabel('P_s (dBW)'); ylabel('Outage probability'); title('Fig. 2 check (K = 3)');

h(1) = plot(nan, nan, 'ko');  h(2) = plot(nan, nan, 'kx');  h(3) = plot(nan, nan, 'ks');
h(4) = plot(nan, nan, 'b-');  h(5) = plot(nan, nan, 'r--');
legend(h, {'Sim T=1','Sim T=2','Sim T=3','Upper bound (MC)','Lower bound (MC)'}, ...
       'Location', 'southwest');

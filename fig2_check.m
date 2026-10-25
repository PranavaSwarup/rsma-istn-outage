%% FIG2_CHECK  Sanity check of the system model against the paper's Fig. 2
% K = 3, alpha_c = 0.4, alpha_1 = alpha_2 = alpha_3 = 0.2, gc_th = gp_th = 0.4
% Paper's Fig. 2 values to compare against (read off the plot / text):
%   T = 2 : ~8.6e-3 at 10 dBW,  ~5e-4 at 15 dBW
%   T = 3 : ~8.7e-3 at  5 dBW,  ~1.5e-4 at 10 dBW
clear; clc;
p = istn_params();
p.alpha_p = [0.2 0.2 0.2];
PsdB = -10:5:20;
N    = 2e6;

figure('Color','w'); hold on; grid on; box on;
mk = {'o','x','s'};
for T = 1:3
    [OP, A1, A2] = rsma_outage(PsdB, T, N, p);
    fprintf('T=%d: ', T); fprintf('%.2e  ', OP); fprintf('\n');
    semilogy(PsdB, OP, ['k' mk{T}], 'MarkerSize', 7);
    semilogy(PsdB, min(A1+A2,1), 'b-', PsdB, max(A1,A2), 'r--');
end
set(gca,'YScale','log'); ylim([1e-6 1.5]);
xlabel('P_s (dBW)'); ylabel('Outage probability'); title('Fig. 2 check (K = 3)');

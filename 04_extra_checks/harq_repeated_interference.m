%% HARQ_REPEATED_INTERFERENCE  How optimistic is "sum the SINRs over rounds"?
% Paper / mc_outage :  decode iff  sum_t gamma(x_t) >= gamma_th
% Repeated model    :  decode iff  gamma(sum_t x_t) >= gamma_th
%   (same packet resent => interference repeats and combines coherently;
%    see mc_outage_repeated.m for the derivation)
% In the repeated model every condition is again ONE bar on S = sum_t x_t,
% so the generic RSMA user (and an OMA user) has an exact closed form:
%     P_out = F_T( max(bar_c, bar_p) )        (sr_cdf_T)
% and the ceiling theta = delta/vartheta cannot be exceeded by adding rounds.
clear; clc;
setup_extra_paths();
p = istn_params();
St = sinr_streams(p);

PsdB = 0:2.5:20;
N    = 2e6;
rho  = 10.^(PsdB/10) * p.g;
bar  = max(threshold_on_gain(St.rsma_c, rho), threshold_on_gain(St.rsma_p, rho));

fprintf('RSMA generic user: paper model (sum of SINRs) vs repeated interference\n');
fprintf('%4s %7s %13s %13s %13s %8s\n', 'T', 'Ps', 'sum (MC)', 'repeat (MC)', 'repeat exact', 'ratio');
res = struct();
for T = 1:3
    a = mc_outage(PsdB, T, N, p);
    b = mc_outage_repeated(PsdB, T, N, p);
    e = sr_cdf_T(bar, p, T);
    res(T).sum = a;  res(T).rep = b;  res(T).exact = e;
    for i = [3 5]                                   % 5 and 10 dBW
        fprintf('%4d %7.1f %13.3e %13.3e %13.3e %8.2f\n', T, PsdB(i), ...
            a.rsma_user(i), b.rsma_user(i), e(i), b.rsma_user(i) / max(a.rsma_user(i), eps));
    end
end

fprintf('\nNOMA (Monte Carlo, ordering ''%s''), 5 dBW:\n', p.order);
fprintf('%4s %-10s %13s %13s\n', 'T', 'user', 'sum', 'repeat');
for T = 1:3
    for q = {'noma_far', 'noma_near'}
        fprintf('%4d %-10s %13.3e %13.3e\n', T, q{1}, res(T).sum.(q{1})(3), res(T).rep.(q{1})(3));
    end
end
fprintf('\nOMA is identical in both models (no interference): T = 2, 5 dBW  sum %.3e  repeat %.3e\n', ...
    res(2).sum.oma_weak(3), res(2).rep.oma_weak(3));

%% Ceiling check: at very high power the two models differ in kind
fprintf('\nMax accumulated common-stream SINR as rho -> Inf:\n');
for T = 1:3
    fprintf('  T = %d :  sum model %.3f   repeated model %.3f   (threshold %.1f)\n', ...
        T, T * St.rsma_c.ceiling, St.rsma_c.ceiling, St.rsma_c.gth);
end

%% Figure
figure('Color', 'w'); hold on; box on; grid on;
cols = lines(3);
for T = 1:3
    semilogy(PsdB, res(T).sum.rsma_user, 'o--', 'Color', cols(T, :));
    semilogy(PsdB, res(T).exact, '-', 'Color', cols(T, :), 'LineWidth', 1.6);
    semilogy(PsdB, res(T).rep.rsma_user, 'x', 'Color', cols(T, :));
end
set(gca, 'YScale', 'log'); ylim([1e-5 1]);
xlabel('P_s (dBW)'); ylabel('Outage probability, RSMA user');
title('HARQ-CC: summed SINR (dashed) vs repeated interference (solid exact, x MC)');
legend('T=1 sum', 'T=1 repeated exact', 'T=1 repeated MC', ...
       'T=2 sum', 'T=2 repeated exact', 'T=2 repeated MC', ...
       'T=3 sum', 'T=3 repeated exact', 'T=3 repeated MC', 'Location', 'southwest');
saveas(gcf, 'harq_repeated_interference.png');

%% ISIC_FLOOR  Imperfect SIC (Singh et al., ref. [12]) puts an error floor on
% every user that performs SIC: the NOMA near (strong) user and the RSMA user's
% private stream. T = 1.
%
% With residual rho*|g_I|^2 the condition delta*rho*x/(vartheta*rho*x+rho*g+1)
% >= gamma becomes, as rho -> Inf,  x >= c*g  with  c = gamma/(delta-gamma*vartheta),
% so the outage tends to a CONSTANT (diversity order 0):
%   NOMA near user : floor = E_g[ F(c_max*g)^2 ],  c_max = max over its two steps
%   RSMA user      : floor = E_g[ F(c_p*g) ]       (private stream; common has no residual)
% computed below by numerical integration over g ~ Exp(OmegaI).
clear; clc;
setup_extra_paths();
p  = istn_params();
St = sinr_streams(p);

PsdB = -5:5:40;
N    = 1e6;
OmI_dB = [-20 -10];

cfun = @(s) s.gth / (s.delta - s.gth * s.vartheta);
c_n  = max(cfun(St.noma_1), cfun(St.noma_2));
c_p  = cfun(St.rsma_p);

pf  = op_closed_form_T1(PsdB, p);                  % perfect SIC, exact
figure('Color', 'w'); hold on; box on; grid on;
semilogy(PsdB, pf.noma_near, 'k-', 'LineWidth', 1.4);
semilogy(PsdB, pf.rsma_user, 'b-', 'LineWidth', 1.4);
leg = {'NOMA near, perfect SIC', 'RSMA user, perfect SIC'};
mk  = {'s', 'o'};

fprintf('Error floors with imperfect SIC (T = 1)\n');
for j = 1:numel(OmI_dB)
    OmI = 10^(OmI_dB(j)/10);
    g   = linspace(0, 40*OmI, 20001);
    fg  = exp(-g/OmI) / OmI;
    floor_n = trapz(g, sr_cdf(c_n*g, p).^2 .* fg);
    floor_r = trapz(g, sr_cdf(c_p*g, p) .* fg);
    op = mc_outage_isic(PsdB, N, p, OmI);
    fprintf('\nOmega_I = %d dB:  floor NOMA near %.3e   floor RSMA %.3e\n', OmI_dB(j), floor_n, floor_r);
    fprintf('  Ps(dBW)  NOMA near (I-SIC)  NOMA near (P-SIC)  RSMA (I-SIC)  RSMA (P-SIC)\n');
    for i = 1:numel(PsdB)
        fprintf('  %6d   %14.3e   %14.3e   %12.3e  %12.3e\n', PsdB(i), ...
            op.noma_near(i), pf.noma_near(i), op.rsma_user(i), pf.rsma_user(i));
    end
    semilogy(PsdB, op.noma_near, ['k' mk{j} '--']);
    semilogy(PsdB, op.rsma_user, ['b' mk{j} '--']);
    semilogy(PsdB([1 end]), floor_n*[1 1], 'k:');
    semilogy(PsdB([1 end]), floor_r*[1 1], 'b:');
    leg = [leg, {sprintf('NOMA near, I-SIC %d dB', OmI_dB(j)), sprintf('RSMA, I-SIC %d dB', OmI_dB(j)), ...
                 'NOMA near floor', 'RSMA floor'}];
end
fprintf('\nNOMA far user and OMA perform no SIC, so they are unaffected.\n');
set(gca, 'YScale', 'log'); ylim([1e-6 1]);
xlabel('P_s (dBW)'); ylabel('Outage probability, T = 1');
title('Imperfect SIC (ref. [12]) gives an error floor: diversity 0');
legend(leg, 'Location', 'southwest');
try, theme(gcf, 'light'); catch, end
saveas(gcf, 'isic_floor.png');

%% NOMA_IMPERFECTIONS  Effect of [12]'s non-ideal conditions on the HARQ-CC NOMA pair.
% Hu et al. assume perfect hardware and perfect SIC. Ref. [12] (Singh et al.)
% adds hardware impairments (lambda, EVM) and imperfect SIC (residual |gI|^2,
% Omega_I). This script shows what each does to the far and near users.
clear; clc;
PsdB = -10:5:40;  N = 2e6;  T = 3;   % wide range so the I-SIC error floor shows
cases = { 'ideal (Hu et al.)',      {};
          'HI, \lambda = 0.141',     {'lambda_hi',0.1*sqrt(2)};   % [12]: lambda_su = sqrt(2)*lambda_0
          'I-SIC, \Omega_I = -20 dB',{'isic',1,'Omega_I_dB',-20};
          'I-SIC, \Omega_I = -10 dB',{'isic',1,'Omega_I_dB',-10};
          'I-SIC, \Omega_I = 0 dB',  {'isic',1,'Omega_I_dB',0} };
figure('Color','w'); hold on; grid on; box on;
st = {'-o','-s','-^','-v','-d'};
for c = 1:size(cases,1)
    p = istn_params(cases{c,2}{:});
    [OPf, OPn] = noma_outage(PsdB, T, N, p);
    semilogy(PsdB, OPf./(OPf>0), st{c}, 'Color',[0.85 0.1 0.1], 'DisplayName', ['far, '  cases{c,1}]);
    semilogy(PsdB, OPn./(OPn>0), st{c}, 'Color',[0.1 0.3 0.85], 'DisplayName', ['near, ' cases{c,1}]);
end
set(gca,'YScale','log'); ylim([1e-6 1.5]);
xlabel('P_s (dBW)'); ylabel('Outage probability');
title(sprintf('HARQ-CC NOMA, T = %d: imperfections from ref. [12]', T));
legend('Location','southwest');
exportgraphics(gcf, 'noma_imperfections.png', 'Resolution', 200);

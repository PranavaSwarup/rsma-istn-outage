%% MAKE_FOUR_PLOTS  The four plots the professor asked for, saved to ./out/
%   1. Shadowed-Rician channel PDF, simulation vs eq. (4)   (Rician_Dist.m, Abel)
%   2. OMA  outage, T = 1 and T = 3                          (oma_outage.m)
%   3. NOMA outage, far and near user, T = 1 and T = 3       (noma_outage.m)
%   4. RSMA outage, simulation + eq. (8) bounds, T = 1, 3    (rsma_outage.m)
% Run from this folder:  >> make_four_plots
root = fileparts(mfilename('fullpath'));
addpath(root, fullfile(root,'01_fig4_monte_carlo'), fullfile(root,'03_shadowed_rician_pdf'));
if ~exist(fullfile(root,'out'),'dir'), mkdir(fullfile(root,'out')); end
light = @(f) evalc('try, theme(f, ''light''); catch, end');   % R2025b dark theme -> light

cd(fullfile(root,'03_shadowed_rician_pdf'));  run('Rician_Dist.m');
root = fileparts(which('make_four_plots'));   % Rician_Dist runs 'clear'
light = @(f) evalc('try, theme(f, ''light''); catch, end');
light(gcf); saveas(gcf, fullfile(root,'out','1_shadowed_rician_pdf.png'));

cd(root);
oma_outage;   light(gcf); title('OMA (TDMA): weak and strong user'); saveas(gcf, fullfile(root,'out','2_oma_outage.png'));
noma_outage;  light(gcf); title('NOMA: far (weak) and near (strong) user'); saveas(gcf, fullfile(root,'out','3_noma_outage.png'));
rsma_outage;  light(gcf); title('RSMA: user k, simulation and eq. (8) bounds'); saveas(gcf, fullfile(root,'out','4_rsma_outage.png'));
fprintf('\n===== FOUR PLOTS DONE =====\n');

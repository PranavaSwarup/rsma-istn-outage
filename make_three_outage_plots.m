% MAKE_THREE_OUTAGE_PLOTS  Re-make plots 2-4 only (OMA, NOMA, RSMA) into ./out/
root = fileparts(mfilename('fullpath'));  addpath(root, fullfile(root,'01_fig4_monte_carlo'));
cd(root); close all;
light = @(f) evalc('try, theme(f, ''light''); catch, end');
oma_outage;   light(gcf); title('OMA (TDMA): weak and strong user');         saveas(gcf, fullfile(root,'out','2_oma_outage.png'));
noma_outage;  light(gcf); title('NOMA: far (weak) and near (strong) user');  saveas(gcf, fullfile(root,'out','3_noma_outage.png'));
rsma_outage;  light(gcf); title('RSMA: user k, simulation and eq. (8) bounds'); saveas(gcf, fullfile(root,'out','4_rsma_outage.png'));
fprintf('\n===== THREE PLOTS DONE =====\n');

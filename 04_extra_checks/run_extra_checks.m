%% RUN_EXTRA_CHECKS  Runs every script in 04_extra_checks and logs the output.
% Run from this folder:  >> run_extra_checks
% Log: out/extra_checks_log.txt   Figures: out/*.png
% Takes a few minutes (Monte Carlo with 1e6 to 2e6 trials per point).
% Each script starts with "clear", so the folder is looked up again each time.
cd(fileparts(mfilename('fullpath'))); addpath(pwd);
if ~exist('out', 'dir'), mkdir('out'); end
diary off;
if exist(fullfile('out', 'extra_checks_log.txt'), 'file'), delete(fullfile('out', 'extra_checks_log.txt')); end
diary(fullfile('out', 'extra_checks_log.txt'));
close all;

fprintf('\n===================== sr_cdf_steps =====================\n');
cd(fileparts(which('run_extra_checks'))); run('sr_cdf_steps.m');
fprintf('\n===================== oma_diversity_exact =====================\n');
cd(fileparts(which('run_extra_checks'))); run('oma_diversity_exact.m');
fprintf('\n===================== rsma_nesting_demo =====================\n');
cd(fileparts(which('run_extra_checks'))); run('rsma_nesting_demo.m');
fprintf('\n===================== ordering_compare =====================\n');
cd(fileparts(which('run_extra_checks'))); run('ordering_compare.m');
fprintf('\n===================== harq_repeated_interference =====================\n');
cd(fileparts(which('run_extra_checks'))); run('harq_repeated_interference.m');
fprintf('\n===================== isic_floor =====================\n');
cd(fileparts(which('run_extra_checks'))); run('isic_floor.m');

cd(fileparts(which('run_extra_checks')));
movefile('harq_repeated_interference.png', fullfile('out', 'harq_repeated_interference.png'));
movefile('isic_floor.png', fullfile('out', 'isic_floor.png'));
close all;
fprintf('\n===== ALL EXTRA CHECKS DONE =====\n');
diary off;

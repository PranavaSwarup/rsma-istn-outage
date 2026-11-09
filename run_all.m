%% RUN_ALL  Runs every week-3 check and saves all figures to ./out/
% Run from this folder:  >> run_all
% Log goes to out/run_log.txt
here = fileparts(mfilename('fullpath'));  cd(here);  addpath(here);   % so which('run_all') finds the root after scripts run 'clear'
if ~exist('out','dir'), mkdir('out'); end
diary off; if exist(fullfile('out','run_log.txt'),'file'), delete(fullfile('out','run_log.txt')); end
diary(fullfile('out','run_log.txt'));
close all;

fprintf('\n===== ceiling_report =====\n');
cd(fullfile(fileparts(which('run_all')), '02_sinr_closed_form_outage')); run('ceiling_report.m');
fprintf('\n===== verify_closed_form =====\n');
cd(fullfile(fileparts(which('run_all')), '02_sinr_closed_form_outage')); run('verify_closed_form.m');
F = findobj('Type','figure'); for i = 1:numel(F), saveas(F(i), fullfile(fileparts(which('run_all')),'out',sprintf('verify_%d.png',F(i).Number))); end; close all;

fprintf('\n===== sr_pdf_check =====\n');
cd(fullfile(fileparts(which('run_all')), '03_shadowed_rician_pdf')); run('sr_pdf_check.m');
copyfile('*.png', fullfile(fileparts(which('run_all')),'out')); close all;

fprintf('\n===== fig4_reproduce (both orderings) =====\n');
cd(fullfile(fileparts(which('run_all')), '01_fig4_monte_carlo')); run('fig4_reproduce.m');
copyfile('fig4_both_orderings.png', fullfile(fileparts(which('run_all')),'out')); close all;

cd(fileparts(which('run_all')));
fprintf('\n===== ALL DONE =====\n');
diary off;

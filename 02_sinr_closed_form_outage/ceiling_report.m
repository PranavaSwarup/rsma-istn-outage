%% CEILING_REPORT  Print every SINR stream, its ceiling and whether its target
% can be reached at all. If threshold >= ceiling, outage = 1 at ANY power, and
% (for HARQ-CC, Hu et al. eq. (16)) the full diversity D = T is lost.
clear; clc;
setup_paths();

cases = {'Fig. 4 settings (K = 2)', [0.3 0.3];
         'Fig. 2 settings (K = 3)', [0.2 0.2 0.2]};

for c = 1:size(cases, 1)
    p = istn_params();
    p.alpha_p = cases{c, 2};
    S = sinr_streams(p);
    fprintf('\n%s\n', cases{c, 1});
    fprintf('  %-16s %7s %9s %9s %10s  %s\n', 'stream', 'delta', 'vartheta', 'ceiling', 'threshold', 'reachable');
    for f = {'oma', 'noma_1', 'noma_2', 'rsma_c', 'rsma_p'}
        s = S.(f{1});
        fprintf('  %-16s %7.3f %9.3f %9.3f %10.4f  %s\n', s.name, s.delta, s.vartheta, ...
                s.ceiling, s.gth, mat2str(s.reachable));
    end
end
fprintf('\nCompare: Hu et al. quote theta_c = 2/3 and theta_p = 1/2 for Fig. 2.\n');

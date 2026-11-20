%% ORDERING_COMPARE  Weak/strong user ordering under HARQ-CC: 'round' vs 'first'.
% 'round' : weak user re-chosen every round (code default; reproduces the
%           paper's Fig. 4 ranking at T = 3).
% 'first' : roles fixed by round 1 (same packet resent, so physically consistent).
% Identical at T = 1; 'round' gives the weak user the worse channel in EVERY
% round, so it is pessimistic for the weak user and optimistic for the strong.
clear; clc;
setup_extra_paths();
p0 = istn_params();
PsdB = [5 10];
N    = 2e6;

q = {'oma_weak','noma_far','noma_near'};
fprintf('%-10s %-4s %-6s %12s %12s %8s\n', 'user', 'T', 'Ps', '''round''', '''first''', 'ratio');
for T = 1:3
    p = p0;  p.order = 'round';  a = mc_outage(PsdB, T, N, p);
    p = p0;  p.order = 'first';  b = mc_outage(PsdB, T, N, p);
    for j = 1:numel(q)
        for i = 1:numel(PsdB)
            ra = a.(q{j})(i);  rb = b.(q{j})(i);
            fprintf('%-10s %-4d %-6d %12.3e %12.3e %8.2f\n', q{j}, T, PsdB(i), ra, rb, ra / max(rb, eps));
        end
    end
end

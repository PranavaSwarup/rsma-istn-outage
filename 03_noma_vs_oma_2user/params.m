function p = params()
% PARAMS  Every setting in one place. Change a value here and re-run main.m.
%
% Setup: downlink, 2 users, single transmission (T = 1), Shadowed-Rician
% fading. Notation follows our RSMA-ISTN work (Hu et al., IEEE TVT 2025):
%   user 1 = WEAK (far)   -> gets the larger power share a1
%   user 2 = STRONG (near)-> gets the smaller power share a2, does SIC
% Defaults are the values from our old project (average shadowing, Fig. 4).

%% ---------------- Shadowed-Rician channel (average shadowing)  [Step 9]
p.b     = 0.126;   % 2b    = average power of the scattered (multipath) part
p.m     = 10.1;    % m     = Nakagami-m severity of the LOS part
p.Omega = 0.835;   % Omega = average power of the LOS part

%% ---------------- Link budget  [Step 1]
p.g = 1.186;       % g = Gk^2/N0 (0.74 dB), so rho = Ps*g  (from old istn_params)

%% ---------------- NOMA power split  [Step 3]
p.a1 = 0.7;        % weak user's power share   (a1 > a2)
p.a2 = 0.3;        % strong user's power share (a1 + a2 = 1)

%% ---------------- Target rates (bit/s/Hz)  [Step 5]
p.R1 = 0.728;      % weak user's target rate   (old: Rc/2 + Rp)
p.R2 = 0.728;      % strong user's target rate (separate variable, starts equal)

%% ---------------- Sweep and simulation
p.PsdB  = -20:2:20;  % transmit power Ps (dBW) on the x-axis
p.N     = 1e6;       % Monte Carlo trials per power point  [Step 11]
p.seed  = 1;         % fixed seed so every run gives the same points
p.nTerms = 100;      % terms kept in the Shadowed-Rician CDF series [Step 9]

%% ---------------- Derived values (do not edit; computed from the above)
p.gth1    = 2^p.R1 - 1;        % NOMA threshold, weak user      [Step 5]
p.gth2    = 2^p.R2 - 1;        % NOMA threshold, strong user
p.gth1OMA = 2^(2*p.R1) - 1;    % OMA threshold (half the time), weak
p.gth2OMA = 2^(2*p.R2) - 1;    % OMA threshold, strong
p.theta   = p.a1/p.a2;         % weak user's SINR ceiling        [Step 3]
end

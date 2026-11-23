function S = outage_simulation(p)
% OUTAGE_SIMULATION  Monte Carlo outage probability.            [Step 11]
% Uses the raw SINRs only (no bars, no CDF), so matching the analysis
% is a genuine check of Steps 6-10.
% Returns S.noma_w, S.noma_s, S.oma_w, S.oma_s, one value per Ps in p.PsdB.

rng(p.seed);

% ---- Step 11.1-11.2: two users, order them
x1 = sr_gain([p.N 1], p);
x2 = sr_gain([p.N 1], p);
xw = min(x1, x2);                 % weak (far) user
xs = max(x1, x2);                 % strong (near) user

nP = numel(p.PsdB);
S.noma_w = zeros(1,nP);  S.noma_s = zeros(1,nP);
S.oma_w  = zeros(1,nP);  S.oma_s  = zeros(1,nP);

for i = 1:nP
    rho = 10^(p.PsdB(i)/10) * p.g;            % Step 1

    % ---- Step 3: NOMA SINRs
    g1  = p.a1*rho*xw ./ (p.a2*rho*xw + 1);   % weak user, s2 as noise
    g21 = p.a1*rho*xs ./ (p.a2*rho*xs + 1);   % strong user, SIC step A
    g2  = p.a2*rho*xs;                        % strong user, step B

    % ---- Step 4: OMA SINRs (full power, half the time)
    gw_oma = rho*xw;
    gs_oma = rho*xs;

    % ---- Step 11.4-11.5: count failures / N
    S.noma_w(i) = mean(g1 < p.gth1);
    S.noma_s(i) = mean(g21 < p.gth1 | g2 < p.gth2);   % A fails OR B fails
    S.oma_w(i)  = mean(gw_oma < p.gth1OMA);
    S.oma_s(i)  = mean(gs_oma < p.gth2OMA);
end
end

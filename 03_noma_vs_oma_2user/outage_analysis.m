function A = outage_analysis(p)
% OUTAGE_ANALYSIS  Closed-form outage probability (no randomness).  [Steps 5-10]
% Returns A.noma_w, A.noma_s, A.oma_w, A.oma_s, one value per Ps in p.PsdB.

rho = 10.^(p.PsdB/10) * p.g;                   % Step 1: rho = Ps*g

% ---- Step 6: weak user's NOMA bar  y_w = gth1 / (rho (a1 - gth1 a2))
den = p.a1 - p.gth1*p.a2;
if den <= 0                                    % gth1 >= ceiling theta
    warning('gth1 >= a1/a2: NOMA weak user (and SIC step A) always in outage.');
    yw = Inf(size(rho));
else
    yw = p.gth1 ./ (rho*den);
end

% ---- Step 7: strong user must pass step A (bar y_w) AND step B
yB = p.gth2 ./ (rho*p.a2);                     % step B: a2*rho*x >= gth2
ys = max(yw, yB);                              % larger bar binds

% ---- Step 6 (OMA rows): bar = (2^(2R) - 1)/rho
yw_oma = p.gth1OMA ./ rho;
ys_oma = p.gth2OMA ./ rho;

% ---- Steps 8-10: weak = 1 - (1-F)^2, strong = F^2
A.noma_w = 1 - (1 - sr_cdf(yw, p)).^2;
A.noma_s = sr_cdf(ys, p).^2;
A.oma_w  = 1 - (1 - sr_cdf(yw_oma, p)).^2;
A.oma_s  = sr_cdf(ys_oma, p).^2;
end

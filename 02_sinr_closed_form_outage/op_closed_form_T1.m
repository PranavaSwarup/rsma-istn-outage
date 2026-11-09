function op = op_closed_form_T1(PsdB, p)
% OP_CLOSED_FORM_T1  Exact outage probability with no HARQ (T = 1).
%
% With one round, every decoding condition of a user is a threshold on the
% SAME |h|^2 (see threshold_on_gain). "Decode every needed stream" is then
% simply |h|^2 >= the LARGEST threshold, so the outage is exact:
%
%     P_out = F( max_l xi_l )
%
% where F is the CDF of the user's gain. For two ordered users (as in the
% Fig. 4 comparison) the weak user has the min gain and the strong user the
% max gain of two i.i.d. draws:
%     F_weak(x)   = 1 - (1 - F(x))^2
%     F_strong(x) = F(x)^2
%
% Outputs (row vectors over PsdB):
%   op.oma_weak, op.oma_strong   OMA (TDMA)
%   op.noma_far, op.noma_near    NOMA weak / strong (near user needs s1 AND s2)
%   op.rsma_user                 RSMA generic i.i.d. user k (paper's analysis)
%   op.rsma_weak                 RSMA min-gain user out of K
%   op.rsma_PrA1, op.rsma_PrA2   Pr{common fails}, Pr{private fails}  (eq. 8)
%
% For T > 1 the SINRs are summed over rounds and no single threshold exists;
% use mc_outage (or the paper's eqs. (8), (9), (11) bounds) instead.

S   = sinr_streams(p);
rho = 10.^(PsdB/10) * p.g;

F       = @(x) sr_cdf(x, p);
Fmin    = @(x, K) 1 - (1 - F(x)).^K;
Fmax    = @(x, K) F(x).^K;

xi_oma  = threshold_on_gain(S.oma,    rho);
xi_n1   = threshold_on_gain(S.noma_1, rho);
xi_n2   = threshold_on_gain(S.noma_2, rho);
xi_c    = threshold_on_gain(S.rsma_c, rho);
xi_p    = threshold_on_gain(S.rsma_p, rho);

op.oma_weak   = Fmin(xi_oma, 2);
op.oma_strong = Fmax(xi_oma, 2);

op.noma_far   = Fmin(xi_n1, 2);                    % far user decodes s1 only
op.noma_near  = Fmax(max(xi_n1, xi_n2), 2);        % SIC: s1 then s2

op.rsma_PrA1  = F(xi_c);
op.rsma_PrA2  = F(xi_p);
op.rsma_user  = F(max(xi_c, xi_p));                % exact, no bounds needed
op.rsma_weak  = Fmin(max(xi_c, xi_p), S.K_rsma);
end

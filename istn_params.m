function p = istn_params(varargin)
% ISTN_PARAMS  System parameters from Hu et al., "Outage Analysis of RSMA
% Enabled Integrated Satellite-Terrestrial Networks", IEEE TVT, Jun. 2025.
% NOMA/OMA modelling follows the paper's reference [12]: C. K. Singh,
% P. K. Upadhyay, J. Lehtomaki, M. Juntti, IEEE TVT, vol. 73, no. 1, 2024.
%
%   p = istn_params()                               % defaults (physical model)
%   p = istn_params('order','first','extra_gain_dB',0)
%   p = istn_params('preset','fig4')                % settings that best match Fig. 4
%
% Tags:  [paper] from Hu et al. | [12] from Singh et al. | [ASSUMED] ours
%
% Name-value options
%   'order'         'round' (default) weak user = min of the two gains in EVERY
%                   round: [12]'s instantaneous ordering applied per round. Rounds
%                   stay i.i.d., which is what the paper's Laplace-transform
%                   analysis needs, so this is the only ordering that lets the
%                   paper draw "Analytical-NOMA/OMA" curves.
%                   'first' roles fixed by round 1 (the packet is fixed under
%                   HARQ-CC, so physically more consistent).
%                   'none'  unordered generic user (what eqs (9)/(11) assume).
%   'extra_gain_dB' [ASSUMED] calibration offset added to g. 0 = link budget as
%                   stated in the paper. 5.25 dB best fits the published Fig. 4
%                   (Fig. 4 is ~5-6 dB left of the paper's own Fig. 2/Fig. 3).
%   'lambda_hi'     [12] aggregate hardware-impairment level (EVM). 0 in Hu et al.
%   'isic'          [12] 0 = perfect SIC (Hu et al.), 1 = imperfect SIC
%   'Omega_I_dB'    [12] residual-interference power for imperfect SIC
%   'preset'        'fig4' -> order 'round', extra_gain_dB 5.25

opt = struct('order','round','extra_gain_dB',0,'lambda_hi',0,'isic',0, ...
             'Omega_I_dB',-20,'preset','');
for i = 1:2:numel(varargin), opt.(varargin{i}) = varargin{i+1}; end
if strcmpi(opt.preset,'fig4')
    opt.order = 'round';  opt.extra_gain_dB = 5.25;
end

%% ---------------- Shadowed-Rician channel (average shadowing) [paper]
p.b     = 0.126;    % 2b = average power of multipath (scatter) component
p.m     = 10.1;     % Nakagami-m severity of the LOS component
p.Omega = 0.835;    % average power of LOS component

%% ---------------- Link budget [paper]
p.kB    = 1.38e-23;           % Boltzmann constant
p.Bw    = 50e6;               % bandwidth (Hz)
p.Tnoise= 290;                % noise temperature (K)
p.N0    = p.kB*p.Bw*p.Tnoise; % noise power (W)

p.c     = 3e8;                % speed of light
p.fc    = 1.55e9;             % carrier frequency (Hz)
p.d     = 1000e3;             % satellite-user distance (m), same for all users
p.Gmax_dBi  = 25;             % max satellite beam gain
p.Gr_dBi    = 5;              % user receive antenna gain
p.theta3dB  = 0.4;            % 3 dB beamwidth (deg)
p.theta     = 0;              % [ASSUMED] user at beam centre (paper doesn't give it)

Gmax = 10^(p.Gmax_dBi/10);
Gr   = 10^(p.Gr_dBi/10);
w = 2.07123*sind(p.theta)/sind(p.theta3dB);
if abs(w) < 1e-9
    Gs = Gmax;                % limit w->0 : J1/(2w)->1/4, 36*J3/w^3->3/4
else
    Gs = Gmax*( besselj(1,w)/(2*w) + 36*besselj(3,w)/w^3 )^2;
end
p.Gs = Gs;

Gk  = p.c*sqrt(Gs*Gr)/(4*pi*p.fc*p.d);   % eq. (3) scaling factor
p.g_linkbudget = Gk^2/p.N0;              % g_k = Gk^2/N0 (eq. 5), ~1.186 (0.74 dB)
p.extra_gain_dB = opt.extra_gain_dB;
p.g = p.g_linkbudget * 10^(p.extra_gain_dB/10);   % SNR = Ps * g * |h|^2

%% ---------------- RSMA (Fig. 4 caption) [paper]
p.alpha_c   = 0.4;            % common-stream power fraction
p.alpha_p   = [0.3 0.3];      % private-stream fractions (K = 2 users)
p.gc_th     = 0.4;            % common decoding threshold  (SINR, linear)
p.gp_th     = 0.4;            % private decoding threshold (SINR, linear)
p.rsma_ordered = false;       % paper's RSMA analysis: generic i.i.d. user k

%% ---------------- Equal-rate conversion [paper]
p.Rc = log2(1 + p.gc_th);     % common target rate (bps/Hz)
p.Rp = log2(1 + p.gp_th);     % private target rate
p.R1 = p.Rc/2 + p.Rp;         % per-user rate: R1,th = R2,th = Rc/2 + Rp = 0.728

%% ---------------- NOMA [paper] + modelling of [12]
% [12] eq. (6)-(7): user k decoding x_l sees
%   gamma = delta_l*rho*Z / ( vartheta_{k,l}*rho*Z + isic*rho*|gI|^2 + 1 ),
%   vartheta_{k,l} = sum_{i>l} delta_i + lambda^2,   delta_1 >= delta_2 (weak user gets more)
% Hu et al. use perfect hardware and perfect SIC: lambda = 0, isic = 0.
p.a1_noma = (1 + p.alpha_c)/2;   % = 0.7, far/weak user   [paper]
p.a2_noma = 1 - p.a1_noma;       % = 0.3, near/strong user
p.g_noma  = 2^p.R1 - 1;          % SINR threshold for R1 = 0.657
p.lambda_hi  = opt.lambda_hi;    % [12] HI level (aggregate EVM)
p.isic       = opt.isic;         % [12] 0 = P-SIC, 1 = I-SIC
p.Omega_I    = 10^(opt.Omega_I_dB/10);  % [12] E|gI|^2

%% ---------------- OMA (TDMA) [12]
% [12], Fig. 6 discussion: OMA needs K time slots, so for the same target
% rate its equivalent SINR threshold is 2^(K*R) - 1. With K = 2:
p.g_oma = 2^(2*p.R1) - 1;        % = 1.744

%% ---------------- User ordering across HARQ rounds
p.order = opt.order;

%% ---------------- Simulation
p.seed  = 2025;
p.chunk = 1e6;                % samples per chunk (memory control)
end

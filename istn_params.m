function p = istn_params()
% ISTN_PARAMS  System parameters from Hu et al., "Outage Analysis of RSMA
% Enabled Integrated Satellite-Terrestrial Networks", IEEE TVT, Jun. 2025.
% Everything marked [paper] is taken directly from Sec. IV / Fig. 4 caption.
% Everything marked [ASSUMED] is not stated in the paper.

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

% Satellite beam gain, Gs = Gmax*( J1(w)/(2w) + 36*J3(w)/w^3 )^2
Gmax = 10^(p.Gmax_dBi/10);
Gr   = 10^(p.Gr_dBi/10);
w = 2.07123*sind(p.theta)/sind(p.theta3dB);
if abs(w) < 1e-9
    Gs = Gmax;                % limit w->0 : J1/(2w)->1/4, 36*J3/w^3->3/4
else
    Gs = Gmax*( besselj(1,w)/(2*w) + 36*besselj(3,w)/w^3 )^2;
end
p.Gs = Gs;

% Gk = c*sqrt(Gs*Gr)/(4*pi*fc*d),  g_k = Gk^2/N0   (eq. (5))
Gk  = p.c*sqrt(Gs*Gr)/(4*pi*p.fc*p.d);
p.g = Gk^2/p.N0;              % so that SNR = Ps * g * |h|^2  (~0.74 dB)

%% ---------------- RSMA (Fig. 4 caption) [paper]
p.alpha_c   = 0.4;            % common-stream power fraction
p.alpha_p   = [0.3 0.3];      % private-stream fractions (K = 2 users)
p.gc_th     = 0.4;            % common decoding threshold  (SINR, linear)
p.gp_th     = 0.4;            % private decoding threshold (SINR, linear)
p.rsma_ordered = false;       % paper's RSMA analysis treats user k as a generic
                              % i.i.d. user (no ordering). Set true to make RSMA's
                              % "weak user" the min-channel user, like NOMA/OMA.

%% ---------------- Equal-rate conversion [paper]
p.Rc = log2(1 + p.gc_th);     % common target rate (bps/Hz)
p.Rp = log2(1 + p.gp_th);     % private target rate
p.R1 = p.Rc/2 + p.Rp;         % per-user rate: R1,th = R2,th = Rc/2 + Rp

%% ---------------- NOMA [paper]
p.a1_noma = (1 + p.alpha_c)/2;   % = 0.7, far/weak user
p.a2_noma = 1 - p.a1_noma;       % = 0.3, near/strong user
p.g_noma  = 2^p.R1 - 1;          % SINR threshold for R1

%% ---------------- OMA (TDMA) [ASSUMED interpretation]
% Each user gets half the time, so to deliver R1 on average it must run at
% 2*R1 inside its own slot (full power, no interference).
p.g_oma = 2^(2*p.R1) - 1;

%% ---------------- Simulation
p.seed  = 2025;
p.chunk = 1e6;                % samples per chunk (memory control)
end

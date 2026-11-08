function d = paper_fig4_points()
% PAPER_FIG4_POINTS  Values read off Hu et al. Fig. 4 (400-dpi render of the PDF).
% Reading error is about 10-20 % per point. Used only to compare against.
d.T1.Ps   = [0 5 10];
d.T1.oma  = [0.30 0.072 0.020];
d.T1.noma = [0.26 0.058 0.0145];
d.T1.rsma = [0.28 0.064 0.017];
d.T3.Ps   = [-10 -5 0 5 10];
d.T3.oma  = [NaN 0.55 8e-3 9e-5 2.1e-6];
d.T3.noma = [NaN 0.085 1.8e-3 1.9e-5 4e-7];
d.T3.rsma = [0.40 1.6e-2 2.5e-4 3.5e-6 7e-8];
end

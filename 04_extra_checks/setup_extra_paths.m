function setup_extra_paths()
% SETUP_EXTRA_PATHS  Put folders 01, 02 and this one on the MATLAB path.
here = fileparts(mfilename('fullpath'));
addpath(fullfile(here, '..', '01_fig4_monte_carlo'));
addpath(fullfile(here, '..', '02_sinr_closed_form_outage'));
addpath(here);
end

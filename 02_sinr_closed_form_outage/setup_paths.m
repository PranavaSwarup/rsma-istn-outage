function setup_paths()
% SETUP_PATHS  Put the shared week-1 files (istn_params, sr_gain, and the
% Monte Carlo functions oma/noma/rsma_outage) on the MATLAB path.
here = fileparts(mfilename('fullpath'));
addpath(fullfile(here, '..', '01_fig4_monte_carlo'));
addpath(here);
end

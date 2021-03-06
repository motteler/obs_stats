%
% cris_obs_batch - batch wrapper for cris_obs_list
%

function cris_obs_batch(year)

addpath ../source
addpath /asl/packages/ccast/source
addpath /asl/packages/ccast/motmsc/time
addpath /asl/packages/airs_decon/source

% get parameters from slurm env
procid = str2num(getenv('SLURM_PROCID'));
nprocs = str2num(getenv('SLURM_NPROCS'));
nodeid = sscanf(getenv('SLURMD_NODENAME'), '%s');
taskid = str2num(getenv('SLURM_ARRAY_TASK_ID'));

fprintf(1, 'cris_batch: year %d set %d node %s\n', year, taskid, nodeid);

% taskid is the 16-day set number
if ~(1 <= taskid & taskid <= 23)
  error('set index out of range')
end

% take 16-day set number to doy list
if ~isleap(year), yend = 365; else, yend = 366; end
dlist = (taskid - 1) * 16 + 1 : taskid * 16;
if dlist(end) > yend
  dlist = dlist(1) : yend;
end

% set the output filename 
% tfile = sprintf('J01_c07y%ds%0.2d', year, taskid);
  tfile = sprintf('NPP_c07y%ds%0.2d', year, taskid);

% cris_obs_list options
opt1 = struct;
% opt1.cdir = '/asl/cris/ccast/sdr45_j01_HR';  
  opt1.cdir = '/asl/cris/ccast/sdr45_npp_HR';

% scan selection
% opt1.iFOR = 15 : 16;       % 1 near nadir
  opt1.iFOR =  1 : 30;       % 2 full scan
% opt1.iFOR = [8 15 16 23];  % 3 near nadir plus half scan
% opt1.iFOR = [8 23];        % 4 half scan only
% opt1.iFOR = 13 : 18;       % 5 expanded nadir

% use Hamming apodization
opt1.hapod = 1;

% set "c04", low-end LW
% opt1.vlist = [651.875 654.375 659.375 663.750 666.250 668.125];

% set "c05", low strat, CO2, and window
% opt1.vlist = [699.375, 746.875, 901.875, 902.500];

% set "c06", LW hamming test
% opt1.vlist = [651.875 654.375 659.375 663.750 666.250 668.125 902.500];

% set "c07", AIRS channels for CF calc
opt1.band = 'MW';
opt1.vlist = [1227.71, 1231.33];

cris_obs_list(year, dlist, tfile, opt1)


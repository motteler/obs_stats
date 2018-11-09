%
% n20_obs_batch - batch wrapper for cris_obs_list
%

function n20_obs_batch(year)

addpath ../source
addpath /asl/packages/ccast/source
addpath /asl/packages/ccast/motmsc/time

more off

procid = str2num(getenv('SLURM_PROCID'));
nprocs = str2num(getenv('SLURM_NPROCS'));
nodeid = sscanf(getenv('SLURMD_NODENAME'), 'n%d');
taskid = str2num(getenv('SLURM_ARRAY_TASK_ID'));

fprintf(1, 'n20_batch: year %d set %d node %d\n', year, taskid, nodeid);

if ~(1 <= taskid & taskid <= 23)
  error('set index out of range')
end

if ~isleap(year), yend = 365; else, yend = 366; end

dlist = (taskid - 1) * 16 + 1 : taskid * 16;

if dlist(end) > yend
  dlist = dlist(1) : yend;
end

% set the output filename 
tfile = sprintf('N20_902y%ds%0.2d', year, taskid);

opt1 = struct;

  opt1.cdir = '/asl/data/cris/ccast/sdr45_j01_HR';

% opt1.iFOR = 15 : 16;       % 1 near nadir
  opt1.iFOR =  1 : 30;       % 2 full scan
% opt1.iFOR = [8 15 16 23];  % 3 near nadir plus half scan
% opt1.iFOR = [8 23];        % 4 half scan only
% opt1.iFOR = 13 : 18;       % 5 expanded nadir

% opt1.v1 = 2450; opt1.v2 = 2550;  % SW Tb frequency span
  opt1.v1 = 899;  opt1.v2 = 904;   % LW Tb frequency span
  opt1.T1 = 160;  opt1.T2 = 360;   % Tb selection span

cris_obs_list(year, dlist, tfile, opt1)


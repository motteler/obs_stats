%
% airs_obs_batch - batch wrapper for airs_obs_list
%
% edit both channel list and output filename to change channel sets
%

function airs_obs_batch(year)

addpath ../source
addpath /asl/packages/ccast/source
addpath /asl/packages/ccast/motmsc/time

procid = str2num(getenv('SLURM_PROCID'));
nprocs = str2num(getenv('SLURM_NPROCS'));
nodeid = sscanf(getenv('SLURMD_NODENAME'), '%s');
taskid = str2num(getenv('SLURM_ARRAY_TASK_ID'));

fprintf(1, 'airs_obs_batch: year %d set %d node %s\n', year, taskid, nodeid);

if ~(1 <= taskid & taskid <= 23)
  error('set index out of range')
end

if ~isleap(year), yend = 365; else, yend = 366; end

dlist = (taskid - 1) * 16 + 1 : taskid * 16;

if dlist(end) > yend
  dlist = dlist(1) : yend;
end

% set the output filename 
tfile = sprintf('airs_c03y%ds%0.2d', year, taskid);

% airs_obs_list options
opt1 = struct;
opt1.adir = '/asl/hpcnfs1/airs/L1C';  % AIRS data

% scan selection
% opt1.ixt = 43 : 48;              % 1 near nadir
  opt1.ixt =  1 : 90;              % 2 full scan
% opt1.ixt = [21:23 43:48 68:70];  % 3 near nadir plus half scan
% opt1.ixt = [21:23 68:70];        % 4 half scan only
% opt1.ixt = 37 : 54;              % 5 expanded nadir

% channel set c3
  opt1.vlist = [699.380 746.967 902.040 1231.330 1613.862 2384.252 2500.601];

% channel set c4
% opt1.vlist = [830.47 843.91 899.62 921.64 968.23 992.45 1227.71 1231.33];

% channel set c5
% opt1.vlist = [830.47 1227.71 1231.33 2456.48 2607.89 2616.38 2653.13];

airs_obs_list(year, dlist, tfile, opt1)


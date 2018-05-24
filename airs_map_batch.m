%
% airs_map_batch - batch wrapper for airs_map_list
%

% function airs_map_batch(year)

addpath /asl/packages/ccast/source
addpath /asl/packages/ccast/motmsc/time

more off

% procid = str2num(getenv('SLURM_PROCID'));
% nprocs = str2num(getenv('SLURM_NPROCS'));
% nodeid = sscanf(getenv('SLURMD_NODENAME'), 'n%d');
% taskid = str2num(getenv('SLURM_ARRAY_TASK_ID'));

% *** TEMP for tests ***
year = 2016;
nodeid = 0;
taskid = 8;

fprintf(1, 'airs_batch: year %d set %d node %d\n', year, taskid, nodeid);

if ~(1 <= taskid & taskid <= 23)
  error('set index out of range')
end

if ~isleap(year), yend = 365; else, yend = 366; end

dlist = (taskid - 1) * 16 + 1 : taskid * 16;

if dlist(end) > yend
  dlist = dlist(1) : yend;
end

% set the output filename 
  tfile = sprintf('airs902y%dq%d', year, taskid);
% tfile = sprintf('airs2500y%dq%d', year, taskid);

opt1 = struct;

% opt1.adir = '/asl/data/airs/L1C';

% opt1.ixt = 43 : 48;              % 1 near nadir
  opt1.ixt =  1 : 90;              % 2 full scan
% opt1.ixt = [21:23 43:48 68:70];  % 3 near nadir plus half scan
% opt1.ixt = [21:23 68:70];        % 4 half scan only
% opt1.ixt = 37 : 54;              % 5 expanded nadir

% opt1.v1 = 2450; opt1.v2 = 2550;  % SW Tb frequency span
  opt1.v1 = 899;  opt1.v2 = 904;   % LW Tb frequency span
  opt1.T1 = 160;  opt1.T2 = 360;   % Tb selection span

airs_map_list(year, dlist, tfile, opt1)

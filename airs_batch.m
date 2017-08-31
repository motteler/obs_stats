%
% airs_batch - batch wrapper for airs_tbin parameters
%

function airs_batch(year)

addpath /asl/packages/ccast/source
addpath /asl/packages/ccast/motmsc/time

more off

procid = str2num(getenv('SLURM_PROCID'));
nprocs = str2num(getenv('SLURM_NPROCS'));
nodeid = sscanf(getenv('SLURMD_NODENAME'), 'n%d');
taskid = str2num(getenv('SLURM_ARRAY_TASK_ID'));

fprintf(1, 'airs_batch: year %d quintile %d node %d\n', year, taskid, nodeid);

if ~(1 <= taskid & taskid <= 5)
  error('quintile index out of range')
end

if ~isleap(year), yend = 365; else, yend = 366; end

switch(taskid)
  case 1, dlist =   1 :  73;   % quintile 1
  case 2, dlist =  74 : 146;   % quintile 2
  case 3, dlist = 147 : 219;   % quintile 3
  case 4, dlist = 220 : 292;   % quintile 4
  case 5, dlist = 293 : yend;  % quintile 5
end

% tfile = sprintf('airs902y%dq%d', year, taskid);
  tfile = sprintf('airs2500y%dq%d', year, taskid);

opt1 = struct;

% opt1.adir = '/asl/data/airs/L1C';

% opt1.ixt = 43 : 48;              % 1 near nadir
  opt1.ixt =  1 : 90;              % 2 full scan
% opt1.ixt = [21:23 43:48 68:70];  % 3 near nadir plus half scan
% opt1.ixt = [21:23 68:70];        % 4 half scan only
% opt1.ixt = 37 : 54;              % 5 expanded nadir

  opt1.v1 = 2450; opt1.v2 = 2550;  % broad SW window
% opt1.v1 = 899;  opt1.v2 = 904;   % Tb frequency span
% opt1.T1 = 180;  opt1.T2 = 340;   % Tb bin span
  opt1.dT = 0.5;                   % Tb bin step size
  opt1.nedn = 0.2;                 % noise for smoothing

airs_tbin(year, dlist, tfile, opt1)


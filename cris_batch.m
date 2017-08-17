%
% cris_batch - batch wrapper for cris_tbin parameters
%

function cris_batch(year)

addpath /asl/packages/ccast/source
addpath /asl/packages/ccast/motmsc/time

more off

procid = str2num(getenv('SLURM_PROCID'));
nprocs = str2num(getenv('SLURM_NPROCS'));
nodeid = sscanf(getenv('SLURMD_NODENAME'), 'n%d');
taskid = str2num(getenv('SLURM_ARRAY_TASK_ID'));

fprintf(1, 'cris_batch: year %d quintile %d node %d\n', year, taskid, nodeid);

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

tfile = sprintf('cris902y%dq%d', year, taskid);

opt1 = struct;

% opt1.cdir = '/asl/data/cris/ccast/sdr60_hr';

% opt1.iFOR = 15 : 16;       % 1 near nadir
  opt1.iFOR =  1 : 30;       % 2 full scan
% opt1.iFOR = [8 15 16 23];  % 3 near nadir plus half scan
% opt1.iFOR = [8 23];        % 4 half scan only
% opt1.iFOR = 13 : 18;       % 5 expanded nadir

% opt1.v1 = 2450; opt1.v2 = 2550;  % broad SW window
% opt1.v1 = 899;  opt1.v2 = 904;   % Tb frequency span
% opt1.T1 = 180;  opt1.T2 = 340;   % Tb bin span
  opt1.dT = 0.5;                   % Tb bin step size

cris_tbin(year, dlist, tfile, opt1)


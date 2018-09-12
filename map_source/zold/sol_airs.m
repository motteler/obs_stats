%
% quick AIRS solar zenith stats
%

addpath ./source
addpath /asl/packages/ccast/source
addpath /asl/packages/ccast/motmsc/time

year = 2018;
dlist = 61 : 76;
tfile = 'sol_airs_x1';
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


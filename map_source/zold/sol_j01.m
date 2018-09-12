%
% quick j1 solar zenith stats
%

addpath ./source
addpath /asl/packages/ccast/source
addpath /asl/packages/ccast/motmsc/time

year = 2018;
dlist = 61 : 76;
tfile = 'sol_j01_x1';

opt1 = struct;

  opt1.cdir = '/asl/data/cris_xfs3/ccast/sdr45_j01_HR';

% opt1.iFOR = 15 : 16;       % 1 near nadir
  opt1.iFOR =  1 : 30;       % 2 full scan
% opt1.iFOR = [8 15 16 23];  % 3 near nadir plus half scan
% opt1.iFOR = [8 23];        % 4 half scan only
% opt1.iFOR = 13 : 18;       % 5 expanded nadir

% opt1.v1 = 2450; opt1.v2 = 2550;  % SW Tb frequency span
  opt1.v1 = 899;  opt1.v2 = 904;   % LW Tb frequency span
  opt1.T1 = 160;  opt1.T2 = 360;   % Tb selection span

cris_map_list(year, dlist, tfile, opt1)


%
% quick NPP solar zenith stats
%

addpath ./source
addpath /asl/packages/ccast/source
addpath /asl/packages/ccast/motmsc/time

year = 2018;
dlist = 61 : 76;
tfile = 'testY_j1_1653';

opt1 = struct;

% SDR data
opt1.cdir = '/asl/data/cris_xfs3/ccast/sdr45_j01_HR';

% full scan
opt1.iFOR =  1 : 30;  

% Tb selection span
opt1.T1 = 60; opt1.T2 = 360;  

% MW Tb frequency span
% opt1.v1 = 1231.25;   opt1.v2 = 1231.25;
  opt1.v1 = 1653.125;  opt1.v2 = 1653.125;  

cris_map_listY(year, dlist, tfile, opt1)


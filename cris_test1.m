%
% driver file for basic cris_tbin tests
%

opt1 = struct;

% dlist =   1 :  73;   % qt1
% dlist =  74 : 146;   % qt2
% dlist = 147 : 219;   % qt3
% dlist = 220 : 292;   % qt4
% dlist = 293 : 365;   % qt5

% year = 2015;
% dlist = 1 :  91;      % W = winter
% tfile = 'a902t2015W';

% dlist =  92 : 182;    % X = spring
% dlist = 183 : 273;    % Y = summer
% dlist = 274 : 365;    % Z = fall

  year = 2016;
  dlist = 111 : 126;  % 2016 no missing granules
  tfile = 'c902t2016d16';

% opt1.cdir = '/asl/data/cris/ccast/sdr60_hr';

% opt1.iFOR = 15 : 16;       % 1 near nadir
  opt1.iFOR =  1 : 30;       % 2 full scan
% opt1.iFOR = [8 15 16 23];  % 3 near nadir plus half scan
% opt1.iFOR = [8 23];        % 4 half scan only
% opt1.iFOR = 13 : 18;       % 5 expanded nadir

% opt1.v1 = 2450;  opt1.v2 = 2550; % broad SW window
% opt1.v1 = 899;  opt1.v2 = 904;   % Tb frequency span
% opt1.T1 = 180;  opt1.T2 = 340;   % Tb bin span
  opt1.dT = 0.5;                   % Tb bin step size

cris_tbin(year, dlist, tfile, opt1)


%
% NAME
%   cris_tbin - tabulate CrIS obs x Tb bins
%
% SYNOPSIS
%   cris_tbin(year, dlist, tfile, opt1)
%
% INPUTS
%   year   - year, as an integer
%   dlist  - list of days-of-the-year
%   tfile  - save file for tabulation
%
% DISCUSSION
%
% AUTHOR
%  H. Motteler, 3 July 2017
%

function cris_tbin(year, dlist, tfile, opt1)

% default params 
cdir = '/asl/data/cris/ccast/sdr60_hr';  % path to CrIS data
iFOR =  1 : 30;       % full scans
v1 = 899; v2 = 904;   % Tb frequency span
T1 = 180; T2 = 340;   % Tb bin span
dT = 0.25;            % Tb bin step size

% process input options
if nargin == 4
  if isfield(opt1, 'cdir'), cdir = opt1.cdir; end
  if isfield(opt1, 'iFOR'), iFOR = opt1.iFOR; end
  if isfield(opt1, 'v1'),   v1   = opt1.v1; end
  if isfield(opt1, 'v2'),   v2   = opt1.v2; end
  if isfield(opt1, 'T1'),   T1   = opt1.T1; end
  if isfield(opt1, 'T2'),   T2   = opt1.T2; end
  if isfield(opt1, 'dT'),   dT   = opt1.dT; end
else
  opt1 = struct;
end

% path to CrIS data, including year
ayear = fullfile(cdir, sprintf('%d', year));

% initialize Tb bins
tind = T1 : dT : T2;
tmid = tind + dT/2;
nbin = length(tind);
nday = length(dlist);
tbin = zeros(nbin, nday);

% loop on days of the year
for di = dlist
  
  % loop on CrIS granules
  doy = sprintf('%03d', di);
  fprintf(1, 'doy %s ', doy)
  flist = dir(fullfile(ayear, doy, 'SDR*.mat'));

  for fi = 1 : length(flist);

    afile = fullfile(ayear, doy, flist(fi).name);

%   % load everyting for local L1b_err calc
%   d1 = load(afile);

%   % just load LW radiances
    d1 = load(afile, 'vLW', 'rLW', 'L1b_err', 'geo');
    ixv = find(v1 <= d1.vLW & d1.vLW <=v2);
    rad = d1.rLW(ixv,:,iFOR,:);
    cfrq = d1.vLW(ixv);

%   % just load SW radiances
%   d1 = load(afile, 'vSW', 'rSW', 'L1b_err');
%   ixv = find(v1 <= d1.vSW & d1.vSW <=v2);
%   rad = d1.rSW(ixv,:,iFOR,:);
%   cfrq = d1.vSW(ixv);

%  % new L1b_err local calc
%   L1b_err = ...
%      checkSDR(d1.vLW, d1.vMW, d1.vSW, d1.rLW, d1.rMW, d1.rSW, ...
%               d1.cLW, d1.cMW, d1.cSW, d1.L1a_err, d1.rid);
%   iOK = ~L1b_err(:,iFOR,:);
%   rad = rad(:,iOK);
 
    % new L1b_err from file
    iOK = ~d1.L1b_err(:,iFOR,:);
    rad = rad(:,iOK);

    % read lat and lon
    lat = d1.geo.Latitude(:,iFOR,:);
    lon = d1.geo.Longitude(:,iFOR,:);
    lat = lat(iOK);
    lon = lon(iOK);

    % latitude subsample
    lat_rad = deg2rad(lat);
    [m,n] = size(lat_rad);
    jx = rand(m, n) < abs(cos(lat_rad));
    lat = lat(jx);
    lon = lon(jx);
    rad = rad(:,jx);

    % ocean or land subset
    [~, landfrac] = usgs_deg10_dem(lat', lon');
%   ocean = landfrac(:) == 0;
%   rad = rad(:, ocean);
%   land = landfrac(:) == 1;
%   rad = rad(:, land);
    if isempty(rad), continue, end

    % brightness temp bins
    Tb = real(rad2bt(cfrq, rad));
    rmsTb = squeeze(rms(Tb));
    rmsTb = rmsTb(:);

    ix = floor((rmsTb - T1) / dT) + 1;
    ix(ix < 1) = 1;
    ix(nbin < ix) = nbin;

    for i = 1 : length(ix)
      tbin(ix(i)) = tbin(ix(i)) + 1;
    end

    if mod(fi, 10) == 0, fprintf(1, '.'), end
  end
  fprintf(1, '\n')
end

save cris_tbin ayear dlist iFOR v1 v2 cfrq tind tbin

save(tfile, 'year', 'dlist', 'cdir', 'iFOR', 'v1', 'v2', ...
            'dT', 'T1', 'T2', 'cfrq', 'tind', 'tmid', 'tbin')






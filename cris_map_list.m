%
% NAME
%   cris_map_list - list selected CrIS obs
%
% SYNOPSIS
%   cris_map_list(year, dlist, ofile, opt1)
%
% INPUTS
%   year   - year, as an integer
%   dlist  - list of days-of-the-year
%   ofile  - save file for obs lists
%
% DISCUSSION
%   this is just cris_obs_list.m with different options
%
% AUTHOR
%  H. Motteler, 3 July 2017
%

function cris_map_list(year, dlist, ofile, opt1)

% default params 
cdir = '/asl/data/cris/ccast/sdr60_npp_HR';   % path to CrIS data
iFOR =  1 : 30;       % full scans
v1 = 899; v2 = 904;   % Tb frequency span
T1 = 160; T2 = 360;   % save obs if T1 <= Tb <= T2

% process input options
if nargin == 4
  if isfield(opt1, 'cdir'), cdir = opt1.cdir; end
  if isfield(opt1, 'iFOR'), iFOR = opt1.iFOR; end
  if isfield(opt1, 'v1'),   v1   = opt1.v1; end
  if isfield(opt1, 'v2'),   v2   = opt1.v2; end
  if isfield(opt1, 'T1'),   T1   = opt1.T1; end
  if isfield(opt1, 'T2'),   T2   = opt1.T2; end
else
  opt1 = struct;
end

% path to CrIS data, including year
ayear = fullfile(cdir, sprintf('%d', year));

% initialize obs lists
Tb_list = [];
lat_list = [];
lon_list = [];
tai_list = [];
zen_list = [];
sol_list = [];

% loop on days of the year
for di = dlist
  
  % loop on CrIS granules
  doy = sprintf('%03d', di);
  fprintf(1, 'doy %s ', doy)
  flist = dir(fullfile(ayear, doy, 'SDR*.mat'));

  for fi = 1 : length(flist);

    if mod(fi, 10) == 0, fprintf(1, '.'), end

    afile = fullfile(ayear, doy, flist(fi).name);

    % load LW radiances
    d1 = load(afile, 'vLW', 'rLW', 'L1b_stat', 'L1a_err', 'geo');
%   d1 = load(afile, 'vLW', 'rLW', 'cLW', 'L1b_stat', 'L1a_err', 'geo');
    ixv = find(v1 <= d1.vLW & d1.vLW <=v2);
    rad = d1.rLW(ixv,:,iFOR,:);
    cfrq = d1.vLW(ixv);

    % load SW radiances
%   d1 = load(afile, 'vSW', 'rSW', 'L1b_stat', 'L1a_err', 'geo');
%   d1 = load(afile, 'vSW', 'rSW', 'cSW', 'L1b_stat', 'L1a_err', 'geo');
%   ixv = find(v1 <= d1.vSW & d1.vSW <=v2);
%   rad = d1.rSW(ixv,:,iFOR,:);
%   cfrq = d1.vSW(ixv);

    % use the SDR file L1b_err
%   iOK = ~d1.L1b_err(:,iFOR,:);

    % do our own error checking
    [eLW, eMW, eSW] = fixmyQC(d1.L1a_err, d1.L1b_stat);
    iOK = ~eLW(:, iFOR, :);
%   iOK = ~eSW(:, iFOR, :);

    % ccast QC with added UW imag resid check
%   eUW = uw_qc_LW(d1.L1a_err, d1.L1b_stat, d1.vLW, d1.cLW);
%   eUW = uw_qc_SW(d1.L1a_err, d1.L1b_stat, d1.vSW, d1.cSW);
%   iOK = ~eUW(:, iFOR, :);

    % radiance valid subset
    rad = rad(:,iOK);

    % read geo data
    lat = d1.geo.Latitude(:,iFOR,:);
    lon = d1.geo.Longitude(:,iFOR,:);
    tai = iet2tai(d1.geo.FORTime(iFOR, :));
%   zen = d1.geo.SatelliteZenithAngle(:, iFOR, :);
%   sol = d1.geo.SolarZenithAngle(:, iFOR, :);

    % extend tai from 30 x 60 to 9 x 30 x 60
    [m,n] = size(tai);    
    tai = reshape(ones(9,1)*tai(:)', 9, m, n);

    % FOV subsetting goes here

    % geo valid subset
    lat = lat(iOK);
    lon = lon(iOK);
    tai = tai(iOK);
%   zen = zen(iOK);
%   sol = sol(iOK);

    % latitude subsample
    lat_rad = deg2rad(lat);
    [m,n] = size(lat_rad);
    jx = rand(m, n) < abs(cos(lat_rad));
    rad = rad(:,jx);
    lat = lat(jx);
    lon = lon(jx);
    tai = tai(jx);
%   zen = zen(jx);
%   sol = sol(jx);

%   % land or ocean subsets
%   [~, landfrac] = usgs_deg10_dem(lat', lon');
%   ocean = landfrac(:) == 0;
%   rad = rad(:, ocean);
%   land = landfrac(:) == 1;
%   rad = rad(:, land);
%   if isempty(rad), continue, end

    % get window span rms Tb
    Tb = real(rad2bt(cfrq, rad));
    rmsTb = rms(Tb);
    rmsTb = rmsTb(:);

    % check for a hot subset
    ihot = find(T1 <= rmsTb & rmsTb <= T2);
    if isempty(ihot), continue, end

    % add hot obs to lists
    Tb_list = [Tb_list; single(rmsTb(ihot))];
    lat_list = [lat_list; single(lat(ihot))];
    lon_list = [lon_list; single(lon(ihot))];
    tai_list = [tai_list; single(tai(ihot))];
%   zen_list = [zen_list; zen(ihot)];
%   sol_list = [sol_list; sol(ihot)];

  end % loop on granules
  fprintf(1, '\n')
end % loop on days

save(ofile, 'year', 'dlist', 'cdir', 'iFOR', 'v1', 'v2', ...
            'T1', 'T2', 'cfrq', 'Tb_list', 'lat_list', ...
             'lon_list', 'tai_list', 'zen_list', 'sol_list');


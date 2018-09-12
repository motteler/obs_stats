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
%   mostly just cris_obs_list.m with different options
%   see cris_geo_list.m if we need to add FOV subsetting
%
% AUTHOR
%  H. Motteler, 3 July 2017
%

function cris_map_list(year, dlist, ofile, opt1)

% default params 
cdir = '/asl/data/cris/ccast/sdr60_npp_HR';   % path to CrIS data
iFOR =  1 : 30;       % full scans
iFOV =  1 : 9;        % all FOVs
v1 = 899; v2 = 904;   % Tb frequency span
T1 = 160; T2 = 360;   % save obs if T1 <= Tb <= T2
nLat = 24; dLon = 4;  % equal area bin spec

% process input options
if nargin == 4
  if isfield(opt1, 'cdir'), cdir = opt1.cdir; end
  if isfield(opt1, 'iFOR'), iFOR = opt1.iFOR; end
  if isfield(opt1, 'v1'),   v1   = opt1.v1; end
  if isfield(opt1, 'v2'),   v2   = opt1.v2; end
  if isfield(opt1, 'T1'),   T1   = opt1.T1; end
  if isfield(opt1, 'T2'),   T2   = opt1.T2; end
  if isfield(opt1, 'nLat'), nLat = opt1.nLat; end
  if isfield(opt1, 'dLon'), dLon = opt1.dLon; end
else
  opt1 = struct;
end

% FOV and FOR count
nFOR = length(iFOR);
nFOV = length(iFOV);

% path to CrIS data, including year
cyear = fullfile(cdir, sprintf('%d', year));

% initialize obs lists
Tb_list = [];
lat_list = [];
lon_list = [];
tai_list = [];
zen_list = [];
sol_list = [];
asc_list = logical([]);
fov_list = [];

% loop on days of the year
for di = dlist
  
  % loop on CrIS granules
  doy = sprintf('%03d', di);
  fprintf(1, 'doy %s ', doy)
  flist = dir(fullfile(cyear, doy, '*SDR*.mat'));

  for fi = 1 : length(flist);

    if mod(fi, 10) == 0, fprintf(1, '.'), end

    cfile = fullfile(cyear, doy, flist(fi).name);

    % load MW radiances
    d1 = load(cfile, 'vMW', 'rMW', 'L1b_stat', 'L1a_err', 'geo');
    ixv = find(v1 <= d1.vMW & d1.vMW <=v2);
    rad = d1.rMW(ixv,:,iFOR,:);
    cfrq = d1.vMW(ixv);

    % do our own error checking
    [eLW, eMW, eSW] = fixmyQC(d1.L1a_err, d1.L1b_stat);
    iOK = ~eMW(:, iFOR, :);

    % radiance valid subset
    rad = rad(:,iOK);

    % read geo data
    lat = d1.geo.Latitude(:,iFOR,:);
    lon = d1.geo.Longitude(:,iFOR,:);
    tai = iet2tai(d1.geo.FORTime(iFOR, :));
    zen = d1.geo.SatelliteZenithAngle(:, iFOR, :);
    sol = d1.geo.SolarZenithAngle(:, iFOR, :);
    asc = d1.geo.Asc_Desc_Flag;

    % extend tai from m x n to 9 x m x n
    [m,n] = size(tai);    
    tai = reshape(ones(nFOV,1)*tai(:)', 9, m, n);

    % extend asc from n to 9 x m x n
    asc = reshape(ones(nFOV*nFOR,1)*asc(:)', 9, m, n);

    % add a fov index
    fov = reshape((1:9)' * ones(1,m*n), 9, m, n);

    % geo valid subset
    lat = lat(iOK);
    lon = lon(iOK);
    tai = tai(iOK);
    zen = zen(iOK);
    sol = sol(iOK);
    asc = asc(iOK);
    fov = fov(iOK);

    % geo QC (we shouldn't need this, but...)
    gOK = -90 <= lat & lat <=  90 & ...
         -180 <= lon & lon <= 180 & ...
         ~isnan(asc);
    rad = rad(:,gOK);
    lat = lat(gOK);
    lon = lon(gOK);
    tai = tai(gOK);
    zen = zen(gOK);
    sol = sol(gOK);
    asc = logical(asc(gOK));
    fov = single(fov(gOK));

    % latitude subsample
    lat_rad = deg2rad(lat);
    [m,n] = size(lat_rad);
    jx = rand(m, n) < abs(cos(lat_rad));
    rad = rad(:,jx);
    lat = lat(jx);
    lon = lon(jx);
    tai = tai(jx);
    zen = zen(jx);
    sol = sol(jx);
    asc = asc(jx);
    fov = fov(jx);

%   % land or ocean subsets
%   [~, landfrac] = usgs_deg10_dem(lat', lon');
%   ocean = landfrac(:) == 0;
%   rad = rad(:, ocean);
%   land = landfrac(:) == 1;
%   rad = rad(:, land);
%   if isempty(rad), continue, end

    % get window span rms Tb
    Tb = real(rad2bt(cfrq, rad));
    rmsTb = rms(Tb, 1);
    rmsTb = rmsTb(:);

    % check for a hot subset
    ihot = find(T1 <= rmsTb & rmsTb <= T2);
    if isempty(ihot), continue, end

    % add hot obs to lists
    Tb_list = [Tb_list; rmsTb(ihot)];
    lat_list = [lat_list; lat(ihot)];
    lon_list = [lon_list; lon(ihot)];
    tai_list = [tai_list; tai(ihot)];
    zen_list = [zen_list; zen(ihot)];
    sol_list = [sol_list; sol(ihot)];
    asc_list = [asc_list; asc(ihot)];
    fov_list = [fov_list; fov(ihot)];

  end % loop on granules
  fprintf(1, '\n')
end % loop on days

save(ofile, 'year', 'dlist', 'cdir', 'iFOR', 'v1', 'v2', 'T1', 'T2', ...
            'cfrq', 'Tb_list', 'lat_list', 'lon_list', 'fov_list', ...
            'tai_list', 'zen_list', 'sol_list', 'asc_list');
%
% clear rad
% 
% [latB1, lonB1, gtot1, gavg1] = ...
%     equal_area_bins(nLat, dLon, lat_list, lon_list, Tb_list);
% 
% save(ofile, 'year', 'dlist', 'cdir', 'iFOR', 'v1', 'v2', ...
%             'T1', 'T2', 'cfrq', 'nLat', 'dLon', 'latB1', 'lonB1', ...
%             'gtot1', 'gavg1')
% 

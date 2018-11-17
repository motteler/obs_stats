%
% NAME
%   cris_obs_list - list selected CrIS obs
%
% SYNOPSIS
%   cris_obs_list(year, dlist, ofile, opt1)
%
% INPUTS
%   year   - year, as an integer
%   dlist  - list of days-of-the-year
%   ofile  - save file for obs lists
%
% DISCUSSION
%   uses channel list rather than window span
%
% AUTHOR
%  H. Motteler, 3 July 2017
%

function cris_obs_list(year, dlist, ofile, opt1)

% default params 
cdir = '/asl/data/cris/ccast/sdr45_npp_HR';
iFOV =  1 : 9;    % all FOVS
iFOR =  1 : 30;   % full scans
band = 'LW';      % LW band        

% default frequency list
vlist = [902.040, 902.387];

% process input options
if nargin == 4
  if isfield(opt1, 'cdir'), cdir = opt1.cdir; end
  if isfield(opt1, 'iFOR'), iFOR = opt1.iFOR; end
  if isfield(opt1, 'iFOV'), iFOV = opt1.iFOV; end
  if isfield(opt1, 'band'), band = opt1.band; end
  if isfield(opt1, 'vlist'), vlist = opt1.vlist; end
else
  opt1 = struct;
end

% FOV and FOR count
nFOR = length(iFOR);
nFOV = length(iFOV);

% path to CrIS data, including year
cyear = fullfile(cdir, sprintf('%d', year));

% initialize obs lists
rad_list = [];
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

    % load selected SDR fields
    switch (band)
      case 'LW'
        d1 = load(cfile, 'vLW', 'rLW', 'L1b_err', 'geo');
        ixv = interp1(d1.vLW, 1:length(d1.vLW), vlist, 'nearest');
        rad = d1.rLW(ixv,iFOV,iFOR,:);
        vlist = d1.vLW(ixv);
      case 'MW'
        d1 = load(cfile, 'vMW', 'rMW', 'L1b_err', 'geo');
        ixv = interp1(d1.vMW, 1:length(d1.vMW), vlist, 'nearest');
        rad = d1.rMW(ixv,iFOV,iFOR,:);
        vlist = d1.vMW(ixv);
      case 'SW'
        d1 = load(cfile, 'vSW', 'rSW', 'L1b_err', 'geo');
        ixv = interp1(d1.vSW, 1:length(d1.vSW), vlist, 'nearest');
        rad = d1.rSW(ixv,iFOV,iFOR,:);
        vlist = d1.vSW(ixv);
      end

    % read geo data
    lat = d1.geo.Latitude(iFOV,iFOR,:);
    lon = d1.geo.Longitude(iFOV,iFOR,:);
    tai = iet2tai(d1.geo.FORTime(iFOR,:));
    zen = d1.geo.SatelliteZenithAngle(iFOV,iFOR,:);
    sol = d1.geo.SolarZenithAngle(iFOV,iFOR,:);
    asc = d1.geo.Asc_Desc_Flag;

    % extend tai from m x n to 9 x m x n
    [m,n] = size(tai);    
    tai = reshape(ones(nFOV,1)*tai(:)', 9, m, n);

    % extend asc from n to 9 x m x n
    asc = reshape(ones(nFOV*nFOR,1)*asc(:)', 9, m, n);

    % add a fov index
    fov = reshape((1:9)' * ones(1,m*n), 9, m, n);

    % use the SDR file L1b_err
    iOK = ~d1.L1b_err(iFOV,iFOR,:);

%   % do our own error checking
%   [eLW, eMW, eSW] = fixmyQC(d1.L1a_err, d1.L1b_stat);
%   switch (band)
%     case 'LW', iOK = ~eLW(iFOV, iFOR, :);
%     case 'MW', iOK = ~eMW(iFOV, iFOR, :);
%     case 'SW', iOK = ~eSW(iFOV, iFOR, :);
%   end

    % valid radiance subset
    rad = rad(:,iOK);

    % valid geo subset
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

    % latitude weighted subset
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

   % add obs to lists
    rad_list = [rad_list, rad];
    lat_list = [lat_list; lat];
    lon_list = [lon_list; lon];
    tai_list = [tai_list; tai];
    zen_list = [zen_list; zen];
    sol_list = [sol_list; sol];
    asc_list = [asc_list; asc];
    fov_list = [fov_list; fov];

  end % loop on granules
  fprintf(1, '\n')
end % loop on days

% save the obs list
save(ofile, 'year', 'dlist', 'cdir', 'iFOV', 'iFOR', 'vlist', ...
            'rad_list', 'lat_list', 'lon_list', 'tai_list', ...
            'zen_list', 'sol_list', 'asc_list', 'fov_list');


%
% NAME
%   airs_map_list - list selected AIRS obs
%
% SYNOPSIS
%   airs_map_list(year, dlist, ofile, opt1)
%
% INPUTS
%   year   - year, as an integer
%   dlist  - list of days-of-the-year
%   ofile  - save file for obs lists
%
% DISCUSSION
%   mostly just airs_obs_list.m with different options
%
% AUTHOR
%  H. Motteler, 3 July 2017
%

function airs_map_list(year, dlist, ofile, opt1)

% default params 
adir = '/asl/data/airs/L1C';   % path to AIRS data
ixt = 1 : 90;         % full scans
v1 = 899; v2 = 904;   % Tb frequency span
T1 = 160; T2 = 360;   % save obs if T1 <= Tb <= T2
nLat = 24; dLon = 4;  % equal area bin spec

% process input options
if nargin == 4
  if isfield(opt1, 'adir'), adir = opt1.adir; end
  if isfield(opt1, 'ixt'),  ixt  = opt1.ixt; end
  if isfield(opt1, 'v1'),   v1   = opt1.v1; end
  if isfield(opt1, 'v2'),   v2   = opt1.v2; end
  if isfield(opt1, 'T1'),   T1   = opt1.T1; end
  if isfield(opt1, 'T2'),   T2   = opt1.T2; end
  if isfield(opt1, 'nLat'), nLat = opt1.nLat; end
  if isfield(opt1, 'dLon'), dLon = opt1.dLon; end
else
  opt1 = struct;
end

% path to AIRS data, including year
ayear = fullfile(adir, sprintf('%d', year));

% L1c channel frequencies
afrq = load('freq2645.txt');
ixv = find(v1 <= afrq & afrq <=v2);
afrq = afrq(ixv);

% initialize obs lists
Tb_list = [];
lat_list = [];
lon_list = [];
tai_list = [];
zen_list = [];
sol_list = [];
asc_list = logical([]);

% loop on days of the year
for di = dlist

  % loop on AIRS granules
  doy = sprintf('%03d', di);
  fprintf(1, 'doy %s ', doy)
  flist = dir(fullfile(ayear, doy, 'AIRS*L1C*.hdf'));

  for fi = 1 : length(flist)

    if mod(fi, 10) == 0, fprintf(1, '.'), end

    % read radiance, nchan x 90 x 135
    afile = fullfile(ayear, doy, flist(fi).name);
    try
      rad = hdfread(afile, 'radiances');
    catch
      fprintf(1, '\nairs_tbin: bad file %s', afile)
      continue
    end
    rad = rad(:, ixt, ixv);        % cross track and channel subset
    rad = permute(rad, [3,2,1]);   % transpose to column order

    % read geo data, 90 x 135
    lat = hdfread(afile, 'Latitude');
    lon = hdfread(afile, 'Longitude');
    tai = airs2tai(hdfread(afile, 'Time'));
    zen = hdfread(afile, 'satzen');
    sol = hdfread(afile, 'solzen');

    % cross track subset and transpose
    lat = lat(:,ixt); lat = permute(lat, [2,1]);
    lon = lon(:,ixt); lon = permute(lon, [2,1]);
    tai = tai(:,ixt); tai = permute(tai, [2,1]);
    zen = zen(:,ixt); zen = permute(zen, [2,1]);
    sol = sol(:,ixt); sol = permute(sol, [2,1]);

    % typical values
    %  lat     90x135   97200  double
    %  lon     90x135   97200  double
    %  rad  14x90x135  680400  single
 
    % basic radiance and latitude QC
    iOK = -90 <= lat & lat <= 90 & cAND(-1 < rad & rad < 250);

    % latitude subsample
    nxt = length(ixt);
    lat_rad = deg2rad(lat);
    jx = rand(nxt, 135) < abs(cos(lat_rad));
    jx = jx & iOK;

    % apply subsetting
    rad = rad(:,jx);
    lat = lat(jx);
    lon = lon(jx);
    tai = tai(jx);
    zen = zen(jx);
    sol = sol(jx);
    if isempty(lat), continue, end

    % typical values
    %  lat     2177x1   17416  double              
    %  lon     2177x1   17416  double              
    %  rad  14x2177    121912  single              

%   % land or ocean subsets
%   [~, landfrac] = usgs_deg10_dem(lat', lon');
%   ocean = landfrac(:) == 0;
%   rad = rad(:, ocean);
%   land = landfrac(:) == 1;
%   rad = rad(:, land);
%   if isempty(rad), continue, end

    % get window span rms Tb
    Tb = real(rad2bt(afrq, rad));
    rmsTb = rms(Tb);
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

  end % loop on granules
  fprintf(1, '\n')
end % loop on days

save(ofile, 'year', 'dlist', 'adir', 'ixt', 'v1', 'v2', ...
             'T1', 'T2', 'afrq', 'Tb_list', 'lat_list', ...
             'lon_list', 'tai_list', 'zen_list', 'sol_list');

% save an equal area map
%
% clear rad
% 
% [latB1, lonB1, gtot1, gavg1] = ...
%     equal_area_bins(nLat, dLon, lat_list, lon_list, Tb_list);
% 
% save(ofile, 'year', 'dlist', 'adir', 'ixt', 'v1', 'v2', ...
%             'T1', 'T2', 'afrq', 'nLat', 'dLon', 'latB1', 'lonB1', ...
%             'gtot1', 'gavg1') 
%

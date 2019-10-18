%
% NAME
%   oisst_match -- match NOAA OI SST with lat/lon/time lists
%
% SYNOPSIS
%   sst = oisst_match(tai_list, lat_list, lon_list);
%
% INPUTS
%   tai_list  - obs time, TAI vector
%   lat_list  - obs latitude vector
%   lon_list  - obs longitude vector
%
% OUTPUTS
%   sst  - corresponding SST vector
%
% DISCUSSION
%   Inputs must be in time order.  Latitude and longitude ranges
%   for inputs are -90 to 90 and -180 to 180.  Inputs can be single
%   precision, output is double because the tabulated SST values are
%   double.  Results for single and double precision inputs may
%   differ (very rarely) at bin edges.
%
%   Paths to the SST data and file-name prefixes are hard-coded,
%   for now.  The longitude range for the OI SST data is 0 to 360,
%   so the LHS and RHS are swapped before indexing.  This swap is
%   also useful for browsing SST data with the mapping toolbox.
%
%   oisst_match does not catch file errors.  It appears that read
%   errors aren't caught by ncread either, so you need a try/catch
%   or an "exist" test somewhere.  For the intended application the
%   read should fail if any part fails, and putting the call in a
%   try/catch does that.
%
% AUTHOR
%   H. Motteler, 14 Aug 2019
%

function sst = oisst_match(tai_list, lat_list, lon_list);

if ~issorted(tai_list), error('tai must be sorted'), end

% get first and last days
d1 = floor(tai2dnum(double(tai_list(1))));
d2 = ceil(tai2dnum(double(tai_list(end))));

sst = [];

% loop on datenums
for di = d1 : d2

  % partition obs by day
  t1 = dnum2tai(di);
  t2 = dnum2tai(di+1);
  ix = t1 <= tai_list & tai_list < t2;
  tai = tai_list(ix);
  lat = lat_list(ix);
  lon = lon_list(ix);

  % check that we have something
  if isempty(tai), continue, end

  % read the day's SST file 
  [yy,mm,dd] = datevec(di);
% sst_path = sprintf('/asl/xfs3/SST-OI/%4d/%02d', yy, mm);
  sst_path = sprintf('/asl/xfs3/SST_OI_flat/%4d%02d', yy, mm);  
  sst_file = sprintf('avhrr-only-v2.%4d%02d%02d.nc', yy, mm, dd);
  fprintf(1, 'sst_match: reading %s\n', sst_file);
  sst_file = fullfile(sst_path, sst_file);

  % the SST map is 1440 x 720 (lon x lat) with index 1 at lon 0
  sst_map = ncread(sst_file, 'sst');
  sst_map = sst_map';
  sst_map = [sst_map(:, 721:1440), sst_map(:,1:720)];

  % loop on individual obs
  n = length(lat);
  stmp = zeros(n, 1);
  for j = 1 : n

    % take values to indices
    ilat = floor((lat(j) + 90)/0.25) + 1;
    ilon = floor((lon(j) + 180)/0.25) + 1;

    % valid lat = 90 gives index 721, lon = 180 gives index 1441
    if ilat < 1 |  721 < ilat, error('latitude out of range'), end
    if ilon < 1 | 1441 < ilon, error('longitude out of range'), end

    % move boundary conditions (90 and 180) to bins 720 and 1440
    if ilat ==  721, ilat =  720; end
    if ilon == 1441, ilon = 1440; end

    % save the matching SST value
    stmp(j) = sst_map(ilat, ilon);
  end
  sst = [sst; stmp];
end


%
% simple test function to read a single sst obs
%
% input range lat -90 to 90, lon -180 to 180
% tabulation range lat -90 to 90, lon 0 to 360
%

function sst = simple_read(tai, lat, lon);

if numel(tai) > 1, error('tai must be scalar'), end

% read the SST file 
[yy,mm,dd] = datevec(tai2dnum(double(tai)));
sst_path = sprintf('/asl/xfs3/SST-OI/%4d/%02d', yy, mm);
sst_file = sprintf('avhrr-only-v2.%4d%02d%02d.nc', yy, mm, dd);
% fprintf(1, 'sst_match: reading %s\n', sst_file);
sst_file = fullfile(sst_path, sst_file);

% the SST map is 1440 x 720 (lon x lat) with index 1 at lon 0
sst_map = ncread(sst_file, 'sst');
sst_map = sst_map';
% sst_map = [sst_map(:, 721:1440), sst_map(:,1:720)];

% take values to indices
ilat = floor((lat + 90)/0.25) + 1;
ilon = floor(mod(lon + 360, 360)/0.25) + 1;

% valid lat = 90 gives index 721, lon = 180 gives index 1441
if ilat < 1 |  721 < ilat, error('latitude out of range'), end
if ilon < 1 | 1441 < ilat, error('longitude out of range'), end

% move boundary conditions (90 and 180) to bins 720 and 1440
if ilat ==  721, ilat =  720, end
if ilon == 1441, ilat = 1440, end

sst = sst_map(ilat, ilon);


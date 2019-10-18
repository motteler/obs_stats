%
% airs_geo_list -- AIRS geo obs list
%

addpath ../source
addpath /asl/packages/ccast/motmsc/time

% year and path to data
  ayear = '/asl/data/airs/L1C/2016';
% ayear = '/asl/data/airs/L1C/2018';

% days of the year
  dlist = 111 : 126;  % d1, 2016 16 day all good
% dlist = 118 : 133;  % d2, 2016 16 day all good
% dlist = 244;        %  1 Sep 2019 bad match day
% dlist = 259;        % 16 Sep 2018 good match day

% AIRS scan spec
%   ixt = 43 : 48;              % s1, near nadir
    ixt =  1 : 90;              % s2, full scan
%   ixt = [21:23 43:48 68:70];  % s3, near nadir plus half scan
%   ixt = [21:23 68:70];        % s4, half scan only
%   ixt = 37 : 54;              % s5, expanded nadir
nxt = length(ixt);  

% cosine exponent
  w = 1.0;
% w = 1.1;

% tabulated values
lat = [];
lon = [];
zen = [];
sol = [];
tai = [];

% loop on days of the year
for di = dlist
  
  % loop on L1c granules
  doy = sprintf('%03d', di);
  flist = dir(fullfile(ayear, doy, 'AIRS*L1C*.hdf'));

  for fi = 1 : length(flist);

    afile = fullfile(ayear, doy, flist(fi).name);
    tlat = hdfread(afile, 'Latitude');
    tlon = hdfread(afile, 'Longitude');
    ttai = airs2tai(hdfread(afile, 'Time'));
    tzen = hdfread(afile, 'satzen');
    tsol = hdfread(afile, 'solzen');

    tlat = tlat(:, ixt);  tlat = tlat(:);
    tlon = tlon(:, ixt);  tlon = tlon(:);
    ttai = ttai(:, ixt);  ttai = ttai(:);
    tzen = tzen(:, ixt);  tzen = tzen(:);
    tsol = tsol(:, ixt);  tsol = tsol(:);

    iOK = -90 <= tlat & tlat <= 90 & -180 <= tlon & tlon <= 180;
    tlat = tlat(iOK); 
    tlon = tlon(iOK);
    ttai = ttai(iOK); 
    tzen = tzen(iOK);
    tsol = tsol(iOK); 

    lat = [lat;, tlat];
    lon = [lon;, tlon];
    tai = [tai;, ttai];
    zen = [zen;, tzen];
    sol = [sol;, tsol];

    if mod(fi, 10) == 0, fprintf(1, '.'), end
  end
  fprintf(1, '\n')
end

% total good obs count
nobs = numel(lat);
fprintf(1, '%d initial good obs\n', nobs)

% get latitude subset as rand < abs(cos(lat))
lat_rad = deg2rad(lat);
ix = rand(nobs, 1) < abs(cos(lat_rad).^w);
slat = lat(ix);
slon = lon(ix);
stai = tai(ix);
szen = zen(ix);
ssol = sol(ix);
nsub = numel(slat);
fprintf(1, '%d obs after subset\n', nsub)

save airs_geo_xxxx ...
  ayear dlist ixt w nobs nsub slat slon stai szen ssol


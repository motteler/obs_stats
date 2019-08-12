%
% cris_geo_list -- CrIS geo obs list
%

addpath ../source
addpath /asl/packages/ccast/motmsc/time

% year and path to data
  cyear = '/asl/cris/ccast/sdr45_npp_HR/2016';
% cyear = '/asl/cris/ccast/sdr45_npp_HR/2018';

% days of the year
  dlist = 111 : 126;  % d1, 2016 16 day all good
% dlist = 118 : 133;  % d2, 2016 16 day all good
% dlist = 101 : 116;  % d3, 2016 CrIS-only good span 1
% dlist = 117 : 132;  % d4, 2016 CrIS-only good span 2
% dlist = 244;        % Chris H. 2018 sample test

% CrIS scan spec
% iFOR = 15 : 16;       % s1, near nadir
  iFOR =  1 : 30;       % s2, full scan
% iFOR = [8 15 16 23];  % s3, near nadir plus half scan
% iFOR = [8 23];        % s4, half scan only
% iFOR = 13 : 18;       % s5, expanded nadir
nFOR = length(iFOR);

% specify FOVs
  iFOV = 1 : 9;
% iFOV = [3 6 9];
% iFOV = 9;
nFOV = length(iFOV);

% cosine exponent
  w = 1.0;
% w = 1.1;

% tabulated values
lat = [];
lon = [];
zen = [];
sol = [];
tai = [];
asc = logical([]);

% loop on days of the year
for di = dlist

  % loop on CrIS granules
  doy = sprintf('%03d', di);
  flist = dir(fullfile(cyear, doy, 'CrIS_SDR*.mat'));

  for fi = 1 : length(flist);

    cfile = fullfile(cyear, doy, flist(fi).name);
    d1 = load(cfile, 'geo');
    tlat = d1.geo.Latitude(iFOV, iFOR, :);
    tlon = d1.geo.Longitude(iFOV, iFOR, :);
    tzen = d1.geo.SatelliteZenithAngle(:, iFOR, :);
    tsol = d1.geo.SolarZenithAngle(:, iFOR, :);
    ttai = iet2tai(d1.geo.FORTime(iFOR, :));
    tasc = d1.geo.Asc_Desc_Flag;

    tlat = tlat(:);
    tlon = tlon(:);
    tzen = tzen(:);
    tsol = tsol(:);
    ttai = ones(nFOV,1) * ttai(:)';
    ttai = ttai(:);
    tasc = ones(nFOV*nFOR,1) * tasc(:)';
    tasc = tasc(:) == 1;

    lat = [lat; tlat];
    lon = [lon; tlon];
    zen = [zen; tzen];
    sol = [sol; tsol];
    tai = [tai; ttai];
    asc = [asc; tasc];

    if mod(fi, 10) == 0, fprintf(1, '.'), end
  end
  fprintf(1, '\n')
end

% get good obs subset
iOK = -90 <= lat & lat <= 90 & -180 <= lon & lon <= 180 & ...
      ~isnan(lat) & ~isnan(lon);
lat = lat(iOK);
lon = lon(iOK);
zen = zen(iOK);
sol = sol(iOK);
tai = tai(iOK);
asc = asc(iOK);

nobs = numel(lat);
fprintf(1, '%d initial good obs\n', nobs)

% % get latitude subset as rand < abs(cos(lat))
lat_rad = deg2rad(lat);
  ix = rand(nobs, 1) < abs(cos(lat_rad).^w);
% ix = 1 : numel(lat);
slat = lat(ix);
slon = lon(ix);
stai = tai(ix);
sasc = asc(ix);
szen = zen(ix);
ssol = sol(ix);
nsub = numel(slat);
fprintf(1, '%d obs after subset\n', nsub)

% asc/desc subset
% slat = slat(~sasc);
% slon = slon(~sasc);
% stai = stai(~sasc);

save cris_geo_xxxx ...
  cyear dlist iFOR iFOV w nobs nsub slat slon stai szen ssol


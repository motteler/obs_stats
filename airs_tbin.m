%
% NAME
%   airs_tbin - tabulate AIRS obs x Tb bins
%
% SYNOPSIS
%   airs_tbin(year, dlist, tfile, opt1)
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

function airs_tbin(year, dlist, tfile, opt1)

% default params 
adir = '/asl/data/airs/L1C';   % path to AIRS data
ixt = 1 : 90;         % full scans
v1 = 899; v2 = 904;   % Tb frequency span
T1 = 180; T2 = 340;   % Tb bin span
dT = 0.5;             % Tb bin step size
nedn = 0.2;           % noise for smoothing

% process input options
if nargin == 4
  if isfield(opt1, 'adir'), adir = opt1.adir; end
  if isfield(opt1, 'ixt'),  ixt  = opt1.ixt; end
  if isfield(opt1, 'v1'),   v1   = opt1.v1; end
  if isfield(opt1, 'v2'),   v2   = opt1.v2; end
  if isfield(opt1, 'T1'),   T1   = opt1.T1; end
  if isfield(opt1, 'T2'),   T2   = opt1.T2; end
  if isfield(opt1, 'dT'),   dT   = opt1.dT; end
  if isfield(opt1, 'nedn'), nedn = opt1.nedn; end
else
  opt1 = struct;
end

% path to AIRS data, including year
ayear = fullfile(adir, sprintf('%d', year));

% initialize Tb bins
tind = T1 : dT : T2;
tmid = tind + dT/2;
nbin = length(tind);
nday = length(dlist);
tbin = zeros(nbin, nday);

% L1c channel frequencies
afrq = load('freq2645.txt');
ixv = find(v1 <= afrq & afrq <=v2);
afrq = afrq(ixv);

% loop on days of the year
for di = 1 : nday

  % loop on AIRS granules
  doy = sprintf('%03d', dlist(di));
  fprintf(1, 'doy %s ', doy)
  flist = dir(fullfile(ayear, doy, 'AIRS*L1C*.hdf'));

  for fi = 1 : length(flist);

    % radiance channel and xtrack subset
    afile = fullfile(ayear, doy, flist(fi).name);
    try
      rad = hdfread(afile, 'radiances');
    catch
      fprintf(1, '\nairs_tbin: bad file %s', afile)
      continue
    end
    rad = rad(:, ixt, ixv);
    rad = permute(rad, [3,2,1]);

    % latitude xtrack subset
    lat = hdfread(afile, 'Latitude');
    lat = lat(:,ixt);
    lat = permute(lat, [2,1]);

    % longitude xtrack subset
    lon = hdfread(afile, 'Longitude');
    lon = lon(:,ixt);
    lon = permute(lon, [2,1]);

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
    if isempty(lat), continue, end

    % typical values
    %  lat     2177x1   17416  double              
    %  lon     2177x1   17416  double              
    %  rad  14x2177    121912  single              

%   % land or ocean subsets
%   [~, landfrac] = usgs_deg10_dem(lat', lon');
%   ocean = landfrac == 0;
%   rad = rad(:, ocean);
%   land = landfrac == 1;
%   rad = rad(:, land);
%   if isempty(rad), continue, end

    % add noise to smooth discretization
    [m,n] = size(rad);
    rad = rad + randn(m,n) * nedn;

    % increment Tb bin counts
    Tb = real(rad2bt(afrq, rad));
    rmsTb = rms(Tb);
    rmsTb = rmsTb(:);

    ix = floor((rmsTb - T1) / dT) + 1;
    ix(ix < 1) = 1;
    ix(nbin < ix) = nbin;

    for i = 1 : length(ix)
      tbin(ix(i), di) = tbin(ix(i), di) + 1;
    end

    if mod(fi, 10) == 0, fprintf(1, '.'), end
  end % loop on granules
  fprintf(1, '\n')
end % loop on days

save(tfile, 'year', 'dlist', 'adir', 'ixt', 'v1', 'v2', ...
            'dT', 'T1', 'T2', 'nedn', 'afrq', 'tind', 'tmid', 'tbin')



%
% airs_trends -- mean and variance of latitude bands
%
% AIRS "c3" channel set
%   1   699.380    250 mb peak
%   2   746.967    CO2 proxy
%   3   902.040    LW window
%   4  1231.330    MW window
%   5  1613.862    400 mb peak
%   6  2384.252    250 mb peak
%   7  2500.601    SW window
%
% basic map table
%   dnum - time index as datenums
%   ntab - nlat x nlon x nset
%   utab - nchan x nlat x nlon x nset
%   vtab - nchan x nlat x nlon x nset
%
% misc support variables
%   nchan - number of tabulated channels
%   vlist - tabulated channel frequencies
%   nlat  - number of latitude bins
%   nlon  - number of longitude bins
%   latB  - nlat+1 vector, latitude bin boundaries
%   lonB  - nlon+1 vector, longitude bin boundaries
%   nset  - total number of 16-day sets
%
% saved values
%   dax   - nset time index as datetime
%   nband - nchan x nlat x nset obs counts
%   uband - nchan x nlat x nset band means
%   vband - nchan x nlat x nset band variance
%

addpath ../source
addpath ../map_16day_airs_c3
addpath /asl/packages/ccast/source

%-------------------------------------------
% combine annual tabulations of 16-day maps
%-------------------------------------------
dnum = []; % time index as datenums
ntab = []; % nlat x nlon x time bin count
utab = []; % nchan x nlat x nlon x time bin mean
vtab = []; % nchan x nlat x nlon x time bin variance

% loop on annual tabulations
for year = 2002 : 2019

  mfile = sprintf('airs_c03_%d_tab.mat', year);
  fprintf(1, 'loading %s\n', mfile);
  if exist(mfile) == 2
    c1 = load(mfile);
  else
    fprintf(1, 'missing %s\n', mfile)
    continue
  end

  % 16-day set midpoint day-of-year as datenums
  dlist = (c1.sind - 1) * 16 + 8;
  dtmp = datenum([c1.year, 1, 1]) + dlist;

  % check data
  if find(isnan(c1.yavg)), keyboard, end
  if find(isnan(c1.yvar)), keyboard, end

  % tabulate map data
  dnum = [dnum, dtmp];
  utab = cat(4, utab, c1.yavg);
  vtab = cat(4, vtab, c1.yvar);
  ntab = cat(3, ntab, squeeze(c1.ytot));
end

[nchan, nlat, nlon, nset] = size(utab);

% add 1's row to ntab to match utab and vtab
ntab = ones(nchan, 1) * ntab(:)';
ntab = reshape(ntab, nchan, nlat, nlon, nset);

% vlist and bin boundaries from annual tab
vlist = c1.vlist;
latB = c1.latB;
lonB = c1.lonB;

% datetime values for dnum 16-day set times
dax = datetime(dnum, 'ConvertFrom', 'datenum');

%---------------------------------------
% mean and variance over latitude bands
%---------------------------------------

nband = zeros(nchan, nlat, nset);
uband = zeros(nchan, nlat, nset);
vband = zeros(nchan, nlat, nset);

% loop on latitude bands
for j = 1 : nlat

  % nchan x nlon x nset temp vars
  ntmp = squeeze(ntab(:,j,:,:));
  utmp = squeeze(utab(:,j,:,:));
  vtmp = squeeze(vtab(:,j,:,:));

  % take mean and variance over the nlon dimension
  for i = 1 : nset
    [nband(:,j,i), uband(:,j,i), vband(:,j,i)] = ...
       merge_tree(ntmp(:,:,i), utmp(:,:,i), vtmp(:,:,i));
  end
end

%-----------------------------------
% linear trends over latitude bands
%-----------------------------------

%   4  1231.330    MW window
%   5  1613.862    400 mb peak
%   6  2384.252    250 mb peak
%   7  2500.601    SW window

c1 = 4;  c2 = 7;

P1 = zeros(2, nlat);
P2 = zeros(2, nlat);

% loop on latitude bands
for j = 1 : nlat
  utmp1 = squeeze(uband(c1,j,:,:));
  utmp2 = squeeze(uband(c2,j,:,:));
  P1(:, j) = polyfit(dnum', utmp1, 1);
  P2(:, j) = polyfit(dnum', utmp2, 1);        
end

figure(1); clf
x = (latB(1:48)+latB(2:49)) / 2;
plot(x, P1(1,:)*365, x, P2(1,:)*365, 'linewidth', 2)
axis([-90, 90, -0.05, 0.1]);
title('AIRS 2002-2019 trends by latitude')
legend('1231.3 cm-1', '2500.6 cm-1', 'location', 'northwest')
xlabel('latitude')
ylabel('dK / year')
grid on; zoom on

% saveas(gcf, 'AIRS_trends_by_latitude', 'png')

return

% save selected values
save airs_lat_band_means ...
  dnum dax vlist nlat nlon latB nband uband vband

% sanity check plot
y1 = squeeze(uband(3, 6, :));
y2 = squeeze(uband(3, 42, :));
plot(dax, y1, dax, y2)
legend('band 1', 'band 2')
xlabel('year')
ylabel('BT (K)')
grid on


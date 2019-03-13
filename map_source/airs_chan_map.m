%
% airs_chan_map -- 16-day maps to lat x lon x time channel maps
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
% map table
%   dnum - time index as datenums
%   ntab - nlat x nlon x nset
%   utab - nchan x nlat x nlon x nset
%   vtab - nchan x nlat x nlon x nset
%
% summary maps
%   nmap - nchan x nlat x nlon
%   umap - nchan x nlat x nlon
%   vmap - nchan x nlat x nlon
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

addpath ../source
addpath /asl/packages/ccast/source

%-------------------------------------------
% combine annual tabulations of 16-day maps
%-------------------------------------------
dnum = []; % time index as datenums
ntab = []; % nlat x nlon x time bin count
utab = []; % nchan x nlat x nlon x time bin mean
vtab = []; % nchan x nlat x nlon x time bin variance

% loop on annual tabulations
for year = 2002 : 2018

  mfile = sprintf('airs_c03_%d_tab.mat', year);
% mfile = sprintf('airsX_c03_%d_tab.mat', year);
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
ntmp = ones(nchan, 1) * ntab(:)';
ntmp = reshape(ntmp, nchan, nlat, nlon, nset);

latB = c1.latB;
lonB = c1.lonB;
vlist = c1.vlist;

%----------------------
% summary mean and std
%----------------------

[nmap, umap, vmap] = merge_tree(ntmp, utab, vtab);

% umap = rad2bt(vlist, umap);
% vmap = rad2bt(vlist, vmap);

ic = 3;

utmp = squeeze(umap(ic,:,:));
tstr = sprintf('AIRS %.2f cm-1 15 year mean', vlist(ic));
equal_area_map(1, latB, lonB, utmp, tstr);
c = colorbar; c.Label.String = 'degrees (K)';

vtmp = squeeze(vmap(ic,:,:));
tstr = sprintf('AIRS %.2f cm-1 15 year std', vlist(ic));
equal_area_map(2, latB, lonB, sqrt(vtmp), tstr);
c = colorbar; c.Label.String = 'degrees (K)';

d1 = load('radmean');

du = squeeze(d1.umap(ic,:,:)) - squeeze(umap(ic,:,:));
tstr = sprintf('AIRS %.2f cm-1 rad mean minus bt mean', vlist(ic));
equal_area_map(3, latB, lonB, du, tstr);
c = colorbar; c.Label.String = 'degrees (K)';

% load llsmap5
% colormap(llsmap5)
% caxis([-0.2, 0.2])
% c = colorbar;
% c.Label.String = 'degrees (K)/year';


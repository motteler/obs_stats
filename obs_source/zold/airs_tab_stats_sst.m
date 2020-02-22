%
% airs_tab_stats -- annual map tables to map stats
%
% this version compares OI SST with AIRS BT
%
%    airs c4 channel set
%  ind   freq      comments
% ---------------------------------------
%   1    830.47   Window, H2O Cont
%   2    843.91   CFC-11
%   3    899.62   Window, Edge M-08 small a/b drift there
%   4    921.64   CFC-12  (0.1K over 16 years)
%   5    968.23   Window, tiny CO2?
%   6    992.45   Window
%   7   1227.71   Weak water, used to get column water with 1520
%   8   1231.33   Window, lowest WV absorption
%   9   sea surface temperature
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
addpath ../map_16day_airs_c4

%-------------------------------------------
% combine annual tabulations of 16-day maps
%-------------------------------------------
dnum = []; % time index as datenums
ntab = []; % nlat x nlon x time bin count
utab = []; % nchan x nlat x nlon x time bin mean
vtab = []; % nchan x nlat x nlon x time bin variance

% loop on annual tabulations
for year = 2002 : 2019

  mfile = sprintf('airs_c04x_g2_%d_tab.mat', year);
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
% if find(isnan(c1.yavg)), keyboard, end
% if find(isnan(c1.yvar)), keyboard, end

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
% selected annual diffs
%-----------------------

y1 = 115;
y2 = y1 + 10 * 23;
datestr(dnum(y1))
datestr(dnum(y2))
s1 = y1 : y1 + 22;
s2 = y2 : y2 + 22;

[datestr(dnum(s1(1))), '  ', datestr(dnum(s1(end)))]
[datestr(dnum(s2(1))), '  ', datestr(dnum(s2(end)))]

ntmp1 = ntmp(:,:,:,s1);
utmp1 = utab(:,:,:,s1);
vtmp1 = vtab(:,:,:,s1);
[nmap1, umap1, vmap1] = merge_tree(ntmp1, utmp1, vtmp1);

ntmp2 = ntmp(:,:,:,s2);
utmp2 = utab(:,:,:,s2);
vtmp2 = vtab(:,:,:,s2);
[nmap2, umap2, vmap2] = merge_tree(ntmp2, utmp2, vtmp2);

udiff = umap2 - umap1;           % take the difference
udiff = squeeze(udiff(10,:,:));  % select a channel for plots

tstr = 'AIRS CF 2017 minus 2007 difference';
equal_area_map(1, latB, lonB, udiff, tstr);
c = colorbar; c.Label.String = 'degrees (K)';
% saveas(gcf, 'AIRS_CF_2017_minus_2007_diff', 'png')
% saveas(gcf, 'AIRS_CF_2017_minus_2007_diff', 'fig')

return

%----------------------
% summary mean and std
%----------------------

[nmap, umap, vmap] = merge_tree(ntmp, utab, vtab);

% choose channel for plots
ic = 10;  

% tstr = sprintf('AIRS %.2f cm-1 15 year std', vlist(ic));
  tstr = 'AIRS CF 2002-2019 mean';
equal_area_map(1, latB, lonB, squeeze(umap(ic,:,:)), tstr);
c = colorbar; c.Label.String = 'degrees (K)';
% saveas(gcf, 'AIRS_CF_2002-2019_mean', 'png')

vtmp = squeeze(vmap(ic,:,:));
% tstr = sprintf('AIRS %.2f cm-1 15 year std', vlist(ic));
  tstr = sprintf('AIRS CF 2002-2019 std');
equal_area_map(2, latB, lonB, sqrt(vtmp), tstr);
c = colorbar; c.Label.String = 'degrees (K)';
% saveas(gcf, 'AIRS_CF_2002-2019_std', 'png')

fprintf(1, '%.2f obs/tile\n', mean(nmap(:)))

return

% show the CF approximation
SST = squeeze(umap(9,:,:));
BT1228 = squeeze(umap(7,:,:));
BT1231 = squeeze(umap(8,:,:));
P = [-0.17 -0.15 -1.66  1.06];
% CF = (SST - polyval(P, BT1228 - BT1231)) - BT1231;
  CF = BT1231 - (SST - polyval(P, BT1228 - BT1231));

tstr = 'AIRS cloud forcing 2002-2019 mean';
equal_area_map(3, latB, lonB, CF, tstr);
c = colorbar; c.Label.String = 'degrees (K)';

return

% choose channel (1-8) for diff
ic = 8;  

tstr = 'OI SST 2002-2019 mean';
equal_area_map(1, latB, lonB, squeeze(umap(9,:,:)), tstr);
c = colorbar; c.Label.String = 'degrees (K)';

tstr = sprintf('AIRS %.2f cm-1 2002-2019 mean', vlist(ic));
equal_area_map(2, latB, lonB, squeeze(umap(ic,:,:)), tstr);
c = colorbar; c.Label.String = 'degrees (K)';

% take the SST diff
udif = squeeze(umap(9,:,:) - umap(ic,:,:));
tstr = sprintf('SST minus AIRS %.2f cm-1 2002-2019 mean', vlist(ic));
equal_area_map(3, latB, lonB, udif, tstr);
c = colorbar; c.Label.String = 'degrees (K)';


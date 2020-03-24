%
% airs_pdf_stats -- stats from annual pdf map tables
%
% reads annual pdf map tables, with variables
%   tbtab - nbin x nlat x nlon x nset pdf map table
%   tbins - nbin vector, pdf temperature bins
%   sind  - nset vector, list of 16 day set indices
%   latB  - nlat+1 vector, latitude bin boundaries
%   lonB  - nlon+1 vector, longitude bin boundaries
%   cfrq  - channel frequency (nan for CF & SST)
%
% new or updated working variables
%   tbtab - nbin x nlat x nlon x nset, multi-year table
%   dnum  - nset vector, datenum values for set index
%
% this version is for CF and SST plots (NaNs for land)
%
% The section "global or regional trends" takes a region specified
% with a bounding box or with a list of lat/lon pairs, finds the PDF
% for the region, for each 16-day set, and plots both raw trends and
% trends smoothed with a moving average.
%

addpath ../source
addpath /asl/packages/ccast/source
addpath ../pdf_16day_airs

%-------------------------------------------
% combine annual tabulations of 16-day maps
%-------------------------------------------
dnum = [];   % nset index as datenums
tbtab = [];  % nbin x nlat x nlon x nset

% loop on annual tabulations
for year = 2002 : 2019

  mfile = sprintf('airs_CF_g2_%d_pdf.mat', year);
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

  % tabulate pdf (tbin) data
  dnum = [dnum, dtmp];
  tbtab = cat(4, tbtab, c1.tbtab);

end

latB = c1.latB;
lonB = c1.lonB;
% cfrq = c1.cfrq;
% tbins = c1.tbins;
tbins = -140 : 2 : 70;

%---------------------------------
% summary map over all time steps
%---------------------------------

% sum bins over all time steps
[nbin, nlat, nlon, nset] = size(tbtab);
tbmap = zeros(nbin, nlat, nlon);
for k = 1 : nset
  for j = 1 : nlon
    for i = 1 : nlat
      tbmap(:,i,j) = tbmap(:,i,j) + tbtab(:,i,j,k);
    end
  end
end

% tstr = 'AIRS 2002-2019 CF 4-12 K PDF map';
  tstr = 'AIRS 2002-2019 CF 4-8 K PDF map';
% tstr = 'AIRS 2002-2019 CF 50-100 K PDF map';
bin_sum = squeeze(sum(tbmap));
% bin_span = squeeze(sum(tbmap(65:69,:,:)));
  bin_span = squeeze(sum(tbmap(67:69,:,:)));
% bin_span = squeeze(sum(tbmap(21:46,:,:)));
bin_rel = bin_span ./ bin_sum;
equal_area_map(1, latB, lonB, bin_rel, tstr);
% saveas(gcf, t2fstr(tstr), 'png'

%---------------------------
% global or regional trends
%---------------------------

[nbin, nlat, nlon, nset] = size(tbtab);

% take both overall and subrange bin sums, for each map tile.
% result is an nlat x nlon x nset array.
tz = squeeze(sum(tbtab));
ty = squeeze(sum(tbtab(67:69,:,:,:)));

if false
  % do a geo subset from lat/lon bounds
  % ilat = 1:nlat;  ilon = 1:nlon;   % all lat and lon
  % ilat = 21:45;                    % -22:22 latitude band
  % ilat = 21:22;   ilon = 63:64;    % 2 x 2 W. Africa ocean
    ilat = 21;      ilon = 63;       % single tile test

  % apply the region selection
  ty = ty(ilat, ilon, :);
  tz = tz(ilat, ilon, :);

  % flatten the resulting lat/lon array
  [mlat, mlon, mset] = size(tz);
  mtile = mlat * mlon;
  ty = reshape(ty, mtile, mset); 
  tz = reshape(tz, mtile, mset); 
else
  % do a geo subset from a list of [lat, lon] pairs
  % iList = [[21, 63]; [21, 64]; [22, 63]; [22, 64]];
  % iList = [21, 63];
  d1 = load('mbl_ind_1'); iList = d1.iList;

  % flatten the original lat/lon array
  ntile = nlat * nlon;
  ty = reshape(ty, ntile, nset); 
  tz = reshape(tz, ntile, nset); 

  % get indices into the flattened array
  ix = sub2ind([nlat, nlon], iList(:,1), iList(:,2));
  ty = ty(ix, :);
  tz = tz(ix, :);
end

% check for land-flag NaNs
[mtile, mset] = size(tz);
iOK = logical(ones(mtile, 1));
for i = 1 : mset
  iOK = iOK & ~isnan(tz(:,i));
end

% sum over ocean sets
tz = sum(tz(iOK, :),1);
ty = sum(ty(iOK, :),1);

% datetime axes for plots 
dax = datetime(dnum, 'ConvertFrom', 'datenum');

figure(2); clf
plot(dax, ty./tz, 'linewidth', 2)
tstr = 'AIRS [region] 2002-2019 CF 4-8K 16-day PDFs';
title(tstr)
ylabel('PDF weight')
xlabel('year')
grid on; zoom on
% saveas(gcf, t2fstr(tstr), 'fig')

% take a simple moving average of pdf weights
nsp = 11;  % half-span
pwt = ty./tz;
pmv = zeros(1,nset);

for j = 1 : nset
  i1 = max(1, j-nsp);
  i2 = min(j+nsp, nset);
% [i1,i2]
  pmv(j) = mean(pwt(i1:i2));
end

figure(3); clf
P = polyfit(dnum, pmv, 1);
plot(dax, pmv, dax, polyval(P, dnum), 'linewidth', 2)
legend('moving avg', 'linear fit')
xlim([datetime('Sep 6, 2003'), datetime('Aug 5, 2018')])
tstr = 'AIRS [region] 2003-2018 CF 4-8K PDF 1-yr moving avg';
title(tstr)
ylabel('PDF weight')
xlabel('year')
grid on; zoom on
% saveas(gcf, t2fstr(tstr), 'fig')

% summary annual trend
zz = polyval(P, dnum);  % the interpolated function
w1 = diff(zz);          % change per 16-day step
w2 = w1(1) * 23;        % annual change
fprintf(1, 'trend = %.4f pct/year\n', 100*w2)


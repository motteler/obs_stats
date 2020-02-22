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

addpath ../source
addpath /asl/packages/ccast/source
% addpath ../map_16day_airs_c4
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

%------------
% sample map
%------------

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
% saveas(gcf, t2fstr(tstr), 'fig')

%---------------
% sample trends
%---------------

% optional -22:22 lat band subset
  tbtab = tbtab(:,21:45,:,:);

[nbin, nlat, nlon, nset] = size(tbtab);

% global summary for tbin subset x time
% we need both the overall and subrange bin sums
tz = squeeze(sum(tbtab));
% ty = squeeze(sum(tbtab(65:69,:,:,:)));
  ty = squeeze(sum(tbtab(67:69,:,:,:)));
% ty = squeeze(sum(tbtab(21:46,:,:,:)));

ty = reshape(ty, nlat * nlon, nset); 
tz = reshape(tz, nlat * nlon, nset); 

% SST and CF flag land as NaNs
iOK = logical(ones(nlat*nlon, 1));
jOK = iOK;
for i = 1 : nset-1
  iOK = iOK & ~isnan(ty(:,i));
  jOK = jOK & ~isnan(tz(:,i));
end

% sum over ocean sets
tz = sum(tz(jOK, :));
ty = sum(ty(iOK, :));
P = polyfit(dnum, ty./tz, 1);

% datetime axes for plots 
dax = datetime(dnum, 'ConvertFrom', 'datenum');

figure(2); clf
% plot(dax, ty, dax, polyval(P, dnum), 'linewidth', 2)
  plot(dax, ty./tz, dax, polyval(P, dnum), 'linewidth', 2)
% tstr = 'AIRS global 2002-2019 CF 4-12K PDF trend';
  tstr = 'AIRS global 2002-2019 CF 4-8K PDF trend';
% tstr = 'AIRS global 2002-2019 CF 50-100K PDF trend';
title(tstr)
legend('16-day sets', 'linear fit', 'location', 'southwest')
ylabel('PDF weight')
xlabel('year')
grid on; zoom on

% saveas(gcf, t2fstr(tstr), 'png')
% saveas(gcf, t2fstr(tstr), 'fig')

% summary annual trend
% zz = polyval(P, dnum);  % the interpolated function
% w1 = diff(zz);          % change per 16-day step
% w2 = w1(1) * 23;        % annual change
% fprintf(1, 'trend = %.4f pct/year\n', 100*w2)

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
plot(dax, pmv, 'linewidth', 2)
xlim([datetime('Sep 6, 2003'), datetime('Aug 5, 2018')])
% tstr = 'AIRS global 2003-2018 CF 4-8K PDF moving avg';
  tstr = 'AIRS -22:22 lat 2003-2018 CF 4-8K PDF moving avg';
title(tstr)
ylabel('PDF weight')
xlabel('year')
grid on; zoom on

saveas(gcf, t2fstr(tstr), 'png')

return

%---------------
% global summary
%---------------

figure(2); clf
tbins = -140 : 2 : 70;  % want to get this from the file

% reshape tbtab for easier ocean indexing
tbtab = reshape(tbtab, nbin, nlat*nlon, nset);

iL = cOR(cOR(isnan(tbtab))');  % boolean flags of land tiles
iW = find(~iL);                % index list of ocean tiles
tbOcean = tbtab(:,iW,:);       % ocean-only map tiles

tb_all_obs_ocean = sum(tbOcean(:,:),2);
semilogy(tbins,tb_all_obs_ocean, 'linewidth', 2)
title('AIRS 2002-2019 CF global counts');
xlabel('temperature bins (K)')
ylabel('bin counts')
grid on; zoom on
% saveas(gcf, 'AIRS_2002-2019_CF_global_counts', 'png')


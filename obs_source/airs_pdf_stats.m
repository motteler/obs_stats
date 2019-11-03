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

addpath ../source
addpath ../pdf_16day_airs
addpath /asl/packages/ccast/source

%-------------------------------------------
% combine annual tabulations of 16-day maps
%-------------------------------------------
dnum = [];   % nset index as datenums
tbtab = [];  % nbin x nlat x nlon x nset

% loop on annual tabulations
for year = 2002 : 2019

% mfile = sprintf('airs_c4-6_g2_%d_pdf.mat', year);
  mfile = sprintf('airs_c4-8_g2_%d_pdf.mat', year);
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
cfrq = c1.cfrq;
tbins = c1.tbins;

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

% tstr = 'AIRS %.2f cm-1 2002-2019 324-340 K PDF map';
% tstr = 'AIRS %.2f cm-1 2002-2019 320-340 K PDF map';
% tstr = 'AIRS %.2f cm-1 2002-2019 310-330 K PDF map';
  tstr = 'AIRS %.2f cm-1 2002-2019 270-280 K PDF map';
tstr = sprintf(tstr, cfrq);
bin_sum = squeeze(sum(tbmap));
% bin_span = squeeze(sum(tbmap(63:71,:,:)));
% bin_span = squeeze(sum(tbmap(61:71,:,:)));
% bin_span = squeeze(sum(tbmap(56:66,:,:)));
  bin_span = squeeze(sum(tbmap(36:41,:,:)));
bin_rel = bin_span ./ bin_sum;

equal_area_map(1, latB, lonB, bin_rel, tstr);
c = colorbar; c.Label.String = 'relative weight';
% saveas(gcf, t2fstr(tstr), 'png')

%---------------
% sample trends
%---------------

% global summary for tbin subset x time
% ty = squeeze(sum(tbtab(63:71,:,:,:)));
% ty = squeeze(sum(tbtab(61:71,:,:,:)));
% ty = squeeze(sum(tbtab(56:66,:,:,:)));
  ty = squeeze(sum(tbtab(36:41,:,:,:)));
ty = reshape(ty, 64 * 120, 390); 
ty = sum(ty);
P = polyfit(dnum, ty, 1);

% datetime axes for plots 
dax = datetime(dnum, 'ConvertFrom', 'datenum');

figure(2); clf
plot(dax, ty, dax, polyval(P, dnum), 'linewidth', 2)
% tstr = 'AIRS 2002-2019 %.2f cm-1 324-340 K PDF trend';
% tstr = 'AIRS 2002-2019 %.2f cm-1 320-340 K PDF trend';
% tstr = 'AIRS 2002-2019 %.2f cm-1 310-330 K PDF trend';
  tstr = 'AIRS 2002-2019 %.2f cm-1 270-280 K PDF trend';
tstr = sprintf(tstr, cfrq);
title(tstr)
legend('16-day sets', 'linear fit', 'location', 'northwest')
ylabel('bin count')
xlabel('year')
grid on; zoom on
% saveas(gcf, t2fstr(tstr), 'png')

fprintf(1, 'trend = %.2f counts/year\n', P(1)*365)
fprintf(1, 'relative trend = %.2f pct/year\n', 100*P(1)*365 / mean(ty))

return

%---------------
% global summary
%---------------

figure(3); clf
tb_all_obs = sum(tbtab(:,:),2);
semilogy(tbins,tb_all_obs, 'linewidth', 2)
tstr = 'AIRS 2002-2019 %.2f cm-1 2002-2019 global counts';
title(sprintf(tstr, cfrq))
xlabel('temperature bins (K)')
ylabel('bin counts')
grid on; zoom on
fstr = 'AIRS_2002-2019_%.0f_cm-1_global_counts';
% saveas(gcf, sprintf(fstr, cfrq), 'png')

return

%-------------------------------
% means of hottest x pct of obs
%-------------------------------

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

mean_map = zeros(nlat, nlon);
% convert map tbins to means
for j = 1 : nlon
  for i = 1 : nlat
    bin_total = sum(tbmap(:,i,j));
    cutoff = floor(bin_total / 100);
    count = 0;
    % count down from top
    for q = nbin : -1 : 1
      count = count + tbmap(q,i,j);
      if count > cutoff, break, end
    end
    s2 = sum(tbmap(q:nbin, i, j));
    if s2 ~= count, error('s2 != count'), end
    t1 = sum(tbins(q:nbin)' .* (tbmap(q:nbin,i,j) / s2));
    mean_map(i, j) = t1;
  end
end

figure(1)
tstr = 'AIRS 2002-2019 means of hottest 1 pct';
equal_area_map(1, latB, lonB, mean_map, tstr);
c = colorbar;
c.Label.String = 'bin mean ( K )';

return

%---------------------------
% global pdf x time step plot
%---------------------------

[nbin, nlat, nlon, nset] = size(tbtab);
tx = zeros(nbin, nset);
for k = 1 : nset
  for j = 1 : nlon
    for i = 1 : nlat
      tx(:,k) = tx(:,k) + tbtab(:,i,j,k);
    end
  end
  tx(:,k) = real(log(tx(:,k)));
end

figure(4); clf
yax = (dnum - datenum([2002,1,1])) / 365 + 2002;

pcolor(yax, tbins, tx)
shading flat
c = colorbar;
c.Label.String = 'log ( bin count )';

%   % plot a window channel map
%   tstr = 'pdf test 310-340K';
%   map_test = squeeze(sum(tbmap(56:71,:,:)));  % 310-340 K
%   tstr = 'pdf test 200-230K';
%   map_test = squeeze(sum(tbmap(1:16,:,:)));   % 200-230 K

%   % plot a an SST map
%   tstr = 'pdf sst test 300-315K';
%   map_test = squeeze(sum(tbmap(33:43,:,:)));  % 300-310 K
%   map_test = squeeze(sum(tbmap(33:48,:,:)));  % 300-315 K
%   map_test = squeeze(sum(tbmap(4:6,:,:)));    % 271-273 K


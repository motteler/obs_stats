%
% airs_pdfs - AIRS multi-year moving PDFs
%

addpath airs_pdfs
addpath /asl/packages/ccast/motmsc/time

% initialize tabulations
dlist = [];  % day-of-year list
ynum = [];   % fractional year number
dnum = [];   % matlab datenum obs times
tbin = [];   % Tb bin x day table

% load annual tabulations
for year = 2002 : 2017
  d1 = load(sprintf('airs902y%d', year));
  dlist = [dlist, d1.dlist];
  ynum = [ynum, doy2ynum(d1.year, d1.dlist)];
  dnum = [dnum, datenum([d1.year, 1, 1]) + d1.dlist];
  tbin = [tbin, d1.tbin];
end

% Tb bin midpoints
tmid = d1.tmid;

% drop tbin Tb extremes
[m, n] = size(tbin);
ix = 21 : m - 21;
tbin = tbin(ix,:);
tmid = tmid(ix);
[m, n] = size(tbin);

% set up the moving PDF
  k1 = 1 * 16;           % half moving PDF span
% k1 = 182;              % half moving PDF span
k2 = 2 * k1;           % full moving PDF span
k3 = n - k2 + 1;       % total obs minus PDF span wings
nbin2 = zeros(1, k3);  % moving tabulation obs count
tbin2 = zeros(m, k3);  % moving PDF tabulation

% loop on moving tabulation bins
for i = k1+1 : n-k1+1
  j1 = i - k1;
  j2 = i-k1 : i+k1-1;
  tbin2(:, j1) = sum(tbin(:, j2), 2);
  nbin2(j1) = sum(tbin2(:, j1));
end

% year number subset to match tbin2
ynum2 = ynum(k1+1 : n-k1+1);
dnum2 = dnum(k1+1 : n-k1+1);

% normalize tbin3 to 1
tbin3 = tbin2 ./ nbin2;

% difference from mean
tmean = mean(tbin3, 2);
tdif3 = tbin3 - tmean;
trel3 = (tbin3 - tmean) ./ tmean;

% integrate over Tb bins
[m, n] = size(tdif3);
ttmp = tbin3 .* (tmid(:) * ones(1,n));
tint = sum(ttmp);

% fit to weighted average
% p1 = polyfit(ynum2, tint, 3);
% tfit = polyval(p1, ynum2);

% simple moving average
% [mavg, iavg] = moving_avg(tint, 2);    % 4-day
  [mavg, iavg] = moving_avg(tint, 182);  % 1 year
% [mavg, iavg] = moving_avg(tint, 364);  % 2 year

% save data snapshot
% clear d1
% save(sprintf('airs_pdfs_%d', k2))

figure(1); clf
% pcolor(ynum2, tmid, tbin3)
pcolor(ynum2, tmid, tdif3)
title(sprintf('902 cm-1 %d-day PDF difference from mean', k2))
ylabel('Tb bins, K')
xlabel('year')
% caxis([-3e-3, 3e-3])
% caxis([-2e-3, 2e-3])
shading flat
colorbar

figure(2); clf
dax = datetime(dnum2, 'ConvertFrom', 'datenum');
plot(dax, tint, dax(iavg), mavg);
title(sprintf('902 cm-1 %d-day PDF integrated Tb', k2))
legend('integrated Tb', '1 yr moving avg', ...
       'location', 'northwest')
ylabel('Tb, K')
xlabel('year')
grid on; zoom on


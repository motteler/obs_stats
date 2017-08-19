%
% airs_pdf - compare successive AIRS years
%

addpath airs_pdfs
addpath /asl/packages/ccast/motmsc/time

% load annual tabulations
a08 = load('airs902y2008');
a09 = load('airs902y2009');
a10 = load('airs902y2010');
a11 = load('airs902y2011');
a12 = load('airs902y2012');
a13 = load('airs902y2013');
a14 = load('airs902y2014');
a15 = load('airs902y2015');
a16 = load('airs902y2016');

% concatenate day-of-year lists
dlist = [a08.dlist, a09.dlist, a10.dlist, ...
         a11.dlist, a12.dlist, a13.dlist, ...
         a14.dlist, a15.dlist, a16.dlist];

% concatenate Tb bins
tbin = [a08.tbin, a09.tbin, a10.tbin, ...
        a11.tbin, a12.tbin, a13.tbin, ...
        a14.tbin, a15.tbin, a16.tbin];

% concatenate "year number" lists
ynum = [doy2ynum(a08.year, a08.dlist), ...
        doy2ynum(a09.year, a09.dlist), doy2ynum(a10.year, a10.dlist), ...
        doy2ynum(a11.year, a11.dlist), doy2ynum(a12.year, a12.dlist), ...
        doy2ynum(a13.year, a13.dlist), doy2ynum(a14.year, a14.dlist), ...
        doy2ynum(a15.year, a15.dlist), doy2ynum(a16.year, a16.dlist)];

% Tb bin specs
tmid = a16.tmid;
tind = a16.tind;

% drop tbin Tb extremes
[m, n] = size(tbin);
ix = 21 : m - 21;
tbin = tbin(ix,:);
tmid = tmid(ix);
tind = tind(ix);
[m, n] = size(tbin);

% set up the moving PDF
k1 = 1 * 16;           % half moving PDF span
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

% median for typical obs count
med2 = median(nbin2);

% normalize tbin3 to median
% tbin3 = med2 * tbin2 ./ nbin2;

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
p1 = polyfit(ynum2, tint, 3);
tfit = polyval(p1, ynum2);

figure(1); clf
pcolor(ynum2, tmid, tdif3)
title(sprintf('902 cm-1 %d-day PDF difference from mean', k2))
ylabel('Tb bins, K')
xlabel('year')
% caxis([-3e-3, 3e-3])
% caxis([-2e-3, 2e-3])
shading flat
colorbar

figure(2); clf
plot(ynum2, tint, ynum2, tfit);
title(sprintf('902 cm-1 %d-day PDF integrated Tb', k2))
legend('integrated obs', 'linear fit', 'location', 'northwest')
ylabel('Tb, K')
xlabel('year')
grid on; zoom on

return  
% odds and ends below...

% p1 = polyfit(ynum2, sum(tdif3), 1)
% plot(ynum2, sum(tdif3), ynum2, polyval(p1, ynum2))

% p1 = polyfit(ynum2, sum(trel3), 1)
% plot(ynum2, sum(trel3), ynum2, polyval(p1, ynum2))

figure(2); clf
pcolor(ynum2, tmid, trel3)
title(sprintf('AIRS %d-day PDF relative difference from mean', k2))
ylabel('Tb bins, K')
xlabel('year')
caxis([-1, 1]); 
shading flat
colorbar

% range check
% iOK =  0.95 * med2 < nbin2 & nbin2 <  1.05 * med2;

% datetime plot index
% dax = datetime(ylist2, ones(1, length(ylist2)), dlist2);

% basic PDF
figure(2); clf
pcolor(tbin3)
title('AIRS moving PDF')
ylabel('Tb bins, K')
xlabel('days')
shading flat
colorbar


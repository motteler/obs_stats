%
% airs_trends -- 16-day maps to lat x lon x time trends
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
% moving average table 1, etc for 2
%   nsp1  - moving window span = 2*nsp+1
%   nset1 - number of 16-day sets = nset-2*nsp1
%   dnum1 - nset1 vector, moving window datenum index
%   nmov1 - nchan x nlat x nlon x nset1, bin count
%   umov1 - nchan x nlat x nlon x nset1, bin mean
%   vmov1 - nchan x nlat x nlon x nset1, bin var
%
% zonal averages for mv avg table 1
%   LBN, LBS - N and S latitude bounds
%   nzone1 - nchan x nset1 zonal count
%   uzone1 - nchan x nset1 zonal mean
%   vzone1 - nchan x nset1 zonal var
%
% polynomial fits for mv avg table 1
%   pd - polynomial degree, 1 = linear
%   poly1 - nlat x nlon x pd+1, poly coeff's
%   p1_res_mean - nlat x nlon, poly residual mean
%   p1_res_std  - nlat x nlon, poly residual std
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

%----------------------------------------------
% moving average and variance over 16-day maps
%----------------------------------------------
% moving average set 1
nsp1 = 11;              % moving win half-span
nset1 = nset-2*nsp1;    % number of 16-day sets
dnum1 = nan(1, nset1);  % datenums for set midpoints
nmov1 = nan(nchan, nlat, nlon, nset1); % bin counts
umov1 = nmov1; vmov1 = umov1;  % bin mean and variance

for i = nsp1+1 : nset-nsp1;   % center of moving window
  n1 = ntmp(:,:,:,i-nsp1);    % first val in current window
  u1 = utab(:,:,:,i-nsp1);
  v1 = vtab(:,:,:,i-nsp1);
  for j = i-nsp1+1 : i+nsp1   % index in current window
    n2 = ntmp(:,:,:,j);
    u2 = utab(:,:,:,j);
    v2 = vtab(:,:,:,j);
    [n1,u1,v1] = merge_var(n1,u1,v1,n2,u2,v2);
  end
  nmov1(:,:,:,i-nsp1) = n1;
  umov1(:,:,:,i-nsp1) = u1;
  vmov1(:,:,:,i-nsp1) = v1;
  dnum1(i-nsp1) = dnum(i);
% uX = mean(utab(:,:,:,i-nsp1:i+nsp1),4);
% [nX,uX,vX] = merge_tree(ntmp(:,:,:,i-nsp1:i+nsp1), ...
%                         utab(:,:,:,i-nsp1:i+nsp1), ...
%                         vtab(:,:,:,i-nsp1:i+nsp1));
% rms(u1(:) - uX(:)) / rms(uX(:))
% rms(v1(:) - vX(:)) / rms(vX(:))
end

% moving average set 2
nsp2 = 34;              % moving win half-span
nset2 = nset-2*nsp2;    % number of 16-day sets
dnum2 = nan(1, nset2);  % datenums for set midpoints
nmov2 = nan(nchan, nlat, nlon, nset2); % bin counts
umov2 = nmov2; vmov2 = umov2;  % bin mean and variance

for i = nsp2+1 : nset-nsp2;   % center of moving window
  n1 = ntmp(:,:,:,i-nsp2);    % first val in current window
  u1 = utab(:,:,:,i-nsp2);
  v1 = vtab(:,:,:,i-nsp2);
  for j = i-nsp2+1 : i+nsp2   % index in current window
    n2 = ntmp(:,:,:,j);
    u2 = utab(:,:,:,j);
    v2 = vtab(:,:,:,j);
    [n1,u1,v1] = merge_var(n1,u1,v1,n2,u2,v2);
  end
  nmov2(:,:,:,i-nsp2) = n1;
  umov2(:,:,:,i-nsp2) = u1;
  vmov2(:,:,:,i-nsp2) = v1;
  dnum2(i-nsp2) = dnum(i);
end

% datetime axes for plots 
dax = datetime(dnum, 'ConvertFrom', 'datenum');
dax1 = datetime(dnum1, 'ConvertFrom', 'datenum');
dax2 = datetime(dnum2, 'ConvertFrom', 'datenum');

%---------------------------------------
% mean and variance over latitude bands
%---------------------------------------
% specify N and S boundaries
% LBN = 90; LBS = -90;
  LBN = 50; LBS = 20;
% LBN = 90; LBS = 73;
Lix = find(LBS <= latB & latB < LBN);
nbin = length(Lix)*nlon;

nsub1 = nmov1(:, Lix, :, :);
usub1 = umov1(:, Lix, :, :);
vsub1 = vmov1(:, Lix, :, :);

nsub1 = reshape(nsub1, nchan, nbin, nset1);
usub1 = reshape(usub1, nchan, nbin, nset1);
vsub1 = reshape(vsub1, nchan, nbin, nset1);

nzone1 = zeros(nchan, nset1);
uzone1 = zeros(nchan, nset1);
vzone1 = zeros(nchan, nset1);

for i = 1 : nset1
  [nzone1(:,i), uzone1(:,i), vzone1(:,i)] = ...
     merge_tree(nsub1(:,:,i), usub1(:,:,i), vsub1(:,:,i));
end

% uavg1 = squeeze(mean(usub1, 2));
% rms(uavg1(:) - uzone1(:))/rms(uzone1(:))

nsub2 = nmov2(:, Lix, :, :);
usub2 = umov2(:, Lix, :, :);
vsub2 = vmov2(:, Lix, :, :);

nsub2 = reshape(nsub2, nchan, nbin, nset2);
usub2 = reshape(usub2, nchan, nbin, nset2);
vsub2 = reshape(vsub2, nchan, nbin, nset2);

nzone2 = zeros(nchan, nset2);
uzone2 = zeros(nchan, nset2);
vzone2 = zeros(nchan, nset2);

for i = 1 : nset2
  [nzone2(:,i), uzone2(:,i), vzone2(:,i)] = ...
     merge_tree(nsub2(:,:,i), usub2(:,:,i), vsub2(:,:,i));
end

% sample latitude band plot
ic = 3;  % chan index
% uzone1 = rad2bt(vlist, uzone1);
% uzone2 = rad2bt(vlist, uzone2);
figure(1)
subplot(2,1,1)
plot(dax1, uzone1(ic,:), dax2, uzone2(ic,:), 'linewidth', 2)
tstr = 'AIRS %d to %d deg lat band, %.2f cm-1';
title(sprintf(tstr, LBS, LBN, vlist(ic)))
legend('1 yr mv avg', '3 yr mv avg', 'location', 'best')
ylabel('BT (K)')
grid on
subplot(2,1,2)
plot(dax1, sqrt(vzone1(ic,:)), dax2, sqrt(vzone2(ic,:)), 'linewidth', 2)
legend('1 yr mv std', '3 yr mv std')
xlabel('year')
ylabel('BT (K)')
grid on

%---------------------------------
% poly fit to moving average bins
%---------------------------------
% ic = 3;  % chan index
pd = 1;  % poly degree
poly1 = NaN(nlat, nlon, pd+1);
poly2 = NaN(nlat, nlon, pd+1);

p1_res_mean = NaN(nlat, nlon);
p2_res_mean = NaN(nlat, nlon);
p1_res_std = NaN(nlat, nlon);
p2_res_std = NaN(nlat, nlon);

xtmp1 = dnum1';
xtmp2 = dnum2';

for i = 1 : nlat
  for j = 1 : nlon
    ytmp1 = squeeze(umov1(ic, i, j, :));
    ytmp2 = squeeze(umov2(ic, i, j, :));
    ptmp1 = polyfit(xtmp1, ytmp1, pd);
    ptmp2 = polyfit(xtmp2, ytmp2, pd);

    poly1(i, j, :) = ptmp1;
    poly2(i, j, :) = ptmp2;

    ztmp1 = polyval(ptmp1, xtmp1);
    ztmp2 = polyval(ptmp2, xtmp2);

    p1_res_mean(i, j) = mean(ztmp1 - ytmp1);
    p2_res_mean(i, j) = mean(ztmp2 - ytmp2);
    p1_res_std(i, j) = std(ztmp1 - ytmp1, 0);
    p2_res_std(i, j) = std(ztmp2 - ytmp2, 0);

  end
end

%------------------
% global trend map
%------------------
tstr = sprintf('AIRS %.2f cm-1 15 year trend', vlist(ic));
equal_area_map(2, latB, lonB, 365 * poly1(:,:,1), tstr);
load llsmap5
colormap(llsmap5)
caxis([-0.2, 0.2])
c = colorbar;
c.Label.String = 'degrees (K)/year';

return

%------------------
% single bin stats
%------------------
% ic = 3;   % chan index
ilat = 40;  % lat bin index
ilon = 46;  % lon bin index

uu1 = squeeze(umov1(ic, ilat, ilon, :));
uu2 = squeeze(umov2(ic, ilat, ilon, :));

vv1 = squeeze(vmov1(ic, ilat, ilon, :));
vv2 = squeeze(vmov2(ic, ilat, ilon, :));

zz1 = polyval(squeeze(poly1(ilat, ilon, :)), xtmp1);
zz2 = polyval(squeeze(poly2(ilat, ilon, :)), xtmp2);

slat = (latB(ilat) + latB(ilat+1)) / 2;
slon = (lonB(ilon) + lonB(ilon+1)) / 2;

figure(3); clf
subplot(2,1,1)
plot(dax1, uu1, dax2, uu2, 'linewidth', 2)
tstr = 'AIRS bin (%.1f, %.1f) %.2f cm-1';
title(sprintf(tstr, slat, slon, vlist(ic)))
legend('1 yr mv avg', '3 yr mv avg', 'location', 'best')
ylabel('BT (K)')
grid on
subplot(2,1,2)
plot(dax1, zz1, dax2, zz2, 'linewidth', 2)
legend('1 yr fit', '3 yr fit', 'location', 'best')
xlabel('year')
ylabel('BT (K)')
grid on

uux = squeeze(utab(ic, ilat, ilon, :));
uu1 = squeeze(umov1(ic, ilat, ilon, :));

vvx = squeeze(vtab(ic, ilat, ilon, :));
vv1 = squeeze(vmov1(ic, ilat, ilon, :));

figure(4); clf
subplot(2,1,1)
plot(dax, uux, dax1, uu1, 'linewidth', 2)
tstr = 'AIRS bin (%.1f, %.1f) %.2f cm-1';
title(sprintf(tstr, slat, slon, vlist(ic)))
legend('16-day sets', '1 yr mv avg', 'location', 'best')
ylabel('BT (K)')
grid on
subplot(2,1,2)
plot(dax, sqrt(vvx), dax1, sqrt(vv1), 'linewidth', 2)
legend('16-day std', '1 yr mv std', 'location', 'best')
xlabel('year')
ylabel('BT (K)')
grid on

return

figure(4); clf
subplot(2,1,1)
plot(dax1, uu1, dax2, uu2, 'linewidth', 2)
tstr = 'AIRS bin (%.1f, %.1f) %.2f cm-1';
title(sprintf(tstr, slat, slon, vlist(ic)))
legend('1 yr mv avg', '3 yr mv avg', 'location', 'best')
ylabel('BT (K)')
grid on
subplot(2,1,2)
plot(dax1, vv1, dax2, vv2, 'linewidth', 2)
legend('1 yr mv var', '3 yr mv var', 'location', 'best')
xlabel('year')
ylabel('BT (K)')
grid on

% % plot quadratic coeff's, assumes pd = 2
% tstr = sprintf('AIRS LW %d to %d BT "a" (ax^2+bx+c)', y1, y2);
% equal_area_map(1, d1.latB1, d1.lonB1, M1_poly(:,:,1), tstr);
% colormap(llsmap5)
% caxis([-0.2, 0.2])
% 
% tstr = sprintf('AIRS LW %d to %d BT "b" (ax^2+bx+c)', y1, y2);
% equal_area_map(2, d1.latB1, d1.lonB1, M1_poly(:,:,2), tstr);
% colormap(llsmap5)
% caxis([-3, 3])
% 
% tstr = sprintf('AIRS LW %d to %d BT "c" (ax^2+bx+c)', y1, y2);
% equal_area_map(3, d1.latB1, d1.lonB1, M1_poly(:,:,3), tstr);
% colormap(parula)


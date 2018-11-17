%
% airs_map_stat -- 16-day maps to lat x lon x time
%
%    AIRS "c3" channel set
%  1   699.380    250 mb peak
%  2   746.967    CO2 proxy
%  3   902.040    LW window
%  4  1231.330    MW window
%  5  1613.862    400 mb peak
%  6  2384.252    250 mb peak
%  7  2500.601    SW window
%

addpath ../source
addpath /asl/packages/ccast/source

%-------------------------------------------
% combine annual tabulations of 16-day maps
%-------------------------------------------

dnum = []; % time index as datenums
utab = []; % nchan x nlat x nlon x time bin mean
vtab = []; % nchan x nlat x nlon x time bin variance
ntab = []; % nchan x nlat x nlon x time bin count

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

%----------------------------------------------
% moving average and variance over 16-day maps
%----------------------------------------------

% navg = 2*nsp+1, navg x 16 day moving average
nsp1 = 11;
dnum1 = nan(1, nset-2*nsp1); 
nmov1 = nan(nchan, nlat, nlon, nset-2*nsp1);
umov1 = nmov1; vmov1 = umov1;

for i = nsp1+1 : nset-nsp1;
  for j = i-nsp1 : i+nsp1-1
%   [i,j,j+1]
    if j == i-nsp1
      n1 = ntmp(:,:,:,j); n2 = ntmp(:,:,:,j+1);
      u1 = utab(:,:,:,j); u2 = utab(:,:,:,j+1);
      v1 = vtab(:,:,:,j); v2 = vtab(:,:,:,j+1);
      [n1,u1,v1] = merge_var(n1,u1,v1,n2,u2,v2);
    else
      n2 = ntmp(:,:,:,j+1);
      u2 = utab(:,:,:,j+1);
      v2 = vtab(:,:,:,j+1);
      [n1,u1,v1] = merge_var(n1,u1,v1,n2,u2,v2);
    end
    nmov1(:,:,:,i-nsp1) = n1;
    umov1(:,:,:,i-nsp1) = u1;
    vmov1(:,:,:,i-nsp1) = v1;
    dnum1(i-nsp1) = dnum(i);
  end
end

nsp2 = 34;
dnum2 = nan(1, nset-2*nsp2); 
nmov2 = nan(nchan, nlat, nlon, nset-2*nsp2);
umov2 = nmov2; vmov2 = umov2;
for i = nsp2+1 : nset-nsp2;
  for j = i-nsp2 : i+nsp2-1
%   [i,j,j+1]
    if j == i-nsp2
      n1 = ntmp(:,:,:,j); n2 = ntmp(:,:,:,j+1);
      u1 = utab(:,:,:,j); u2 = utab(:,:,:,j+1);
      v1 = vtab(:,:,:,j); v2 = vtab(:,:,:,j+1);
      [n1,u1,v1] = merge_var(n1,u1,v1,n2,u2,v2);
    else
      n2 = ntmp(:,:,:,j+1);
      u2 = utab(:,:,:,j+1);
      v2 = vtab(:,:,:,j+1);
      [n1,u1,v1] = merge_var(n1,u1,v1,n2,u2,v2);
    end
    nmov2(:,:,:,i-nsp2) = n1;
    umov2(:,:,:,i-nsp2) = u1;
    vmov2(:,:,:,i-nsp2) = v1;
    dnum2(i-nsp2) = dnum(i);
  end
end

% plot(dnum1-dnum1(1), squeeze(vmov1(1,1,1,:)))

%---------------------------------------
% mean and variance over latitude bands
%---------------------------------------

% LBN = 50; LBS = 20;
  LBN = 90; LBS = 73;
Lix = find(LBS <= c1.latB & c1.latB < LBN);
usub1 = umov1(:, Lix, :, :);
usub1 = reshape(usub1, nchan, length(Lix)*nlon, length(dnum1));
uavg1 = squeeze(mean(usub1, 2));

usub2 = umov2(:, Lix, :, :);
usub2 = reshape(usub2, nchan, length(Lix)*nlon, length(dnum2));
uavg2 = squeeze(mean(usub2, 2));

%--

dax1 = datetime(dnum1, 'ConvertFrom', 'datenum');
dax2 = datetime(dnum2, 'ConvertFrom', 'datenum');

figure(1)
ic = 1;
plot(dax1, uavg1(ic,:), dax2, uavg2(ic,:), 'linewidth', 2)
  title('AIRS 73N to 90N, 699.38 cm-1, 250 mb')
% title('AIRS 20N to 50N, 699.38 cm-1, 250 mb')
legend('1 yr mv avg', '3 yr mv avg')
xlabel('year')
ylabel('BT (K)')
grid on

figure(2)
ic = 5;
plot(dax1, uavg1(ic,:), dax2, uavg2(ic,:), 'linewidth', 2)
  title('AIRS 73N to 90N, 1613.86 cm-1, 400 mb')
% title('AIRS 20N to 50N, 1613.86 cm-1, 400 mb')
legend('1 yr mv avg', '3 yr mv avg', 'location', 'southeast')
xlabel('year')
ylabel('BT (K)')
grid on

figure(3)
ic = 3;
plot(dax1, uavg1(ic,:), dax2, uavg2(ic,:), 'linewidth', 2)
  title('AIRS 73N to 90N, 902.04 cm-1, window')
% title('AIRS 20N to 50N, 902.04 cm-1, window')
legend('1 yr mv avg', '3 yr mv avg', 'location', 'southeast')
xlabel('year')
ylabel('BT (K)')
grid on

return

%-------------------
% old trending code
%-------------------

% linear or polynomial fit
M1_poly = NaN(nlat, nlon, pd+1);
M2_poly = NaN(nlat, nlon, pd+1);
M1_res_mean = NaN(nlat, nlon);
M2_res_mean = NaN(nlat, nlon);
M1_res_std = NaN(nlat, nlon);
M2_res_std = NaN(nlat, nlon);
% xtmp = (1:ny)';   % fit annual data
  xtmp = (1:ny-1)'; % fit 2-yr mv avg
for i = 1 : nlat
  for j = 1 : nlon
%   ytmp1 = squeeze(M1_tab(i, j, :)); % fit annual data
%   ytmp2 = squeeze(M2_tab(i, j, :));
    ytmp1 = squeeze(M1_mv2(i, j, :)); % fit 2-yr mv avg 
    ytmp2 = squeeze(M2_mv2(i, j, :));
    ptmp1 = polyfit(xtmp, ytmp1, pd);
    ptmp2 = polyfit(xtmp, ytmp2, pd);
    M1_poly(i, j, :) = ptmp1;
    M2_poly(i, j, :) = ptmp2;
    ztmp1 = polyval(ptmp1, xtmp);
    ztmp2 = polyval(ptmp2, xtmp);
    M1_res_mean(i, j) = mean(ztmp1 - ytmp1);
    M2_res_mean(i, j) = mean(ztmp2 - ytmp2);
    M1_res_std(i, j) = std(ztmp1 - ytmp1, 0);
    M2_res_std(i, j) = std(ztmp2 - ytmp2, 0);
  end
end

% annual mean and variance
M1_tab_std = std(M1_tab, 0, 3);
tstr = 'annual summary std, 2003-2017';
equal_area_map(1, d1.latB1, d1.lonB1, M1_tab_std, tstr);
caxis([0.25, 5.25])

M1_mv2_std = std(M1_mv2, 0, 3);
tstr = 'annual summary std, 2 yr mv avg';
equal_area_map(2, d1.latB1, d1.lonB1, M1_mv2_std, tstr);
caxis([0.25, 5.25])

% plot basic slope fits, assumes pd = 1
tstr = 'AIRS LW BT 2 yr mv avg slope';
equal_area_map(3, d1.latB1, d1.lonB1, M1_poly(:,:,1), tstr);
load llsmap5
colormap(llsmap5)
caxis([-0.35, 0.35])

tstr = 'AIRS SW BT 2 yr mv avg slope';
equal_area_map(4, d1.latB1, d1.lonB1, M2_poly(:,:,1), tstr);
colormap(llsmap5)
caxis([-0.35, 0.35])

tstr = 'std of residual from LW linear fit';
equal_area_map(5, d1.latB1, d1.lonB1, M1_res_std, tstr);


% % plot linear and quadratic break out, assumes pd = 2
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


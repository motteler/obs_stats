%
% airs_diff_map -- annual maps to lat x lon x year table
%
% typical variables for LW window tests
%   M1_tab  - nlat x nlon x ny, annual BT means
%   S1_tab  - nlat x nlon x ny, annual BT stds
%   M1_mv2  - nlat x nlon x ny-1, 2-year mv avg of M1_tab
%   M1_poly - nlat x nlon x pd+1, polynomial fit coeff's
%   M1_res_mean - nlat x nlon, poly fit residual mean
%   M1_res_std  - nlat x nlon, poly fit residual std
%

% test parameters
y1 = 2003;  % first year
y2 = 2017;  % last year
nlat = 48;  % lat bins (from annual tabulation)
nlon = 90;  % lon bins (from annual tabulation)
pd = 1;     % polynomial degree

% tabulate maps by year
ny = y2 - y1 + 1;
M1_tab = NaN(nlat, nlon, ny);
M2_tab = NaN(nlat, nlon, ny);
S1_tab = NaN(nlat, nlon, ny);
S2_tab = NaN(nlat, nlon, ny);

% loop on years
for iy = 1 : ny
  d1 = load(sprintf('airs_%d_stats', iy+y1-1));
  M1_tab(:, :, iy) = d1.M1;
  M2_tab(:, :, iy) = d1.M2;
  S1_tab(:, :, iy) = d1.S1;
  S2_tab(:, :, iy) = d1.S2;
  fprintf(1, '.')
end
fprintf(1, '\n')

% 2-year moving average
M1_mv2 = NaN(nlat, nlon, ny-1);
M2_mv2 = NaN(nlat, nlon, ny-1);
for i = 1 : ny - 1
  M1_mv2(:, :, i) = (M1_tab(:, :, i) + M1_tab(:, :, i+1)) / 2;
  M2_mv2(:, :, i) = (M2_tab(:, :, i) + M2_tab(:, :, i+1)) / 2;
end

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


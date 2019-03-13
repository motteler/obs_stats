%
% npp_n20_fov_map - FOV breakouts for NPP and N20 equal area maps
%

addpath ../source
addpath /asl/packages/ccast/motmsc/utils
addpath ../obs_16day_cris_c4

nLat = 24;  dLon = 4;

dlist = [];
M1 = []; W1= []; N1 = [];
M2 = []; W2= []; N2 = [];

iFOV = 5;
ichan = 4;
  slist = 15;               % most complete set
% slist = [6 10 12 14 15];  % relatively complete sets
year = 2018;

% loop on 16-day sets
for i = slist
  c1 = load(sprintf('NPP_c05y%ds%0.2d.mat', year, i));
  c2 = load(sprintf('N20_c05y%ds%0.2d.mat', year, i));

  % FOV subsetting
  ix1 = c1.fov_list == iFOV;
  ix2 = c2.fov_list == iFOV;

  % asc/dec subsetting; asc = 1 is night, asc = 0 is day
% ix1 = ~logical(c1.asc_list);
% ix2 = ~logical(c2.asc_list);

  % no subsetting
% ix1 = logical(ones(length(c1.lat_list),1));
% ix2 = logical(ones(length(c2.lat_list),1));
 
  lat_list1 = c1.lat_list(ix1); 
  lat_list2 = c2.lat_list(ix2); 
  lon_list1 = c1.lon_list(ix1); 
  lon_list2 = c2.lon_list(ix2); 
  rad_list1 = c1.rad_list(:, ix1);
  rad_list2 = c2.rad_list(:, ix2);

  bt_list1 = rad2bt(c1.vlist(ichan), rad_list1(ichan,:));
  bt_list2 = rad2bt(c2.vlist(ichan), rad_list2(ichan,:));

  [latB1, lonB1, M1, W1, N1] = ...
    equal_area_var(nLat, dLon, lat_list1, lon_list1, bt_list1, M1, W1, N1);

  [latB2, lonB2, M2, W2, N2] = ...
    equal_area_var(nLat, dLon, lat_list2, lon_list2, bt_list2, M2, W2, N2);

  dlist = [dlist, c1.dlist];
  fprintf(1, '.')
end
fprintf(1, '\n')

S1 = sqrt(W1 ./ (N1 - 1));
S2 = sqrt(W2 ./ (N2 - 1));

sol_list1 = c1.sol_list(ix1);
fprintf(1,'mean solar zenith angle %.2f\n', mean(sol_list1))
fprintf(1, 'FOV %d, freq %.2f cm-1, ', iFOV, c1.vlist(ichan))
fprintf(1, 'set list: '); fprintf(1, '%d ', slist); fprintf(1, '\n')

tstr = sprintf('NPP FOV %d eq area bin BT mean', iFOV);
equal_area_map(1, latB1, lonB1, M1, tstr);

tstr = sprintf('NPP FOV %d eq area bin BT std', iFOV);
equal_area_map(2, latB1, lonB1, S1, tstr);

tstr = 'NPP minus N20 FOV %d mean, %d doy %d-%d';
tstr = sprintf(tstr, iFOV, c1.year, dlist(1), dlist(end));
equal_area_map(3, latB1, lonB1, M1 - M2, tstr);
caxis([-1, 1])
load llsmap5
colormap(llsmap5)


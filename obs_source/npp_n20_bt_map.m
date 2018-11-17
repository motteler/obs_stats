%
% npp_n20_bt_map - compare NPP and N20 equal area BT maps
%

addpath ../source
addpath /asl/packages/ccast/motmsc/utils
% addpath ../obs_16day_mix_v1
addpath ../obs_16day_cris_c4

nLat = 24;  dLon = 4;

dlist = [];
M1 = []; W1= []; N1 = [];
M2 = []; W2= []; N2 = [];

% loop on 16-day sets
year = 2018;
% for i = [5:7 10:19]
for i = 10
  c1 = load(sprintf('NPP_c04y%ds%0.2d.mat', year, i));
  c2 = load(sprintf('N20_c04y%ds%0.2d.mat', year, i));

  % asc/dec or other subsetting
  % CrIS asc = 1 is night, asc = 0 is day
% ix1 = ~logical(c1.asc_list);
% ix2 = ~logical(c2.asc_list);
  ix1 = logical(ones(length(c1.lat_list),1));
  ix2 = logical(ones(length(c2.lat_list),1));
  lat_list1 = c1.lat_list(ix1); 
  lon_list1 = c1.lon_list(ix1); 
  rad_list1 = c1.rad_list(:, ix1);
  lat_list2 = c2.lat_list(ix2); 
  lon_list2 = c2.lon_list(ix2); 
  rad_list2 = c2.rad_list(:, ix2);

  bt_list1 = rad2bt(c1.vlist(2), rad_list1(2,:));
  bt_list2 = rad2bt(c2.vlist(2), rad_list2(2,:));

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
mean(sol_list1)

tstr = 'CrIS NPP mean BT equal area bins';
equal_area_map(1, latB1, lonB1, M1, tstr);

tstr = 'CrIS NPP std BT equal area bins';
equal_area_map(2, latB1, lonB1, S1, tstr);

tstr = 'CrIS J1 minus NPP mean BT equal area bins, %d doy %d-%d';
tstr = sprintf(tstr, c1.year, dlist(1), dlist(end));
equal_area_map(3, latB1, lonB1, M2 - M1, tstr, [-6, 6]);

% tstr = 'CrIS J1 minus NPP std BT equal area bins';
% equal_area_map(4, latB2, lonB2, S2 - S1, tstr);


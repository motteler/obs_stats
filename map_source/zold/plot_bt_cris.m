%
% plot_bt_cris - quick sanity check of BT map data
%

addpath source
addpath map_source
addpath /asl/packages/ccast/motmsc/time

% d1 = load('testX_npp_902');
% d2 = load('testX_j1_902');

% d1 = load('testY_npp_1231');
% d2 = load('testY_j1_1231');

  d1 = load('testY_npp_1653');
  d2 = load('testY_j1_1653');

nLat = 24;  dLon = 4;

[latB1, lonB1, gtot1, gavg1] = ...
   equal_area_bins(nLat, dLon, d1.lat_list, d1.lon_list, d1.Tb_list);

[latB2, lonB2, gtot2, gavg2] = ...
   equal_area_bins(nLat, dLon, d2.lat_list, d2.lon_list, d2.Tb_list);

gdiff = gavg2 - gavg1;

tstr = 'CrIS NPP mean BT';
equal_area_map(1, latB1, lonB1, gavg1, tstr);

tstr = 'CrIS J1 mean BT';
equal_area_map(2, latB1, lonB1, gavg2, tstr);

tstr = 'CrIS J1 minus NPP mean BT';
equal_area_map(3, latB1, lonB1, gdiff, tstr);


%
% map_Tb_deom - equal area Tb map
%

addpath source
addpath /asl/packages/ccast/motmsc/time

  d1 = load('airs902y2016q8.mat');
  d2 = load('cris902y2016q8.mat');

% nLat = 20;  dLon = 6;
  nLat = 24;  dLon = 4;

  fprintf(1, 'calculating AIRS equal area bins...\n')
  [latB1, lonB1, gtot1, gavg1] = ...
      equal_area_bins(nLat, dLon, d1.lat_list, d1.lon_list, d1.Tb_list);

  fprintf(1, 'calculating CrIS equal area bins...\n')
  [latB2, lonB2, gtot2, gavg2] = ...
      equal_area_bins(nLat, dLon, d2.lat_list, d2.lon_list, d2.Tb_list);

  tstr = 'AIRS mean equal area Tb bins, %d doy %d-%d';
  tstr = sprintf(tstr, d1.year, d1.dlist(1), d1.dlist(end));
  equal_area_map(1, latB1, lonB1, gavg1, tstr);

  tstr = 'CrIS mean equal area Tb bins, %d doy %d-%d';
  tstr = sprintf(tstr, d2.year, d2.dlist(1), d2.dlist(end));
  equal_area_map(2, latB2, lonB2, gavg2, tstr);

  cax = [-7, 8];
  tstr = 'AIRS minus CrIS mean equal area Tb bins, %d doy %d-%d';
  tstr = sprintf(tstr, d2.year, d2.dlist(1), d2.dlist(end));
  equal_area_map(3, latB2, lonB2, gavg1 - gavg2, tstr, cax);


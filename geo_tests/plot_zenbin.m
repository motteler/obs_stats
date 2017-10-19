%
% plot_zenbin - equal area zenith stats
%

d1 = load('airs_obs_d1s2');
d2 = load('cris_obs_d1s2');

% nLat = 20;  dLon = 6;
  nLat = 24;  dLon = 4;
[latB1, lonB1, gtot1, gavg1] = ...
    equal_area_bins(nLat, dLon, d1.slat, d1.slon, sec(deg2rad(d1.szen)));

[latB2, lonB2, gtot2, gavg2] = ...
    equal_area_bins(nLat, dLon, d2.slat, d2.slon, sec(deg2rad(d2.szen)));

gdiff = gavg2 - gavg1;

tstr = 'CrIS minus AIRS mean secants';
equal_area_map(1, latB1, lonB1, gdiff, tstr);

tstr = 'AIRS mean secants';
equal_area_map(2, latB1, lonB1, gavg1, tstr);

tstr = 'CrIS mean secants'
equal_area_map(3, latB1, lonB1, gavg2, tstr);


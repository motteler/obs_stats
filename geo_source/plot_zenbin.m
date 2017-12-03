%
% plot_zenbin - equal area satellite zenith stats
%

addpath source
addpath geo_data

d1 = load('airs_geo_d1s2');
d2 = load('cris_geo_d1s2');

% % subset by secant of satellite zenith angle
% ix1 = find(sec(deg2rad(d1.szen)) <= 1.8);
% ix2 = find(sec(deg2rad(d2.szen)) <= 1.8);
% d1.slat = d1.slat(ix1);
% d1.slon = d1.slon(ix1);
% d1.szen = d1.szen(ix1);
% d2.slat = d2.slat(ix2);
% d2.slon = d2.slon(ix2);
% d2.szen = d2.szen(ix2);

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
equal_area_map(3, latB2, lonB2, gavg2, tstr);


%
% quick look at 1 Sep 2018
%

d1 = load('airs_geo_t1s1');
d2 = load('cris_geo_t1s1');

% nLat = 20;  dLon = 6;
% nLat = 24;  dLon = 4;
  nLat = 30;  dLon = 4;
[latB1, lonB1, gtot1] = equal_area_bins(nLat, dLon, d1.slat, d1.slon);
[latB2, lonB2, gtot2] = equal_area_bins(nLat, dLon, d2.slat, d2.slon);

gdiff = gtot2 - gtot1;

tstr = 'CrIS minus AIRS one day obs counts';
equal_area_map(1, latB1, lonB1, gdiff, tstr);
caxis([-600, 600])
saveas(gcf, 'cris_minus_airs', 'png')

tstr = 'AIRS one day equal area obs counts';
equal_area_map(2, latB1, lonB1, gtot1, tstr);
caxis([0, 700])
saveas(gcf, 'airs_one_day', 'png')

tstr = 'CrIS one day equal area obs counts';
equal_area_map(3, latB1, lonB1, gtot2, tstr);
caxis([0, 700])
saveas(gcf, 'cris_one_day', 'png')



d1 = load('airs_c2_2003_stats');
d2 = load('airs_c2_2017_stats');

tstr = 'AIRS 746.97 cm-1 BT 2017 minus 2003';
equal_area_map(1, d1.latB1, d1.lonB1, d2.M1 - d1.M1, tstr);
load llsmap5
colormap(llsmap5)
caxis([-5.5, 5.5])
saveas(gcf, 'airs_co2_BT_2017-2003', 'png')

tstr = 'AIRS 2003 746.97 cm-1 BT';
equal_area_map(2, d1.latB1, d1.lonB1, d1.M1, tstr);
saveas(gcf, 'airs_co2_BT_2003', 'png')

tstr = 'AIRS 2017 746.97 cm-1 BT';
equal_area_map(3, d1.latB1, d1.lonB1, d2.M1, tstr);
saveas(gcf, 'airs_co2_BT_2017', 'png')


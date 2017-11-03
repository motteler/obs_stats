%
% plot_hot_LW - LW hot tails and map
%

addpath obs_list_data
addpath /asl/packages/ccast/motmsc/time

% a1 = quint_obs_cat('cris902y2015q1');
a2 = load('airs902y2016');
a1.Tb  = a2.Tb_list;
a1.lat = a2.lat_list;
a1.lon = a2.lon_list;
a1.tai = a2.tai_list;
clear a2

c1 = quint_obs_cat('cris902y2016q1');

na = length(a1.Tb)
nc = length(c1.Tb)

%---------------
% hot histograms
%---------------
figure(1); clf
subplot(2,1,1)
histogram(c1.Tb, 'BinWidth', 1)
set(gca, 'YScale', 'log')
title('CrIS 2016 902 cm-1 hot Tb bins')
ylabel('count')
grid on

subplot(2,1,2)
histogram(a1.Tb, 'BinWidth', 1)
set(gca, 'YScale', 'log')
title('AIRS 2016 902 cm-1 hot Tb bins')
 xlabel('Tb, K')
ylabel('count')
grid on
% saveas(gcf, '2016_hot_LW_hist', 'png')

%--------------
% hot spot map
%--------------
ia = find(a1.Tb > 340);
a1.lat = double(a1.lat(ia));
a1.lon = double(a1.lon(ia));
na = length(ia)

ic = find(c1.Tb > 340);
c1.lat = double(c1.lat(ic));
c1.lon = double(c1.lon(ic));
nc = length(ic)

figure(2); clf
% latlim = [-90, 90];  lonlim = [-180, 180];
  latlim = [-60, 60];  lonlim = [-130, 150];
axesm('mapprojection', 'eqdcylin', ...
      'maplatlimit', latlim, 'maplonlimit', lonlim, ...
      'grid', 'on', 'frame', 'on', 'flinewidth', 1, ...
      'parallellabel', 'on', 'meridianlabel', 'on', ...
      'MLineLocation', 60, 'PLineLocation', 20, ...
      'MLabelParallel', 'south', ...
      'labelformat', 'compass')

plotm(c1.lat, c1.lon, 'og', 'linewidth', 2)
plotm(a1.lat, a1.lon, '+r')
S = shaperead('landareas','UseGeoCoords',true);
geoshow([S.Lat], [S.Lon],'Color','black');
legend('geo', 'cris', 'airs', 'location', 'southwest')
th = title('2016 902 cm-1 Tb greater than 340K');
set(th, 'FontSize', 12')
tightmap
% saveas(gcf, '2016_hot_LW_map', 'png')


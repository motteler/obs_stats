%
% plot_hot_SW - SW hot tails and map
%

addpath obs_list_data
addpath /asl/packages/ccast/motmsc/time

a1 = quint_obs_cat('airs2500y2016q1');
c1 = quint_obs_cat('cris2500y2016q1');

na = length(a1.Tb)
nc = length(c1.Tb)

%----------------
% hot histograms
%----------------
figure(1); clf
subplot(2,1,1)
histogram(c1.Tb, 'BinWidth', 1)
set(gca, 'YScale', 'log')
axis([320, 360, 10, 1e6])
title('CrIS 2016 2500 cm-1 hot Tb bins')
ylabel('count')
grid on

subplot(2,1,2)
histogram(a1.Tb, 'BinWidth', 1)
set(gca, 'YScale', 'log')
axis([320, 360, 10, 1e6])
title('AIRS 2016 2500 cm-1 hot Tb bins')
 xlabel('Tb, K')
ylabel('count')
grid on
% saveas(gcf, '2016_hot_SW_hist', 'png')

%--------------
% hot spot map
%--------------
ia = find(a1.sol > 90 & a1.Tb > 340);
a1.lat = double(a1.lat(ia));
a1.lon = double(a1.lon(ia));
na = length(ia)

ic = find(c1.sol > 90 & c1.Tb > 340);
c1.lat = double(c1.lat(ic));
c1.lon = double(c1.lon(ic));
nc = length(ic)

figure(2); clf
latlim = [-90, 90];  lonlim = [-180, 180];
axesm('mapprojection', 'eqdcylin', ...
      'maplatlimit', latlim, 'maplonlimit', lonlim, ...
      'grid', 'on', 'frame', 'on', 'flinewidth', 1, ...
      'parallellabel', 'on', 'meridianlabel', 'on', ...
      'MLineLocation', 60, 'PLineLocation', 20, ...
      'MLabelParallel', 'south', ...
      'labelformat', 'compass')

plotm(c1.lat, c1.lon, 'og', 'linewidth', 2)
plotm(a1.lat, a1.lon, '+r', 'linewidth', 2)
S = shaperead('landareas','UseGeoCoords',true);
geoshow([S.Lat], [S.Lon],'Color','black');
legend('geo', 'cris', 'airs', 'location', 'southwest')
th = title('2016 2500 cm-1 Tb greater than 340K');
set(th, 'FontSize', 12')
tightmap
% saveas(gcf, '2016_350K_SW_map', 'png')

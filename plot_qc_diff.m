%
% plot_qc_diff - compare airs, cris, and cris with imag resid flag
%

addpath obs_list_data
addpath /asl/packages/ccast/motmsc/time

a1 = quint_obs_cat('airs2500y2016q1');
c1 = quint_obs_cat('cris2500y2016q1');
d1 = quint_obs_cat('uwqc2500y2016q1');

na = length(a1.Tb)
nc = length(c1.Tb)
nd = length(d1.Tb)

%----------------
% hot histograms
%----------------
figure(1); clf
subplot(3,1,1)
histogram(a1.Tb, 'BinWidth', 1)
% set(gca, 'YScale', 'log')
axis([340, 360, 10, 1e3])
title('AIRS 2016 2500 cm-1 hot Tb bins')
ylabel('count')
grid on

subplot(3,1,2)
histogram(d1.Tb, 'BinWidth', 1)
% set(gca, 'YScale', 'log')
axis([340, 360, 10, 1e3])
title('cris uw qc 2016 2500 cm-1 hot Tb bins')
ylabel('count')
grid on

subplot(3,1,3)
histogram(c1.Tb, 'BinWidth', 1)
% set(gca, 'YScale', 'log')
axis([340, 360, 10, 1e3])
title('cris umbc qc 2500 cm-1 hot Tb bins')
xlabel('Tb, K')
ylabel('count')
grid on
% saveas(gcf, '2016_hot_SW_hist', 'png')

return

%--------------
% hot spot map
%--------------
ia = find(a1.Tb > 350);
a1.lat = double(a1.lat(ia));
a1.lon = double(a1.lon(ia));
na = length(ia)

ic = find(c1.Tb > 350);
c1.lat = double(c1.lat(ic));
c1.lon = double(c1.lon(ic));
nc = length(ic)

id = find(d1.Tb > 350);
d1.lat = double(d1.lat(id));
d1.lon = double(d1.lon(id));
nd = length(id)

figure(2); clf
latlim = [-90, 90];  lonlim = [-180, 180];
axesm('mapprojection', 'eqdcylin', ...
      'maplatlimit', latlim, 'maplonlimit', lonlim, ...
      'grid', 'on', 'frame', 'on', 'flinewidth', 1, ...
      'parallellabel', 'on', 'meridianlabel', 'on', ...
      'MLineLocation', 60, 'PLineLocation', 20, ...
      'MLabelParallel', 'south', ...
      'labelformat', 'compass')

plotm(c1.lat, c1.lon, 'og')
plotm(a1.lat, a1.lon, '+r')
S = shaperead('landareas','UseGeoCoords',true);
geoshow([S.Lat], [S.Lon],'Color','black');
legend('geo', 'cris', 'airs', 'location', 'southwest')
th = title('2016 2500 cm-1 Tb greater than 350K');
set(th, 'FontSize', 12')
tightmap
% saveas(gcf, '2016_350K_SW_map', 'png')

%
% plot_obs_tbin - pdfs from obs list
%

addpath obs_list_data
addpath /asl/packages/ccast/motmsc/time

% total na/nc count normalization factor
% nf = 1;      % no scaling factor
% nf = 0.98;   % for 2016
  nf = 0.96;   % for 2015

a1 = quint_obs_cat('airs902y2015q1');
c1 = quint_obs_cat('cris902y2015q1');
d1 = quint_obs_cat('uwqc902y2015q1');

na = length(a1.Tb)
nc = length(c1.Tb)
nd = length(d1.Tb)

T1 = 320; T2 = 360;   % Tb bin span
dT = 0.5;             % Tb bin step size

% initialize Tb bins
tind = T1 : dT : T2;
tmid = tind + dT/2;
nbin = length(tind);
abin = zeros(nbin, 1);
cbin = zeros(nbin, 1);
dbin = zeros(nbin, 1);

ix = floor((a1.Tb - T1) / dT) + 1;
ix(ix < 1) = 1;
ix(nbin < ix) = nbin;
for i = 1 : length(ix)
  abin(ix(i)) = abin(ix(i)) + 1;
end

ix = floor((c1.Tb - T1) / dT) + 1;
ix(ix < 1) = 1;
ix(nbin < ix) = nbin;
for i = 1 : length(ix)
  cbin(ix(i)) = cbin(ix(i)) + 1;
end

ix = floor((d1.Tb - T1) / dT) + 1;
ix(ix < 1) = 1;
ix(nbin < ix) = nbin;
for i = 1 : length(ix)
  dbin(ix(i)) = dbin(ix(i)) + 1;
end

figure(1); clf
semilogy(tmid, abin, tmid, nf * cbin, tmid, nf * dbin, 'linewidth', 2)
axis([330, 350, 0, 1e5])
title('2015 new LW hot tails')
legend('AIRS', 'CrIS ccast', 'CrIS uw imag')
xlabel('Tb, K')
ylabel('count')
grid on

% saveas(gcf, '2015_LW_hot_tails', 'png')

return

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

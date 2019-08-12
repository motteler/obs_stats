%
% cris_geo_stats - sample stats. run after cris_geo_list
%

%---------------------------
% plot equal area grid bins
%---------------------------

nLat = 24;  dLon = 4;
[latB, lonB, gtot] = equal_area_bins(nLat, dLon, slat, slon);

gmean = mean(gtot(:));
grel = (gtot - gmean) / gmean;

tstr = 'CrIS equal area (count - mean) / mean';
equal_area_map(1, latB, lonB, grel, tstr);

%-------------------------
% plot raw latitude bins
%-------------------------
% number of latitude bands is 2 x N
% N1 = 40; N2 = 80; N3 = 120; N4 = 160;
  N1 = 10; N2 = 20; N3 = 30; N4 = 40;
vb1 = equal_area_spherical_bands(N1);
vb2 = equal_area_spherical_bands(N2);
vb3 = equal_area_spherical_bands(N3);
vb4 = equal_area_spherical_bands(N4);

figure(2); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(4,1,1)
histogram(lat, vb1)
title(sprintf('CrIS obs by latitude band, N = %d', N1))
ylabel('obs count')
grid on

subplot(4,1,2)
histogram(lat, vb2)
title(sprintf('CrIS obs by latitude band, N = %d', N2))
ylabel('obs count')
grid on

subplot(4,1,3)
histogram(lat, vb3)
title(sprintf('CrIS obs by latitude band, N = %d', N3))
ylabel('obs count')
grid on

subplot(4,1,4)
histogram(lat, vb4)
title(sprintf('CrIS obs by latitude band, N = %d', N4))
xlabel('latitude')
ylabel('obs count')
grid on

%---------------------------
% plot subset latitude bins
%---------------------------
figure(3); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(4,1,1)
histogram(slat, vb1)
title(sprintf('CrIS cos(lat) subset by latitude band, N = %d', N1))
ylabel('obs count')
grid on

subplot(4,1,2)
histogram(slat, vb2)
title(sprintf('CrIS cos(lat) subset by latitude band, N = %d', N2))
ylabel('obs count')
grid on

subplot(4,1,3)
histogram(slat, vb3)
title(sprintf('CrIS cos(lat) subset by latitude band, N = %d', N3))
ylabel('obs count')
grid on

subplot(4,1,4)
histogram(slat, vb4)
title(sprintf('CrIS cos(lat) subset by latitude band, N = %d', N4))
xlabel('latitude')
ylabel('obs count')
grid on

return

%--------------------------
% plot raw longitude bins
%--------------------------
Lb5  = -180 :  5 : 180;
Lb10 = -180 : 10 : 180;
Lb20 = -180 : 20 : 180;

figure(4); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(3,1,1)
histogram(lon, Lb5)
title('CrIS raw obs by 5 degree longitude band')
ylabel('obs count')
grid on

subplot(3,1,2)
histogram(lon, Lb10)
title('CrIS raw obs by 10 degree longitude band')
ylabel('obs count')
grid on

subplot(3,1,3)
histogram(lon, Lb20)
title('CrIS raw obs by 20 degree longitude band')
ylabel('obs count')
grid on

%----------------------------
% plot subset longitude bins
%-----------------------------
Lb5  = -180 :  5 : 180;
Lb10 = -180 : 10 : 180;
Lb20 = -180 : 20 : 180;

figure(5); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(3,1,1)
histogram(slon, Lb5)
title('CrIS cos(lat) subset by 5 degree lon band')
ylabel('obs count')
grid on

subplot(3,1,2)
histogram(slon, Lb10)
title('CrIS cos(lat) subset by 10 degree lon band')
ylabel('obs count')
grid on

subplot(3,1,3)
histogram(slon, Lb20)
title('CrIS cos(lat) subset by 20 degree lon band')
ylabel('obs count')
grid on

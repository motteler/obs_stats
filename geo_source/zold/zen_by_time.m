
load /asl/data/cris/ccast/daily/2016/allgeo20161209.mat

% xx = (allgeo.FORTime(15, :) - allgeo.FORTime(15, 1)) / (1e6 * 60 * 60);
% axis([0,24, 1.87, 1.89])

y1 = squeeze(allgeo.SatelliteZenithAngle(5, 1, :));
y2 = squeeze(allgeo.SatelliteZenithAngle(1, 1, :));

z1 = sec(deg2rad(y1));
z2 = sec(deg2rad(y2));

n1 = length(z1);
x1 = 24 * (1:n1)/n1;

figure(1); clf
subplot(2,1,1)
plot(x1, z1)
title('FOV 5 FOR 1 24 hour')
axis([0,24, 1.86, 1.885])
ylabel('sec of zen')
grid on

subplot(2,1,2)
plot(x1, z2)
title('FOV 1 FOR 1 24 hour')
axis([0,24, 1.86, 1.885])
ylabel('sec of zen')
xlabel('hour')
grid on
axis([0,24, 1.98, 2.01])

% axis for near-nadir
% plot(z2)
% axis([0,10000, 1.00053, 1.00055])


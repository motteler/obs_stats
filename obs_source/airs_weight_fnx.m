%
% quick look at AIRS weighting functions
%

addpath /asl/packages/airs_decon/test

% std atmos weighting functions
load /asl/s1/sergio/AIRSPRODUCTS_JACOBIANS/STD/wgtfcn_jac.mat
% ix = interp1(fout, 1:2378, [902, 1231.33, 1613.86, 2500], 'nearest');
% ix = find(667 <= fout & fout <= 720);
% ix = find(685 <= fout & fout <= 695);
% w = jwgtfcn(ix, :)';

% associated pressure levels
press= load('/home/sergio/MATLABCODE/airslevels.dat');
pN = press(1:100)-press(2:101);
pD = log(press(1:100)./press(2:101));
pavg = pN./pD;
pavg = pavg(4:100);

% w is 97 x 2378 array of weighting functions
w = jwgtfcn';

[xx, ii] = max(w);
[x,y] = pen_lift(fout, pavg(ii));
figure(1)
plot(x, y)
axis([600,2700,0,1000])
h = gca;
set(h, 'YDir', 'reverse');
title('AIRS weighting function peaks by frequency')
xlabel('wavenumber (cm-1)')
ylabel('pressure (mb)')
grid on; zoom on

yy = pavg(ii);
ix = find(252 < yy & yy < 254)
vleg = {};
for i = 1 : min(ix, 6)
  vleg{i} = sprintf('%4.2f cm-1', fout(ix(i)));
end
figure(2)
plot(w(:, ix), pavg)
h = gca;
set(h, 'YDir', 'reverse');
title('AIRS weighting function peaking near 250 mb')
legend(vleg, 'location', 'southeast')
xlabel('weight')
ylabel('pressure (mb)')
grid on; zoom on

return

% plot the selected values
% plot(w(:,1), pavg, w(:,2), pavg, w(:,3), pavg, w(:,4), pavg, ...
%      'linewidth', 2)
% legend('902 cm-1', '1231.3 cm-1', '1613.9 cm-1', '2500 cm-1')
% xlabel('weight')

for j = 1:10:2378
  ix = j : j + 9;
  w = jwgtfcn(ix, :)';
  plot(w, pavg, 'linewidth', 2)
  h = gca;
  set(h, 'YDir', 'reverse');
  ix
  input('next > ');
end

return

% pcolor plot
figure(1)
fx = fout(ix);
pcolor(fx, pavg, w)
caxis([0, 0.06])
colormap hot
colorbar
h = gca;
set(h, 'YDir', 'reverse');

title('AIRS weighting functions')
xlabel('frequency (cm-1)')
ylabel('pressure (mb)')
grid on; zoom on


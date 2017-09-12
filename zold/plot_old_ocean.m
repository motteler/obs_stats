%
% plot_tbinX - show combined results from airs_tbin and cris_tbin
%

addpath tbin_tests

d1 = load('airs_tbinA');
d2 = load('cris_tbinA');

tbin_a = d1.tbin;
tbin_c = d2.tbin;
tind = d1.tind;

na = sum(tbin_a)
nc = sum(tbin_c)

figure(1)
subplot(2,1,1)
plot(tind, tbin_a, tind, (na/nc)*tbin_c, 'linewidth', 2)
axis([200, 305, 0, 5e7])
title('obs count by 900 cm-1 temperature bins')
legend('AIRS', 'CrIS', 'location', 'northwest')
grid on

subplot(2,1,2)
plot(tind, ((na/nc)* tbin_c - tbin_a) ./ tbin_a, 'linewidth', 2)
axis([200, 305 -0.05, 0.05])
title('CrIS minus AIRS relative difference')
xlabel('Tb, K')
grid on


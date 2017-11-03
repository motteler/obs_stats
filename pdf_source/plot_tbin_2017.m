%
% plot_tbin - show results from airs_tbin and cris_tbin
%

addpath pdf_test_2017

year = 2017

a1 = load(sprintf('airs902y%dq1', year));
a2 = load(sprintf('airs902y%dq2', year));

c1 = load(sprintf('cris902y%dq1', year));
c2 = load(sprintf('cris902y%dq2', year));

tbin_a = [a1.tbin, a2.tbin];
tbin_c = [c1.tbin, c2.tbin];

% sum along days
tbin_a = sum(tbin_a, 2);
tbin_c = sum(tbin_c, 2);

na = sum(tbin_a)
nc = sum(tbin_c)
tmid = a1.tmid;

figure(1)
subplot(2,1,1)
  plot(tmid, tbin_a, tmid, (na/nc)*tbin_c, 'linewidth', 2)
% plot(tmid, tbin_a, tmid, tbin_c, 'linewidth', 2)
  axis([190, 330, 0, 1.4e7])
% axis([200, 305, 0, 4e5])
  title('obs count by 900 cm-1 temperature bins')
% title('obs count by SW cm-1 temperature bins')
legend('AIRS', 'CrIS', 'location', 'northwest')
grid on

subplot(2,1,2)
  plot(tmid, ((na/nc)* tbin_c - tbin_a) ./ tbin_a, 'linewidth', 2)
% plot(tmid, (tbin_c - tbin_a) ./ tbin_a, 'linewidth', 2)
  axis([190, 330,-0.05, 0.05])
% axis([200, 305 -0.1, 0.4])
title('CrIS minus AIRS relative difference')
xlabel('Tb, K')
grid on


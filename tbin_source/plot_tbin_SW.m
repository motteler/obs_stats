%
% plot_tbin - show results from airs_tbin and cris_tbin
%

addpath pdf_test_360K

year = 2016

a1 = load(sprintf('airs2500y%dq1', year));
a2 = load(sprintf('airs2500y%dq2', year));
a3 = load(sprintf('airs2500y%dq3', year));
a4 = load(sprintf('airs2500y%dq4', year));
a5 = load(sprintf('airs2500y%dq5', year));

c1 = load(sprintf('cris2500y%dq1', year));
c2 = load(sprintf('cris2500y%dq2', year));
c3 = load(sprintf('cris2500y%dq3', year));
c4 = load(sprintf('cris2500y%dq4', year));
c5 = load(sprintf('cris2500y%dq5', year));

tbin_a = [a1.tbin, a2.tbin, a3.tbin, a4.tbin, a5.tbin];
tbin_c = [c1.tbin, c2.tbin, c3.tbin, c4.tbin, c5.tbin];

% sum along days
tbin_a = sum(tbin_a, 2);
tbin_c = sum(tbin_c, 2);

na = sum(tbin_a)
nc = sum(tbin_c)
tmid = a1.tmid;

figure(1)
subplot(2,1,1)
plot(tmid, tbin_a, tmid, (na/nc)*tbin_c, 'linewidth', 2)
axis([190, 330, 0, 1.4e7])
title('obs count by 2500 cm-1 temperature bins')
legend('AIRS', 'CrIS', 'location', 'northwest')
grid on

subplot(2,1,2)
plot(tmid, ((na/nc)* tbin_c - tbin_a) ./ tbin_a, 'linewidth', 2)
axis([190, 330,-0.03, 0.07])
title('CrIS minus AIRS relative difference')
xlabel('Tb, K')
grid on

figure(2)
subplot(2,1,1)
plot(tmid, tbin_a, tmid, (na/nc)*tbin_c, 'linewidth', 2)
axis([330, 360, 0, 1e3])
title('obs count by 2500 cm-1 temperature bins')
legend('AIRS', 'CrIS', 'location', 'northwest')
grid on

subplot(2,1,2)
plot(tmid, ((na/nc)* tbin_c - tbin_a) ./ tbin_a, 'linewidth', 2)
axis([330, 360, -0.5, 0.5])
title('CrIS minus AIRS relative difference')
xlabel('Tb, K')
grid on

figure(2)
subplot(2,1,1)
semilogy(tmid, tbin_a, tmid, (na/nc)*tbin_c, 'linewidth', 2)
axis([330, 360, 0, 1e5])
title('log scale obs count by 2500 cm-1 Tb bins')
legend('AIRS', 'CrIS', 'location', 'northeast')
grid on

subplot(2,1,2)
plot(tmid, tbin_a, tmid, (na/nc)*tbin_c, 'linewidth', 2)
axis([340, 360, 0, 800])
title('linear scale obs count by 2500 cm-1 Tb bins')
legend('AIRS', 'CrIS', 'location', 'northeast')
grid on

return

figure(3)
subplot(2,1,1)
plot(tmid, tbin_a, tmid, (na/nc)*tbin_c, 'linewidth', 2)
axis([330, 360, 0, 1e3])
title('obs count by 2500 cm-1 temperature bins')
legend('AIRS', 'CrIS', 'location', 'northwest')
grid on

subplot(2,1,2)
plot(tmid, ((na/nc)* tbin_c - tbin_a) ./ tbin_a, 'linewidth', 2)
axis([330, 360, -0.5, 0.5])
title('CrIS minus AIRS relative difference')
xlabel('Tb, K')
grid on



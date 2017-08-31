%
% airs_pdfs_aux -- combine runs of airs_pdfs
%

d16 = load('airs_pdfs_16.mat');
d32 = load('airs_pdfs_32.mat');
d64 = load('airs_pdfs_64.mat');
d364 = load('airs_pdfs_364.mat');

% normalize dailies
tmid = d32.tmid;
tbin4 = d32.tbin ./ sum(d32.tbin);

% daily integrated Tb
[m, n] = size(tbin4);
ttmp = tbin4 .* (tmid(:) * ones(1,n));
tint4 = sum(ttmp);

% moving average of dailies
[mavg4, iavg4] = moving_avg(tint4, 182);  % 1 year
dax4 = datetime(d32.dnum(iavg4), 'ConvertFrom', 'datenum');

% datetime axis for 1-year moving PDF
dax364 = datetime(d364.dnum2, 'ConvertFrom', 'datenum');

figure(1); clf
plot(dax364, d364.tint, ...
     dax4, mavg4, ...
     d32.dax(d32.iavg), d32.mavg);
title('902 cm-1 1-year moving stat comparison')
legend('1-year moving PDF', ...
       '1-year moving avg of daily PDFs', ...
       '1-year moving avg of 32-day moving PDF', ...
        'location', 'northwest')
ylabel('Tb, K')
xlabel('year')
grid on; zoom on

figure(2); clf
plot(d16.dax(d16.iavg), d16.mavg, ...
     d32.dax(d32.iavg), d32.mavg, ...
     d64.dax(d64.iavg), d64.mavg)
title('902 cm-1 1-year moving averages')
legend('16-day moving PDF', ...
       '32-day moving PDF', ...
       '64-day moving PDF', ...
        'location', 'northwest')
ylabel('Tb, K')
xlabel('year')
grid on; zoom on


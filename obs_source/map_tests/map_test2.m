%
% map_test2 - combine equal area Tb maps, do CrIS annual diffs
%

addpath source
addpath map_data
addpath /asl/packages/ccast/motmsc/time

ctot = 0; csum = 0; 
atot = 0; asum = 0;

% loop on 16-day sets
ya = 2016;
yc = 2017;
for i = 1 : 23
  a1 = load(sprintf('cris902y%ds%0.2d.mat', ya, i));
  c1 = load(sprintf('cris902y%ds%0.2d.mat', yc, i));

  atot = atot + a1.gtot1;
  ctot = ctot + c1.gtot1;

  asum = asum + a1.gavg1 .* a1.gtot1;
  csum = csum + c1.gavg1 .* c1.gtot1;

end

aavg = asum ./ atot;
cavg = csum ./ ctot;

tstr = 'CrIS 2016 minus 2017 mean equal area Tb bins';
equal_area_map(3, c1.latB1, c1.lonB1, aavg - cavg, tstr);


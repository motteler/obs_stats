%
% map_test1 - combine equal area Tb maps, do AIRS and CrIS diff
%

addpath source
addpath map_data
addpath /asl/packages/ccast/motmsc/time

ctot = 0; csum = 0; 
atot = 0; asum = 0;

% loop on 16-day sets
year = 2017;
for i = 1 : 23
  a1 = load(sprintf('airs902y%ds%0.2d.mat', year, i));
  c1 = load(sprintf('cris902y%ds%0.2d.mat', year, i));

  atot = atot + a1.gtot1;
  ctot = ctot + c1.gtot1;

  asum = asum + a1.gavg1 .* a1.gtot1;
  csum = csum + c1.gavg1 .* c1.gtot1;

end

aavg = asum ./ atot;
cavg = csum ./ ctot;

tstr = 'AIRS %d mean equal area Tb bins';
tstr = sprintf(tstr, a1.year);
equal_area_map(1, a1.latB1, a1.lonB1, aavg, tstr);

tstr = 'CrIS %d mean equal area Tb bins';
tstr = sprintf(tstr, c1.year);
equal_area_map(2, c1.latB1, c1.lonB1, cavg, tstr);

cax = [-1.6, 1.6];
tstr = 'AIRS minus CrIS %d mean equal area Tb bins';
tstr = sprintf(tstr, a1.year);
equal_area_map(3, c1.latB1, c1.lonB1, aavg - cavg, tstr, cax);


%
% compare sst matchups
%

addpath ../source
addpath /home/motteler/cris/ccast/motmsc/time

load ../obs_16day_airs_c3/airs_c03y2013s04.mat

sst = sst_match(tai_list, lat_list, lon_list);

for j = 1 : length(tai_list)

  sst2 = simple_read(tai_list(j), lat_list(j), lon_list(j));

  if ~isequaln(sst(j), sst2)
    fprintf(1, '%d %g %g\n', j, sst(j), sst2);
  end
  if mod(j, 1e6) == 0, fprintf(1, '.'), end
end
fprintf(1, '\n')



function d1 = quint_obs_cat(s1)

d1 = struct;
d1.Tb  = []; 
d1.lat = []; 
d1.lon = [];
d1.tai = []; 
d1.zen = []; 
d1.sol = [];

for i = 1 : 5
  d2 = load(sprintf('%s%d', s1(1:end-1), i));
  d1.Tb  = [d1.Tb;  d2.Tb_list];
  d1.lat = [d1.lat; d2.lat_list];
  d1.lon = [d1.lon; d2.lon_list];
  d1.tai = [d1.tai; d2.tai_list];
  d1.zen = [d1.zen; d2.zen_list];
  d1.sol = [d1.sol; d2.sol_list];
end


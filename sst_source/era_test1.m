%
% sample map of ERA data
%

p = '/asl/data/era/2018/07';
f = '20180720_sfc.nc';
d1 = read_netcdf_lls(fullfile(p,f));

latB1 = -90 : 0.75 : 90;
lonB1 = -180 : 0.75 : 180;

% switch data to a -180:180 longitude axis
sst = d1.skt(:,:,2)';

sst = [sst(:, 241:480), sst(:,1:240)];

sst = sst(1:240,:);  % this can't be right

equal_area_map(1, latB1, lonB1, sst, 'sample ERA map');


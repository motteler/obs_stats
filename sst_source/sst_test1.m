%
% sample map of OI SST data
%

addpath ../source

p1 = '/asl/xfs3/SST-OI/2017/06';
f1 = 'avhrr-only-v2.20170620.nc';
f1 = fullfile(p1, f1);
d1 = read_netcdf_lls(f1);

latB1 = -90 : 0.25 : 90;
lonB1 = -180 : 0.25 : 180;

% switch data to a -180:180 longitude axis
sst = d1.sst';
err = d1.err';
ice = d1.ice';

sst = [sst(:, 721:1440), sst(:,1:720)];
err = [err(:, 721:1440), err(:,1:720)];
ice = [ice(:, 721:1440), ice(:,1:720)];

equal_area_map(1, latB1, lonB1, sst, 'sample OI SST map');

% equal_area_map(1, latB1, lonB1, ice, 'sample OI ice map');
% equal_area_map(1, latB1, lonB1, err, 'sample OI SST err');
% saveas(gcf, 'OISST_sample_err', 'png')


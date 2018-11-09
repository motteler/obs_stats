
adir = '/asl/data/airs/AIRIBRAD/2018/001';
agran = 'AIRS.2018.01.01.220.L1B.AIRS_Rad.v5.0.23.0.G18002101507.hdf';
afile = fullfile(adir, agran);

xx = hdfinfo(afile);

% Geo fields
for i = 1 : 3
  xx.Vgroup.Vgroup(1).SDS(i)
end

% SDS fields
for i = 1 : 74
  xx.Vgroup.Vgroup(2).SDS(i)
end

% Vdata fields
for i = 1 : 139
  xx.Vgroup.Vgroup(2).Vdata(i)
end

% Attributes
xx.Attributes(5).Value


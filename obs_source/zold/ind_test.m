
% moving window = 2*nsp + 1

nset = 10;
nsp1 = 2;

for i = nsp1+1 : nset-nsp1; 
  for j = i-nsp1 : i+nsp1-1
    [i,j,j+1]
  end
end


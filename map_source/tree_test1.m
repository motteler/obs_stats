%
% hierarchical merge test
%

m = input('m > ');
a = rand(m,1) * 100;
b = sum(a);

while m > 1
  n = floor((m-1)/2)+1;
  for i = 1 : n
    if 2*i-1 == m
      [m, n, i, 2*i-1]
      a(i) = a(2*i-1);
    else
      [m, n, i, 2*i-1, 2*i]
      a(i) = a(2*i-1) + a(2*i);
    end
  end
  m = n;
end

(a(1) - b) / b


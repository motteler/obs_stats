%
% file name from plot title
%

function f = t2fstr(t)

f = strrep(t, ' ', '_');
f = strrep(f, '.', 'p');


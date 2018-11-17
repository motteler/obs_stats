%   j1 = (ilat-1)*nchan + (ilon-1)*nchan*mlat + 1;
%   j2 = j1 + nchan - 1;
%
%   if ~isequal(gavg(:,ilat,ilon), gavg(j1:j2)')
%     keyboard
%   end
%
%   gavg(j1:j2) = gavg(j1:j2) + obs(:, i)';
%   gsqr(j1:j2) = gsqr(j1:j2) + obs(:, i)'.^2; 


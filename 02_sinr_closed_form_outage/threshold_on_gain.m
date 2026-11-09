function xi = threshold_on_gain(s, rho)
% THRESHOLD_ON_GAIN  Turn "SINR >= threshold" into "|h|^2 >= xi".
%
%   delta*rho*x / (vartheta*rho*x + 1) >= gth
%   <=>  rho*x*(delta - vartheta*gth) >= gth
%   <=>  x >= xi = gth / ( rho*(delta - vartheta*gth) )
%
% Only possible when gth < delta/vartheta (the SINR ceiling). Otherwise the
% stream can never be decoded and xi = Inf (outage = 1 at every power).
den = rho .* (s.delta - s.vartheta .* s.gth);
xi  = s.gth ./ den;
xi(den <= 0) = Inf;
end

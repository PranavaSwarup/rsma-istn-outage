function style_axes(ttl, fl)
% STYLE_AXES  Common look for Fig 1 and Fig 2.
grid on; box on;
xlabel('P_s (dBW)'); ylabel('Outage probability');
title(ttl); legend('Location', 'southwest');
yl = ylim; ylim([max(yl(1), fl) 1]);
end

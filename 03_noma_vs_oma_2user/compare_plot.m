function compare_plot(Ps, aw, sw, as, ss, c, ttl, fl)
% COMPARE_PLOT  Analysis vs simulation for one scheme (Fig 3 = NOMA, Fig 4 = OMA).
%   Colour c = the scheme's colour (NOMA blue, OMA red)
%   weak user   = solid line,   strong user = dashed line
%   analysis    = line + squares, simulation = stars
% Bottom panel: relative gap |sim - ana| / ana in percent.
figure('Name', ttl);

% ---- top panel: overlay
ax1 = axes('Position', [0.13 0.40 0.80 0.53]);
semilogy(ax1, Ps, aw, '-s',  'Color', c, 'DisplayName', 'weak - analysis');  hold(ax1, 'on');
semilogy(ax1, Ps, pos_nan(sw), '*', 'Color', c, 'MarkerSize', 9, 'DisplayName', 'weak - simulation');
semilogy(ax1, Ps, as, '--s', 'Color', c, 'DisplayName', 'strong - analysis');
semilogy(ax1, Ps, pos_nan(ss), '*', 'Color', c, 'MarkerSize', 9, 'DisplayName', 'strong - simulation');
grid(ax1, 'on'); box(ax1, 'on');
ylabel(ax1, 'Outage probability'); title(ax1, ttl);
legend(ax1, 'Location', 'southwest');
yl = ylim(ax1); ylim(ax1, [max(yl(1), fl) 1]);
set(ax1, 'XTickLabel', []);

% ---- bottom panel: relative gap
ax2 = axes('Position', [0.13 0.11 0.80 0.24]);
plot(ax2, Ps, 100*abs(sw - aw)./aw, '-*',  'Color', c, 'DisplayName', 'weak');  hold(ax2, 'on');
plot(ax2, Ps, 100*abs(ss - as)./as, '--*', 'Color', c, 'DisplayName', 'strong');
grid(ax2, 'on'); box(ax2, 'on');
xlabel(ax2, 'P_s (dBW)'); ylabel(ax2, 'Gap (%)');
legend(ax2, 'Location', 'northwest');
linkaxes([ax1 ax2], 'x'); xlim(ax1, [Ps(1) Ps(end)]);
end

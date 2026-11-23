function v = pos_nan(v)
% POS_NAN  Hide zero simulated outages (a zero cannot be drawn on a log axis).
v(v <= 0) = NaN;
end

function [xw, xs] = order_users(H, how)
% ORDER_USERS  Pick the weak and strong user's channel gains over T HARQ rounds.
%
%   [xw, xs] = order_users(H, how)
%     H   : T x n x K array of |h|^2  (rounds x samples x users)
%     how : 'first' - roles fixed by the round-1 channel and kept for all T
%                     rounds (default). HARQ-CC resends the SAME superposed
%                     packet, so the power split and decoding order (who is
%                     weak/strong) cannot change between rounds.
%           'sum'   - roles fixed by the accumulated gain sum_t |h_t|^2
%                     (genie: needs CSI of future rounds; upper benchmark).
%           'round' - per-round min/max (old behaviour). Inconsistent: the
%                     "weak user" is then a different physical user in
%                     different rounds, and its accumulated SINR is not any
%                     real user's. Kept only for comparison.
%     xw, xs : T x n gains of the weakest / strongest user.
%
%   [ASSUMED] The paper only says users are "distinguished by the channel
%   quality" (footnote 3); it does not say how roles are kept across rounds.

[T, n, K] = size(H);
switch how
    case 'round'
        xw = min(H, [], 3);
        xs = max(H, [], 3);
        return;
    case 'first'
        key = H(1, :, :);          % 1 x n x K
    case 'sum'
        key = sum(H, 1);           % 1 x n x K
    otherwise
        error('order_users: unknown ordering ''%s''.', how);
end
[~, iw] = min(key, [], 3);         % 1 x n, index of weak user per sample
[~, is] = max(key, [], 3);         % 1 x n, index of strong user per sample

rows = repmat((1:T)', 1, n);
cols = repmat(1:n, T, 1);
xw = H(sub2ind([T n K], rows, cols, repmat(iw, T, 1)));
xs = H(sub2ind([T n K], rows, cols, repmat(is, T, 1)));
end

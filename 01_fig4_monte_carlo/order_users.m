function [xw, xs] = order_users(H, how)
% ORDER_USERS  Weak / strong user's channel gains over T HARQ-CC rounds.
%
%   [xw, xs] = order_users(H, how)
%     H   : T x n x K array of |h|^2   (rounds x samples x users)
%     how : 'round' - weak = min over users, strong = max, chosen again in
%                     EVERY round (default). This is what the paper's analysis
%                     needs: its HARQ-CC method assumes every round has the same
%                     distribution, which only holds for per-round ordering.
%                     It reproduces the paper's Fig. 4 ranking at T = 3.
%           'first' - roles fixed by the round-1 channel and kept for all T
%                     rounds. Physically consistent: HARQ-CC resends the SAME
%                     superposed packet, so who is weak/strong cannot change.
%     xw, xs : T x n gains of the weak / strong user.
%
% For T = 1 both choices are identical.
% [ASSUMED] The paper does not say how roles are kept across rounds.

[T, n, K] = size(H);
switch how
    case 'round'
        xw = min(H, [], 3);
        xs = max(H, [], 3);
        return;
    case 'first'
        key = H(1, :, :);              % 1 x n x K : round-1 gains
    otherwise
        error('order_users: unknown ordering ''%s''.', how);
end
[~, iw] = min(key, [], 3);             % 1 x n : index of weak user
[~, is] = max(key, [], 3);             % 1 x n : index of strong user
rows = repmat((1:T)', 1, n);
cols = repmat(1:n, T, 1);
xw = H(sub2ind([T n K], rows, cols, repmat(iw, T, 1)));
xs = H(sub2ind([T n K], rows, cols, repmat(is, T, 1)));
end

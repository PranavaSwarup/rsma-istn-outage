function [xw, xs] = order_users(h1, h2, mode)
% ORDER_USERS  Weak / strong user channel gains for a 2-user NOMA/OMA pair.
%   h1, h2 : T x n matrices of |h|^2 (rows = HARQ rounds, columns = trials)
%   mode   : 'round' -> min/max taken separately in every round. This is [12]'s
%                       instantaneous ordering (its eq. (15) order statistics)
%                       applied per round; rounds stay i.i.d.
%            'first' -> roles decided by round 1 and kept for all T rounds
%                       (HARQ-CC resends the same superposed packet).
%            'none'  -> no ordering: user 1 is a generic user.
switch lower(mode)
    case 'round'
        xw = min(h1, h2);  xs = max(h1, h2);
    case 'first'
        weak1 = h1(1,:) <= h2(1,:);            % 1 x n
        W = repmat(weak1, size(h1,1), 1);
        xw = h1.*W + h2.*~W;
        xs = h2.*W + h1.*~W;
    case 'none'
        xw = h1;  xs = h2;
    otherwise
        error('order_users: unknown mode "%s"', mode);
end
end

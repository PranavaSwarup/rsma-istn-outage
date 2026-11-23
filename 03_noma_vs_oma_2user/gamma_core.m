function g = gamma_core(k, sz)
% GAMMA_CORE  Gamma(shape k, scale 1) samples, k >= 1, using the
% Marsaglia-Tsang method. Plain MATLAB, so no Statistics Toolbox is needed.

d = k - 1/3;  c = 1/sqrt(9*d);
g = zeros(sz);
todo = true(sz);
while any(todo(:))
    n = nnz(todo);
    z = randn(n,1);
    v = (1 + c*z).^3;
    u = rand(n,1);
    ok = v > 0 & log(u) < 0.5*z.^2 + d - d*v + d*log(max(v, realmin));
    idx = find(todo);
    g(idx(ok)) = d*v(ok);
    todo(idx(ok)) = false;
end
end

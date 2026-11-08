function P = rsma_bounds_analytic(PsdB, T, a, bI, gth, p, method, N, M)
% RSMA_BOUNDS_ANALYTIC  Paper's closed form, eq. (9) / eq. (11) of Hu et al.
%   P = Pr{ sum_{t=1}^T gamma_t < gth },  gamma_t = a*rho*x_t / (bI*rho*x_t + 1)
%
%   Pr{A1}: a = alpha_c,  bI = 1 - alpha_c,           gth = gc_th   (eq. 9)
%   Pr{A2}: a = alpha_k,  bI = 1 - alpha_c - alpha_k, gth = gp_th   (eq. 11)
%   NOMA far user (unordered) is the same form with a = a1, bI = a2.
%
%   method = 'gs'   (default) paper's route: Gauss-Chebyshev (N nodes, eq. 20)
%                    + Gaver-Stehfest inversion (M, eq. 26) + Gauss-Chebyshev (eq. 28)
%            'step' same quadrature, but the inverse Laplace of exp(-s*A) is a
%                    delta at A, so its integral up to gth is the step 1{A < gth}
%   N = 20, M = 10 as in the paper. Requires gth < theta = a/bI (full diversity case).
if nargin < 7 || isempty(method), method = 'gs'; end
if nargin < 8 || isempty(N), N = 20; end
if nargin < 9 || isempty(M), M = 10; end
th = a/bI;
if gth >= th, error('gth >= theta = a/bI: the paper''s derivation assumes gth < theta.'); end

b = p.b; m = p.m; Om = p.Omega;
lam   = (1/(2*b)) * (2*b*m/(2*b*m + Om))^m;
beta  = 1/(2*b);
delta = Om/(2*b*(2*b*m + Om));

r  = (1:N).';  y = cos((2*r-1)*pi/(2*N));        % Chebyshev nodes y_r
yt = (y+1)*th/2;                                 % SINR node in [0, theta]
Ps = 10.^(PsdB/10);
P  = zeros(size(Ps));

% Stehfest coefficients xi_m (eq. 26)
xi = zeros(2*M,1);
for k = 1:2*M
    s = 0;
    for j = floor((k+1)/2):min(k,M)
        s = s + j^(M+1)/factorial(M)*nchoosek(M,j)*nchoosek(2*j,j)*nchoosek(j,k-j);
    end
    xi(k) = (-1)^(M+k)*s;
end
ye = y;  yy = (ye+1)*gth/2;                      % nodes for the outer integral (eq. 28)

for i = 1:numel(Ps)
    G  = Ps(i)*p.g;
    x  = yt ./ (G*(a - yt*bI));                  % |h|^2 that gives SINR yt  (inverse of eq. 5/6)
    jac = a*G ./ (G*(a - yt*bI)).^2;             % d x / d yt
    w  = (pi/N)*(th/2)*sqrt(1-y.^2) .* sr_pdf(x, lam, beta, delta, m) .* jac;
    % weights w are lambda*c_t*R_t(y_r) of eq. (22): one round's SINR as N point masses

    % T-fold sum: atoms A = sum of node values, weights = product (the set "N-calligraphic" in eq. 23)
    A = 0;  W = 1;
    for t = 1:T
        A = A(:) + yt.';  W = W(:) .* w.';
    end
    A = A(:);  W = W(:);

    switch method
        case 'step'
            P(i) = sum(W(A < gth));
        case 'gs'
            % L1 = ln2 * sum_m xi_m * int_0^gth 2^(-m*A/y)/y dy   (eqs. 26-28)
            L = zeros(numel(A),1);
            for k = 1:2*M
                L2 = (pi/N) * sum( sqrt(1-ye.'.^2)./(1+ye.') .* 2.^(-k*A./yy.'), 2 );
                L  = L + xi(k)*L2;
            end
            P(i) = sum(W .* log(2) .* L);
    end
end
end

function f = sr_pdf(x, lam, beta, delta, m)
% Shadowed-Rician pdf, eq. (4), with 1F1 summed in log space (stable for large x)
f = zeros(size(x));
for i = 1:numel(x)
    z = delta*x(i);
    nmax = ceil(z + 10*sqrt(z) + m + 50);
    n = (0:nmax).';
    lt = gammaln(m+n) - gammaln(m) + n*log(max(z,realmin)) - 2*gammaln(n+1);
    mx = max(lt);
    f(i) = lam * exp(-beta*x(i) + mx + log(sum(exp(lt - mx))));
end
end

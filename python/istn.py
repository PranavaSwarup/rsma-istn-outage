"""Line-by-line Python mirror of the MATLAB code on this branch (used to generate
the figures and numbers in docs/ because MATLAB was not available in the build
environment). MATLAB output should agree up to Monte Carlo noise."""
import numpy as np
from scipy.special import gammaln, gammainc

def params(order='round', extra_gain_dB=0.0, lambda_hi=0.0, isic=0, Omega_I_dB=-20, preset=''):
    if preset == 'fig4': order, extra_gain_dB = 'round', 5.25
    p = dict(b=0.126, m=10.1, Omega=0.835)
    N0 = 1.38e-23*50e6*290
    Gs, Gr = 10**2.5, 10**0.5
    Gk = 3e8*np.sqrt(Gs*Gr)/(4*np.pi*1.55e9*1000e3)
    p['g_linkbudget'] = Gk**2/N0
    p['extra_gain_dB'] = extra_gain_dB
    p['g'] = p['g_linkbudget']*10**(extra_gain_dB/10)
    p.update(alpha_c=0.4, alpha_p=[0.3, 0.3], gc_th=0.4, gp_th=0.4)
    Rc = Rp = np.log2(1.4); R1 = Rc/2 + Rp
    p.update(R1=R1, a1=0.7, a2=0.3, g_noma=2**R1-1, g_oma=2**(2*R1)-1,
             lambda_hi=lambda_hi, isic=isic, Omega_I=10**(Omega_I_dB/10), order=order)
    return p

def sr_gain(rng, shape, p):
    A2 = (p['Omega']/p['m'])*rng.gamma(p['m'], 1.0, shape)
    phi = 2*np.pi*rng.random(shape)
    Z = np.sqrt(p['b'])*(rng.standard_normal(shape)+1j*rng.standard_normal(shape))
    return np.abs(np.sqrt(A2)*np.exp(1j*phi)+Z)**2

def order_users(h1, h2, mode):
    if mode == 'round': return np.minimum(h1, h2), np.maximum(h1, h2)
    if mode == 'first':
        w = h1[0] <= h2[0]
        return np.where(w, h1, h2), np.where(w, h2, h1)
    return h1, h2

def mc(PsdB, T, N, p, seed=2025, chunk=1_000_000):
    """Monte Carlo: OMA weak/strong, NOMA far/near, RSMA OP (generic user k=1)."""
    rng = np.random.default_rng(seed)
    Ps = 10**(np.asarray(PsdB)/10); c = np.zeros((5, len(Ps))); done = 0
    a1, a2, gN, gO = p['a1'], p['a2'], p['g_noma'], p['g_oma']; lam2 = p['lambda_hi']**2
    ac = p['alpha_c']; ak = p['alpha_p'][0]; sumP = sum(p['alpha_p']); oth = sumP - ak
    while done < N:
        n = min(chunk, N-done)
        h1 = sr_gain(rng, (T, n), p); h2 = sr_gain(rng, (T, n), p)
        xw, xs = order_users(h1, h2, p['order'])
        gI = p['Omega_I']*rng.exponential(1.0, (T, n))
        for i, P in enumerate(Ps):
            r = P*p['g']; I = p['isic']*r*gI
            c[0, i] += ((r*xw).sum(0) < gO).sum()
            c[1, i] += ((r*xs).sum(0) < gO).sum()
            c[2, i] += ((a1*r*xw/((a2+lam2)*r*xw+1)).sum(0) < gN).sum()
            g21 = a1*r*xs/((a2+lam2)*r*xs+I+1); g2 = a2*r*xs/(lam2*r*xs+I+1)
            c[3, i] += ((g21.sum(0) < gN) | (g2.sum(0) < gN)).sum()
            gc = ac*r*h1/(sumP*r*h1+1); gp = ak*r*h1/(oth*r*h1+1)
            c[4, i] += ((gc.sum(0) < p['gc_th']) | (gp.sum(0) < p['gp_th'])).sum()
        done += n
    return dict(zip(['oma', 'oma_s', 'noma', 'noma_n', 'rsma'], c/N))

def sr_cdf(z, T, p):
    b, m, Om = p['b'], p['m'], p['Omega']
    lam = (1/(2*b))*(2*b*m/(2*b*m+Om))**m; beta = 1/(2*b); delta = Om/(2*b*(2*b*m+Om))
    n = np.arange(401)
    w1 = np.exp(np.log(lam)+gammaln(m+n)-gammaln(m)+n*np.log(delta)-gammaln(n+1)-(n+1)*np.log(beta))
    w = w1.copy()
    for _ in range(T-1): w = np.convolve(w, w1)[:401]
    z = np.atleast_1d(np.asarray(z, float))
    return w @ gammainc((n+T)[:, None], beta*z[None, :])

def _round_cdf(a, b, rho, y, dist, p):
    if np.isinf(a): x = y/rho
    else:
        den = a-b*y; x = np.where(den > 0, y/(rho*np.maximum(den, 1e-300)), np.inf)
    G = np.ones_like(x); f = np.isfinite(x); G[f] = sr_cdf(x[f], 1, p)
    return 1-(1-G)**2 if dist == 'min' else G

def _sum_cdf(a, b, rho, th, dists, p, M=3000):
    e = np.linspace(0, th, M+1); pm = None
    for d in dists:
        pc = np.diff(_round_cdf(a, b, rho, e, d, p))
        pm = pc if pm is None else np.convolve(pm, pc)[:M]
    cut = M-(len(dists)-1)/2; w = np.clip(cut-np.arange(len(pm)), 0, 1)
    return float(np.sum(pm*w))

def analytic(PsdB, T, p):
    dl = {'round': ['min']*T, 'first': ['min']+['gen']*(T-1)}.get(p['order'], ['gen']*T)
    dg = ['gen']*T; ac = p['alpha_c']; ak = p['alpha_p'][0]; oth = sum(p['alpha_p'])-ak
    out = {k: [] for k in ('oma', 'noma', 'rsmaA1', 'rsmaA2')}
    for P in PsdB:
        r = 10**(P/10)*p['g']
        out['oma'].append(_sum_cdf(np.inf, 0, r, p['g_oma'], dl, p))
        out['noma'].append(_sum_cdf(p['a1'], p['a2'], r, p['g_noma'], dl, p))
        out['rsmaA1'].append(_sum_cdf(ac, 1-ac, r, p['gc_th'], dg, p))
        out['rsmaA2'].append(_sum_cdf(ak, oth, r, p['gp_th'], dg, p))
    out = {k: np.array(v) for k, v in out.items()}
    out['rsmaLo'] = np.maximum(out['rsmaA1'], out['rsmaA2'])
    out['rsmaUp'] = np.minimum(out['rsmaA1']+out['rsmaA2'], 1)
    return out

PAPER = {1: dict(Ps=[0, 5, 10], oma=[.30, .072, .020], noma=[.26, .058, .0145], rsma=[.28, .064, .017]),
         3: dict(Ps=[-10, -5, 0, 5, 10], oma=[np.nan, .55, 8e-3, 9e-5, 2.1e-6],
                 noma=[np.nan, .085, 1.8e-3, 1.9e-5, 4e-7], rsma=[.40, 1.6e-2, 2.5e-4, 3.5e-6, 7e-8])}

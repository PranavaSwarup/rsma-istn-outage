import sys, json, numpy as np, matplotlib
matplotlib.use('Agg'); import matplotlib.pyplot as plt
sys.path.insert(0, sys.argv[1]); from istn import *
outdir = sys.argv[2]
PsdB = np.arange(-20, 10.01, 2.5); N = int(sys.argv[3]) if len(sys.argv) > 3 else 4_000_000
cO, cN, cR = '#e01a1a', '#1abf1a', '#1a1ae6'
results = {}
for name, kw in (('fig4', dict(preset='fig4')), ('physical', dict(order='first', extra_gain_dB=0))):
    p = params(**kw); results[name] = {}
    fig, ax = plt.subplots(figsize=(7.2, 5.4))
    for T, mk in ((1, 'o'), (3, 's')):
        A = analytic(PsdB, T, p); S = mc(PsdB, T, N, p)
        results[name][T] = {'analytic': {k: v.tolist() for k, v in A.items()}, 'mc': {k: v.tolist() for k, v in S.items()}}
        nz = lambda v: np.where(np.asarray(v) > 0, v, np.nan)
        ax.semilogy(PsdB, nz(A['oma']), '-', c=cO, lw=1.4); ax.semilogy(PsdB, nz(A['noma']), '-', c=cN, lw=1.4)
        ax.semilogy(PsdB, nz(A['rsmaUp']), '-', c=cR, lw=1.4); ax.semilogy(PsdB, nz(A['rsmaLo']), '--k', lw=1.1)
        for key, col in (('oma', cO), ('noma', cN), ('rsma', cR)):
            ax.semilogy(PsdB, nz(S[key]), mk, mfc='none', c=col, ms=7)
            ax.semilogy(PAPER[T]['Ps'], PAPER[T][key], 'x', c=col, ms=10, mew=1.8)
    ax.set_xlim(-20, 10); ax.set_ylim(1e-8, 1.5); ax.grid(True, which='both', alpha=.3)
    ax.set_xlabel('$P_s$ (dBW)'); ax.set_ylabel('Outage probability')
    ax.set_title(f"Weak-user OP, {name}: order '{p['order']}', +{p['extra_gain_dB']:.2f} dB")
    from matplotlib.lines import Line2D as L
    ax.legend([L([], [], marker='o', ls='', mfc='none', c='k'), L([], [], marker='s', ls='', mfc='none', c='k'),
               L([], [], marker='x', ls='', c='k', ms=9), L([], [], c=cO), L([], [], c=cN), L([], [], c=cR), L([], [], ls='--', c='k')],
              ['Sim T=1', 'Sim T=3', 'Paper Fig. 4 (read off)', 'OMA', 'NOMA', 'RSMA upper', 'RSMA lower'], loc='lower left', fontsize=9)
    fig.tight_layout(); fig.savefig(f'{outdir}/fig4_{name}.png', dpi=160); plt.close(fig)
# imperfections ([12]): wide power range so the I-SIC error floor is visible
Ps2 = np.arange(-10, 40.01, 5.0); T = 3
fig, ax = plt.subplots(figsize=(7.2, 5.4)); imp = {}
cases = (('ideal (Hu et al.)', {}, '-o'), ('HI $\\lambda$=0.141', dict(lambda_hi=0.1*np.sqrt(2)), '-s'),
         ('I-SIC $\\Omega_I$=-20 dB', dict(isic=1, Omega_I_dB=-20), '-^'), ('I-SIC $\\Omega_I$=-10 dB', dict(isic=1, Omega_I_dB=-10), '-v'),
         ('I-SIC $\\Omega_I$=0 dB', dict(isic=1, Omega_I_dB=0), '-d'))
for lab, kw, st in cases:
    S = mc(Ps2, T, 2_000_000, params(**kw)); imp[lab] = {k: S[k].tolist() for k in ('noma', 'noma_n')}
    ax.semilogy(Ps2, np.where(S['noma'] > 0, S['noma'], np.nan), st, c=cO, mfc='none', label='far, '+lab)
    ax.semilogy(Ps2, np.where(S['noma_n'] > 0, S['noma_n'], np.nan), st, c='#1a4de6', mfc='none', label='near, '+lab)
ax.set_ylim(1e-6, 1.5); ax.grid(True, which='both', alpha=.3); ax.legend(fontsize=7.5, loc='lower left', ncol=2)
ax.set_xlabel('$P_s$ (dBW)'); ax.set_ylabel('Outage probability'); ax.set_title('HARQ-CC NOMA, T = 3: imperfections from ref. [12]')
fig.tight_layout(); fig.savefig(f'{outdir}/noma_imperfections.png', dpi=160); plt.close(fig)
results['imperfections'] = {'Ps': Ps2.tolist(), **imp}; results['PsdB'] = PsdB.tolist()
json.dump(results, open(f'{outdir}/results.json', 'w'), indent=1)
print('done')

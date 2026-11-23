# NOMA vs OMA outage: 2 users, single transmission, Shadowed-Rician

Downlink outage probability of **NOMA** and **OMA (TDMA)** for one weak and one strong user, computed two ways:

- **Analysis**: closed-form expressions, no randomness.
- **Simulation**: Monte Carlo, drawing random channels and counting failures.

The channel and default parameters are taken from our RSMA-ISTN work (Hu et al., IEEE TVT 2025, average shadowing). Unlike that paper, this uses a **single transmission (T = 1)** and no HARQ. The structure follows Sharma et al., *"Performance analysis of downlink NOMA over η–μ and κ–μ fading channels"*, IET Commun. 2020, reduced to M = 2 users.

## Run

```matlab
main          % prints thresholds + a table, draws Fig 1-4, saves PNGs to figures/
```

Change any value in `params.m` (powers a₁/a₂, rates R₁/R₂, channel b/m/Ω, link budget g, Ps range, N) and run `main` again. No toolboxes are needed, and the code also runs in GNU Octave.

## Notation (same as the RSMA-ISTN project)

| Symbol | Meaning | Default |
|---|---|---|
| ρ = Ps·g | transmit SNR including the link budget | g = 1.186 |
| x = \|h\|² | channel gain; x_w = min(x₁,x₂) is the weak user, x_s = max is the strong user | |
| a₁, a₂ | NOMA power shares, weak > strong | 0.7, 0.3 |
| R₁, R₂ | target rates | 0.728, 0.728 |
| γth = 2^R − 1 | NOMA threshold | 0.656 |
| 2^(2R) − 1 | OMA threshold (each user gets half the time) | 1.743 |
| θ = a₁/a₂ | weak user's SINR ceiling | 2.333 |
| F(y) | Shadowed-Rician CDF of one gain | |

## Equation → code map

| Step | Expression | File |
|---|---|---|
| 1 | ρ = Ps·g | `outage_analysis.m`, `outage_simulation.m` |
| 3 | γ₁ = a₁ρx_w/(a₂ρx_w+1), γ₂→₁ = a₁ρx_s/(a₂ρx_s+1), γ₂ = a₂ρx_s | `outage_simulation.m` |
| 4 | OMA: γ = ρx | `outage_simulation.m` |
| 5 | γth = 2^R − 1, γth^OMA = 2^(2R) − 1 | `params.m` (derived values) |
| 6 | weak bar y_w = γth,1 / (ρ(a₁ − γth,1·a₂)), valid only if γth,1 < θ | `outage_analysis.m` |
| 7 | strong bar y_s = max(y_w, γth,2/(ρa₂)) | `outage_analysis.m` |
| 8 | weak = 1 − (1 − F(y))², strong = F(y)² | `outage_analysis.m` |
| 9 | F(y) = (λ/β) Σ cₙ P(n+1, βy), cₙ₊₁ = cₙ(m+n)/(n+1)·(δ/β) | `sr_cdf.m` |
| 11 | h = A·e^{jφ} + Z, A² ~ Gamma(m, Ω/m), Z ~ CN(0, 2b) | `sr_gain.m`, `gamma_core.m` |

## Figures

| File | Content |
|---|---|
| `fig1_analysis_noma_vs_oma.png` | NOMA vs OMA, analysis only (lines + squares) |
| `fig2_simulation_noma_vs_oma.png` | NOMA vs OMA, simulation only (stars) |
| `fig3_noma_analysis_vs_simulation.png` | NOMA: analysis vs simulation plus relative gap \|sim − ana\|/ana |
| `fig4_oma_analysis_vs_simulation.png` | OMA: analysis vs simulation plus relative gap |

## Results at default settings

| Ps (dBW) | NOMA weak | OMA weak | NOMA strong | OMA strong |
|---|---|---|---|---|
| 0 | 0.826 | 0.934 | 0.725 | 0.552 |
| 10 | 0.0639 | 0.0909 | 3.9e-3 | 2.2e-3 |
| 20 | 5.1e-3 | 6.9e-3 | 1.9e-5 | 1.2e-5 |

- **NOMA helps the weak user and costs the strong user** compared with OMA. This is the usual NOMA trade-off, the same one we saw in the RSMA-ISTN project.
- **Analysis and simulation agree to within about 1%** wherever the outage is above 10⁻³.
- **The larger gaps (up to about 14%) at 20 dBW for the strong user are Monte Carlo noise.** An outage of 2×10⁻⁵ with N = 10⁶ means only about 20 failed trials. Raise `p.N` to 10⁷ to shrink the gap.

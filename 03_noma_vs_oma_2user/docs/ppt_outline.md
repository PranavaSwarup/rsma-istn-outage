# PPT build guide: NOMA vs OMA outage (2 users, T = 1, Shadowed-Rician)

Use this to build the deck in any slide tool. Each slide lists its **title**, **on-slide content**, the **equations** (written in LaTeX so they can be pasted into an equation editor), the **visual**, and **speaker notes**.

**Style suggestions:**
- Same look as the earlier RSMA-ISTN deck: light background, navy titles, a small blue section tag above each title.
- One idea per slide, with the equation in a boxed card.
- Colours: weak user blue (#0072BD), strong user orange (#D95319). NOMA solid lines, OMA dashed. Analysis = line + square, simulation = star.
- Footer: "Sharma et al. (IET Commun. 2020) + Hu et al. (IEEE TVT 2025) · NOMA vs OMA outage · page n".

Figures are in `figures/` in the repo: fig1–fig4.

---

## Slide 1: Title
- **Title:** Outage Probability of Downlink NOMA vs OMA over Shadowed-Rician Fading
- **Subtitle:** 2 users, single transmission: analysis and Monte Carlo simulation
- **Footer:** Project elective under Prof. Priyanka Das, IIIT Bangalore; team names; date

## Slide 2: What was asked and what we did
**Bullets:**
- Understand the SINR expressions of OMA and NOMA.
- Derive the outage probability of both.
- Implement both: analysis (closed form) and simulation (Monte Carlo).

**Scope:**
- Structure follows Sharma et al. 2020 (η–μ / κ–μ NOMA paper), reduced to 2 users.
- Channel and parameters come from our RSMA-ISTN work (Shadowed-Rician).
- Single transmission (T = 1).

**Speaker notes:** We kept the channel of our earlier satellite paper so results are comparable, and dropped HARQ to keep the expressions clean.

## Slide 3: System model
**Visual:** a transmitter on the left. A near/strong user (orange) sits close; a far/weak user (blue) sits farther away. Arrows labelled h₂ and h₁.

**Equations:**
```latex
s=\sqrt{a_1P_s}\,s_1+\sqrt{a_2P_s}\,s_2,\qquad y_k=G_k h_k s+n_k,\; n_k\sim\mathcal{CN}(0,N_0)
\rho=P_s\,g,\quad g=\frac{G_k^2}{N_0},\qquad x_k=|h_k|^2
```

**Bullets:**
- a₁ > a₂: the weak user gets more power.
- Perfect CSI and perfect SIC.
- x_w = min(x₁,x₂) and x_s = max(x₁,x₂).

## Slide 4: Parameters (table)

| Parameter | Value | Source |
|---|---|---|
| b, m, Ω (Shadowed-Rician, average shadowing) | 0.126, 10.1, 0.835 | Hu et al. |
| g (link budget) | 1.186 (0.74 dB) | Hu et al. |
| a₁, a₂ | 0.7, 0.3 | Hu et al. NOMA setting |
| R₁, R₂ | 0.728, 0.728 bit/s/Hz | Hu et al. equal-rate setting |
| Ps range | −20 to 20 dBW | ours |
| Trials N | 10⁶ | ours |

**Speaker notes:** All of these are variables in `params.m`, so we can change any of them live.

## Slide 5: NOMA SINRs
**Equations:**
```latex
\gamma_1=\frac{a_1\rho x_w}{a_2\rho x_w+1}\qquad
\gamma_{2\to1}=\frac{a_1\rho x_s}{a_2\rho x_s+1}\qquad
\gamma_2=a_2\rho x_s
```

**Visual:** a two-step SIC flow for the strong user: "decode s₁ → subtract → decode s₂".

**Bullet:** SINR = wanted ÷ (interference + 1).

**Ceiling:**
```latex
\theta = a_1/a_2 = 2.33
```

## Slide 6: OMA SINRs
**Equation:**
```latex
\gamma^{\rm OMA}_w=\rho x_w,\qquad \gamma^{\rm OMA}_s=\rho x_s
```

**Bullets:**
- TDMA: each user transmits alone for half the time at full power.
- No interference, so no ceiling.

## Slide 7: From target rate to threshold
**Equations:**
```latex
\log_2(1+\gamma)<R\;\Rightarrow\;\gamma_{th}=2^{R}-1=0.656
\tfrac12\log_2(1+\gamma)<R\;\Rightarrow\;\gamma_{th}^{\rm OMA}=2^{2R}-1=1.743
```

**Speaker notes:** OMA needs a higher SINR because it only uses half the time.

## Slide 8: SINR condition → bar on the channel gain (key algebra)
**Equations (show line by line):**
```latex
\frac{a_1\rho x}{a_2\rho x+1}<\gamma_{th,1}
\iff a_1\rho x<\gamma_{th,1}a_2\rho x+\gamma_{th,1}
\iff \rho x\,(a_1-\gamma_{th,1}a_2)<\gamma_{th,1}
\iff x<y_w=\frac{\gamma_{th,1}}{\rho\,(a_1-\gamma_{th,1}a_2)}
```

**Warning callout:** valid only if a₁ > γth,1·a₂ (that is, γth,1 < θ). Otherwise the weak user is in outage at any power.

## Slide 9: All the bars (table)

| Case | Bar on x | ρ × bar |
|---|---|---|
| NOMA weak | γth,1/(ρ(a₁−γth,1a₂)) | 1.305 |
| NOMA strong, step A | same | 1.305 |
| NOMA strong, step B | γth,2/(ρa₂) | 2.188 |
| OMA weak | (2^(2R₁)−1)/ρ | 1.743 |
| OMA strong | (2^(2R₂)−1)/ρ | 1.743 |

## Slide 10: Strong user, the larger bar binds
**Equation:**
```latex
\{x_s<y_A\}\cup\{x_s<y_B\}=\{x_s<\max(y_A,y_B)\},\qquad
y_s=\max\!\Big(\frac{\gamma_{th,1}}{\rho(a_1-\gamma_{th,1}a_2)},\frac{\gamma_{th,2}}{\rho a_2}\Big)
```

**Visual:** a small table with x_s = 0.9, 1.5, 2.0 against bars 1.10 and 1.84 (at ρ = 1.186), showing ✅/❌ for each step. Only 2.0 passes both.

## Slide 11: Outage of the weak and strong user (ordering)
**Equations:**
```latex
\Pr(x_s<y)=F(y)^2,\qquad \Pr(x_w<y)=1-\big(1-F(y)\big)^2
```

**Speaker notes:**
- Strong user: it fails only if both draws are below y.
- Weak user: it fails unless both draws are above y.

## Slide 12: Shadowed-Rician CDF
**Equations:**
```latex
f(x)=\lambda e^{-\beta x}\,{}_1F_1(m;1;\delta x)
\lambda=\tfrac{1}{2b}\big(\tfrac{2bm}{2bm+\Omega}\big)^m,\;\beta=\tfrac1{2b},\;\delta=\tfrac{\Omega}{2b(2bm+\Omega)}
F(y)=\frac{\lambda}{\beta}\sum_{n=0}^{\infty}c_n\,P(n+1,\beta y),\quad c_n=\frac{(m)_n}{n!}\Big(\frac{\delta}{\beta}\Big)^n
```

**Bullets:**
- Expand ₁F₁ as a series, integrate term by term, and use the incomplete gamma function.
- δ/β = 0.247, so the series converges fast (about 35 terms give 10⁻¹²).

## Slide 13: Final closed-form outage (summary card)

| | Weak | Strong |
|---|---|---|
| NOMA | 1 − (1 − F(y_w))² | F(y_s)² |
| OMA | 1 − (1 − F((2^(2R₁)−1)/ρ))² | F((2^(2R₂)−1)/ρ)² |

## Slide 14: Analysis vs simulation, what each means

| | Analysis | Simulation |
|---|---|---|
| How | evaluate the closed forms at each ρ | draw 10⁶ channel pairs, compute SINRs, count γ < γth |
| Output | smooth curve (line + square) | points (stars) |
| Purpose | theory | independent check of the theory |

**Sampling equation:**
```latex
h=A e^{j\phi}+Z,\quad A^2\sim{\rm Gamma}(m,\Omega/m),\;\phi\sim\mathcal U[0,2\pi),\;Z\sim\mathcal{CN}(0,2b)
```

## Slide 15: Fig 1, NOMA vs OMA (analysis)
- **Visual:** `fig1_analysis_noma_vs_oma.png`
- **Takeaway:** NOMA lowers the weak user's outage and raises the strong user's outage compared with OMA. This is the NOMA trade-off.

## Slide 16: Fig 2, NOMA vs OMA (simulation)
- **Visual:** `fig2_simulation_noma_vs_oma.png`
- **Takeaway:** the simulation shows the same ordering without using any formula.

## Slide 17: Fig 3, NOMA analysis vs simulation
- **Visual:** `fig3_noma_analysis_vs_simulation.png`
- **Takeaway:** the gap is under 1% above 10⁻³ outage. Larger gaps at 20 dBW are Monte Carlo noise (an outage of about 2×10⁻⁵ means only about 20 failures in 10⁶ trials).

## Slide 18: Fig 4, OMA analysis vs simulation
- **Visual:** `fig4_oma_analysis_vs_simulation.png`
- **Takeaway:** same agreement as Fig 3, which confirms the threshold 2^(2R) − 1.

## Slide 19: Numbers (table)

| Ps (dBW) | NOMA weak | OMA weak | NOMA strong | OMA strong |
|---|---|---|---|---|
| 0 | 0.826 | 0.934 | 0.725 | 0.552 |
| 10 | 0.0639 | 0.0909 | 3.9e-3 | 2.2e-3 |
| 20 | 5.1e-3 | 6.9e-3 | 1.9e-5 | 1.2e-5 |

## Slide 20: Code map
**Table:**

| File | Role | Steps |
|---|---|---|
| `params.m` | every setting, plus derived thresholds | 1, 5 |
| `sr_cdf.m` | closed-form CDF | 9 |
| `sr_gain.m` / `gamma_core.m` | channel draws | 11 |
| `outage_analysis.m` | analysis | 6–10 |
| `outage_simulation.m` | simulation | 3, 4, 11 |
| `main.m` | figures | — |

**Optional:** a code card showing the 3 SINR lines from `outage_simulation.m`.

## Slide 21: Conclusions and next steps
**Bullets:**
- Closed-form outage matches the simulation for both NOMA and OMA.
- NOMA helps the weak user, OMA helps the strong user (at a₁ = 0.7 and equal rates).
- The weak user's NOMA outage hits a floor if γth,1 ≥ a₁/a₂.

**Next steps:**
- M > 2 users (order statistics).
- η–μ / κ–μ fading as in Sharma et al.
- RSMA on the same framework.
- Adding HARQ back (T > 1).

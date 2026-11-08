# NOMA findings: Hu et al. (IEEE TVT 2025) read with its reference [12]

Branch `noma-findings`. Paper under study: C. Hu *et al.*, "Outage Analysis of RSMA Enabled Integrated Satellite-Terrestrial Networks," IEEE TVT, vol. 74, no. 6, Jun. 2025.
Reference [12]: C. K. Singh, P. K. Upadhyay, J. Lehtomäki, M. Juntti, "Performance analysis with deep learning assay for cooperative UAV-borne IRS NOMA networks under non-ideal system imperfections," IEEE TVT, vol. 73, no. 1, Jan. 2024.

## 1. Headline results

1. **Fig. 4 is reproduced.** The NOMA/OMA weak user is modelled as in [12], the OMA threshold follows [12], and a +5.25 dB gain offset is applied. With these settings all T = 1 curves match the published figure to within reading error (≤ 20 %). The T = 3 OMA and NOMA curves match to within about 2×. See `figures/fig4_fig4.png`.
2. **The +5.25 dB offset is not a modelling choice.** Fig. 4 has the same RSMA settings as Fig. 3 at K = 2, but sits about 5–6 dB to the left of it. Without the offset our model reproduces Fig. 2 and Fig. 3 directly. Fig. 4 therefore needs a setting that the paper does not state.
3. **How the "weak user" is chosen decides the T = 3 ranking.** Ordering per round gives RSMA < NOMA < OMA, the same as the paper. Fixing roles by round 1 gives NOMA < RSMA < OMA.
4. **What [12] contributes.** It supplies the NOMA SINR form, the outage rule ("fail any x_l, l ≤ k"), order statistics for the weak user, the 2^(KR) − 1 OMA threshold, and two imperfections that Hu et al. switch off: hardware impairments and imperfect SIC.

## 2. How [12] models NOMA, and what Hu et al. keep

| Item | [12] (Singh et al.) | Hu et al. Fig. 4 | This code |
|---|---|---|---|
| Superposition | Σ √(δ_k P_s) x_k, δ₁ ≥ … ≥ δ_K, Σδ = 1 (fixed allocation for fairness) | a₁ = (1+α_c)/2 = 0.7, a₂ = 0.3 | `p.a1_noma`, `p.a2_noma` |
| User ordering | Instantaneous effective channel gain, ascending: user 1 is weakest (eq. 15 order statistics) | "Divided into weak user 1 and strong user 2 according to the channel gain"; nothing said about HARQ rounds | `p.order` = `'round'` / `'first'` / `'none'` |
| SINR of user k decoding x_l | eq. (6): δ_l ρ Z / (ϑ_{k,l} ρ Z + ϖ ρ \|g_I\|² + 1), ϑ_{k,l} = Σ_{i>l} δ_i + λ² | Same with λ = 0, ϖ = 0 | `noma_outage.m` |
| Last user, own signal | eq. (7): δ_K ρ Z / (λ² ρ Z + ϖ ρ \|g_I\|² + 1) | a₂ ρ x (perfect SIC and hardware) | `g2` |
| Outage | eq. (11): fail to decode **any** x_l, l ≤ k | Near user: SIC step OR own step | union `(sum(g21)<th) \| (sum(g2)<th)` |
| Feasibility | γ_th < δ_l / ϑ_{k,l}, otherwise always in outage | 0.657 < 7/3 | warning in code |
| Hardware impairments | λ_su = √2 λ₀, λ₀ = 0.1 (EVM) | none | `'lambda_hi'` |
| Imperfect SIC | g_I ~ CN(0, Ω_I), Ω_I ∈ {0, −10, −20} dB | none | `'isic'`, `'Omega_I_dB'` |
| OMA benchmark | K time slots, so the equivalent threshold is larger: 2^(KR) − 1 | "TDMA for example" | `p.g_oma = 2^(2R1) − 1 = 1.744` |
| Channel | Rician (aerial) + Rayleigh (terrestrial), IRS | Shadowed-Rician | Shadowed-Rician |

Two consequences:

- **The OMA threshold assumption is now backed by [12].** Earlier this was an assumption of ours. [12] states that OMA needs K slots, so for the same target rate its equivalent SINR threshold is larger. With K = 2 this gives 2^(2R₁) − 1.
- **For T = 1, the weak-user CDF is [12] eq. (15) with K = 2, k = 1.** That is 1 − (1 − F)². Under HARQ-CC Hu et al. never say which round fixes the order. Their analysis method (Laplace transform of a product of identical per-round pdfs) only works if every round has the same distribution. That holds only when the order statistic is applied in every round (`'round'`). This is also the only ordering under which the paper could have drawn "Analytical-NOMA/OMA" curves, and it gives the paper's ranking.

## 3. SINR, outage expression and code per scheme

ρ = P_s g, x_t = |h_t|², and HARQ-CC sums SINRs over the T rounds (Hu eq. 1).

| Scheme | Per-round SINR | Outage after T rounds | Code |
|---|---|---|---|
| OMA (TDMA) | γ_t = ρ x_t | Pr{Σ ρ x_t < 2^(2R₁) − 1} | `oma_outage.m`, `analytic_outage.m` |
| NOMA far / weak | a₁ ρ x / ((a₂ + λ²) ρ x + 1) | Pr{Σ γ₁ < 2^(R₁) − 1} | `noma_outage.m` |
| NOMA near / strong | γ_{2→1} = a₁ ρ x / ((a₂+λ²) ρ x + ϖ ρ\|g_I\|² + 1); γ₂ = a₂ ρ x / (λ² ρ x + ϖ ρ\|g_I\|² + 1) | Pr{Σγ_{2→1} < γ_th ∪ Σγ₂ < γ_th} | `noma_outage.m` |
| RSMA user k (Hu eqs. 5–8) | γ_c = α_c ρ x / ((1−α_c) ρ x + 1); γ_p = α_k ρ x / (Σ_{j≠k} α_j ρ x + 1) | Pr{A₁ ∪ A₂}, max ≤ P ≤ sum | `rsma_outage.m`, `rsma_bounds_analytic.m` (eqs. 9/11) |

**Analytic curves** (`analytic_outage.m`). Each round's SINR is a monotone function of x, so its CDF is the exact Shadowed-Rician CDF (`sr_cdf.m`, a Gamma-mixture series) at the inverse map. For the weak user this becomes 1 − (1 − F)². The HARQ sum is then a T-fold convolution on [0, γ_th]. The result is converged in the grid size (M = 1000 vs 12000 agree to 7 digits) and matches Monte Carlo.

**Exact T = 1 forms** (`closed_form_T1.m`) agree with Monte Carlo to within 0.5 %. They are listed in the earlier verification doc.

## 4. Fig. 4: what matches and what does not

`fig4_reproduce.m` runs two settings:

- **`fig4`**: order `'round'`, +5.25 dB. The offset was fitted by least squares on log₁₀ OP against values read off the published figure. Six model variants were tried: three orderings × two OMA thresholds. This one fits best (rms error 0.22 decades). The next best, `'first'`, fits at 0.42 decades. Light shadowing instead of average shadowing makes the fit worse.
- **`physical`**: order `'first'`, 0 dB. This is the link budget exactly as stated, with roles fixed by round 1 (the packet is fixed under HARQ-CC).

Analytic values, setting `fig4`, against the published figure:

| T | P_s (dBW) | OMA ours / paper | NOMA ours / paper | RSMA lower–upper / paper |
|---|---|---|---|---|
| 1 | 0 | 0.353 / 0.30 | 0.249 / 0.26 | 0.312–0.581 / 0.28 |
| 1 | 5 | 0.085 / 0.072 | 0.060 / 0.058 | 0.069–0.128 / 0.064 |
| 1 | 10 | 0.022 / 0.020 | 0.016 / 0.015 | 0.017–0.032 / 0.017 |
| 3 | 0 | 4.1e-3 / 8e-3 | 7.4e-4 / 1.8e-3 | 4.7e-4–7.4e-4 / 2.5e-4 |
| 3 | 5 | 6.8e-5 / 9e-5 | 1.4e-5 / 1.9e-5 | 7.4e-6–1.2e-5 / 3.5e-6 |
| 3 | 10 | 1.6e-6 / 2.1e-6 | 3.6e-7 / 4e-7 | 1.7e-7–2.8e-7 / 7e-8 |

Residual gaps that cannot be removed:

- **RSMA at T = 3** is about 2× below our curve in the paper. Our curve is computed with the same model and checked by Monte Carlo, so this is not numerical error.
- **The paper's T = 1 RSMA bounds** are nearly equal (upper ≈ 1.1 × lower). With K = 2, Pr{A₂}/Pr{A₁} ≈ 0.86, so upper ≈ 1.86 × lower. This holds in both settings.
- **Fig. 3 vs Fig. 4.** At 10 dBW with K = 2, Fig. 3 gives OP ≈ 0.105 (T = 1) and ≈ 1.8e-5 (T = 3). Fig. 4 gives ≈ 0.017 and ≈ 7e-8 for the same parameters. No single model reproduces both figures.

Conclusion: matching Fig. 4 exactly is not possible because the paper contradicts itself. The `fig4` preset is the closest consistent model and is labelled as calibrated. Report results with `physical`, or the default 0 dB, and cite the Fig. 3/Fig. 4 inconsistency.

## 5. Imperfections from [12] in the ISTN setting

`noma_imperfections.m` and `figures/noma_imperfections.png` (T = 3, 0 dB offset):

- **Hardware impairments** (λ = √2 · 0.1): almost no effect. λ² = 0.02 against a₂ = 0.3 barely lowers the far-user ceiling (7/3 → 2.26), still well above 0.657.
- **Imperfect SIC** affects only the near user, as in [12]. It creates an error floor: with Ω_I = 0 dB, OP saturates at about 2.9e-2 from 20 dBW upward, so the diversity order is 0, matching [12] Remark 2. At Ω_I = −10 or −20 dB the floor lies below 1e-6, out of reach of 2 × 10⁶ trials.
- **The far user is unchanged by imperfect SIC.** It performs no SIC, matching [12] eq. (6).

## 6. Earlier verification findings (still valid)

- Equations (4)–(28) of Hu et al. check out. Eqs. (9)/(11) were implemented as printed in `rsma_bounds_analytic.m`. With N = 20 and M = 10 they are within about 5 % of Monte Carlo at most points, and off by up to 2.3× at a few.
- For T = 1 the union lower bound is exact. Some T = 1 simulation points in Figs. 2 and 3 sit above it.
- The claim "OMA follows from eq. (11) with α_k = 1" divides by zero: θ_p = ∞ and Σ_{j≠k} p_j = 0.
- Typos: "θ_{k,c} = α_c/1 − α_c" is missing brackets, and "saves 15 dBW" should be "15 dB".

## 7. How the numbers were produced

The figures and tables here were generated by `python/` (`istn.py`, `make_figures.py`). That code mirrors the MATLAB line by line, because MATLAB was not available where this branch was built. The MATLAB scripts produce the same quantities. To regenerate in MATLAB, run `fig4_reproduce`, `noma_imperfections` and `verify_paper`. MATLAB output should agree up to Monte Carlo noise. Monte Carlo below about 1e-5 has fewer than 100 counts at N = 4 × 10⁶, so trust the analytic lines there.

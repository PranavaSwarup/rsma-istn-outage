# Downlink NOMA vs OMA outage: step-by-step derivation

**Setup:** 2 users, single transmission (T = 1), Shadowed-Rician channel. Notation is the same as our RSMA-ISTN project.
**Defaults:** a₁ = 0.7, a₂ = 0.3, R₁ = R₂ = 0.728, g = 1.186, b = 0.126, m = 10.1, Ω = 0.835.

---

## Step 0: System model and assumptions
- **Network:** 1 transmitter (satellite/BS) and 2 single-antenna users.
- **Channel:** Shadowed-Rician gains x₁, x₂, i.i.d., perfect CSI.
- **Receivers:** perfect SIC for NOMA, no retransmission (T = 1).
- **NOMA power:** weak user gets a₁, strong user gets a₂, with a₁ > a₂ and a₁ + a₂ = 1.
- **Target rates:** R₁ for the weak user, R₂ for the strong user.

## Step 1: Received signal and transmit SNR
Transmitted signal:
s = √(a₁Ps)·s₁ + √(a₂Ps)·s₂

Signal at user k:
y_k = G_k·h_k·s + n_k, with n_k ~ CN(0, N₀)

Shorthands used from here on:
- **ρ = Ps·g**, where g = G_k²/N₀ = 1.186 (0.74 dB)
- **x_k = |h_k|²**

The received SNR is ρ·x.

## Step 2: Ordering the users
x_w = min(x₁, x₂) is the weak (far) user. x_s = max(x₁, x₂) is the strong (near) user.

## Step 3: NOMA SINRs
Rule: **SINR = wanted power ÷ (interfering power + 1)**.

- **Weak user** (decodes s₁ directly, s₂ acts as noise): γ₁ = a₁ρx_w / (a₂ρx_w + 1)
- **Strong user, SIC step A** (decode the weak user's s₁): γ₂→₁ = a₁ρx_s / (a₂ρx_s + 1)
- **Strong user, step B** (remove s₁, decode own s₂): γ₂ = a₂ρx_s

**Ceiling.** As ρ → ∞, γ₁ approaches θ = a₁/a₂ = 2.33. Extra power cannot push it higher.

## Step 4: OMA (TDMA) SINRs
Each user transmits alone, at full power, for half the time:
γ_w^OMA = ρx_w and γ_s^OMA = ρx_s. There is no interference, so there is no ceiling.

## Step 5: Rate → SINR threshold
Outage means the achievable rate is below the target rate.

| Scheme | Rate condition | Threshold |
|---|---|---|
| NOMA | log₂(1+γ) < R | γth = 2^R − 1 = 0.656 |
| OMA | ½·log₂(1+γ) < R | γth^OMA = 2^(2R) − 1 = 1.743 |

## Step 6: SINR condition → bar on x
Rearrange the weak user's outage condition:

a₁ρx/(a₂ρx+1) < γth,1
⇔ a₁ρx < γth,1·a₂ρx + γth,1
⇔ ρx(a₁ − γth,1·a₂) < γth,1
⇔ **x < y_w = γth,1 / (ρ(a₁ − γth,1·a₂))**

This is valid only if a₁ > γth,1·a₂, which is the same as γth,1 < θ. Otherwise the weak user is always in outage. Default check: 0.7 > 0.197 ✓.

| Case | Bar on x | ρ·bar (default) |
|---|---|---|
| NOMA weak | γth,1/(ρ(a₁−γth,1a₂)) | 1.305 |
| NOMA strong, step A | same as y_w | 1.305 |
| NOMA strong, step B | γth,2/(ρa₂) | 2.188 |
| OMA weak | (2^(2R₁)−1)/ρ | 1.743 |
| OMA strong | (2^(2R₂)−1)/ρ | 1.743 |

## Step 7: The strong user must pass both steps
The strong user is in outage if step A fails or step B fails. Both are bars on the same x_s:

{x_s < y_A} ∪ {x_s < y_B} = {x_s < max(y_A, y_B)}

**y_s = max( γth,1/(ρ(a₁−γth,1a₂)), γth,2/(ρa₂) )**

The larger bar binds. By default that is step B: y_s = 2.188/ρ.

A **bar y** is the smallest channel gain needed for a decoding step to succeed.

## Step 8: Outage of an ordered user
Let F(y) = Pr(x < y) be the CDF of one unordered gain.
- **Strong user:** both gains must be below y, so Pr(x_s < y) = F(y)².
- **Weak user:** it fails unless both gains are above y, so Pr(x_w < y) = 1 − (1 − F(y))².

## Step 9: Shadowed-Rician CDF
**PDF:**
f(x) = λ·e^(−βx)·₁F₁(m; 1; δx)

with λ = (1/2b)(2bm/(2bm+Ω))^m, β = 1/(2b), δ = Ω/(2b(2bm+Ω)). Defaults give λ = 0.226, β = 3.968, δ = 0.980.

**9a. Series for the hypergeometric function:**
₁F₁(m;1;δx) = Σₙ (m)ₙ/(n!)²·(δx)ⁿ

**9b. Integrate one term from 0 to y:**
∫₀ʸ xⁿe^(−βx)dx = n!/β^(n+1)·P(n+1, βy)

Here P is the regularised lower incomplete gamma function, `gammainc(β*y, n+1)` in MATLAB.

**9c. Collect the terms:**
**F(y) = (λ/β)·Σₙ cₙ·P(n+1, βy)**, with cₙ = (m)ₙ/n!·(δ/β)ⁿ

- **Recursion:** c₀ = 1 and cₙ₊₁ = cₙ·(m+n)/(n+1)·(δ/β). This avoids overflow.
- **Convergence:** δ/β = 0.247, so about 35 terms give 10⁻¹² accuracy. The code uses 100.

## Step 10: Final expressions (the "analysis")

| Scheme | Weak user | Strong user |
|---|---|---|
| NOMA | 1 − (1 − F(y_w))² | F(y_s)² |
| OMA | 1 − (1 − F((2^(2R₁)−1)/ρ))² | F((2^(2R₂)−1)/ρ)² |

## Step 11: Simulation (Monte Carlo)
1. **Draw a gain:** h = A·e^(jφ) + Z, where A² ~ Gamma(m, Ω/m), φ ~ U(0, 2π), Z ~ CN(0, 2b). Then x = |h|². Check: mean(x) = Ω + 2b = 1.087.
2. **Make the two users:** draw x₁, x₂ for N = 10⁶ trials. Set x_w = min and x_s = max.
3. **Compute SINRs:** for each Ps, set ρ = Ps·g and compute the SINRs from Steps 3–4.
4. **Count failures:**
   - NOMA weak: γ₁ < γth,1
   - NOMA strong: γ₂→₁ < γth,1 OR γ₂ < γth,2
   - OMA: γ < γth^OMA
5. **Outage probability** = failures ÷ N. This uses no bars and no F, so it independently checks Steps 6–10.

## Step 12: Numbers

| Ps (dBW) | NOMA weak ana / sim | NOMA strong ana / sim | OMA weak ana / sim | OMA strong ana / sim |
|---|---|---|---|---|
| 0 | 0.8263 / 0.8266 | 0.7254 / 0.7254 | 0.9339 / 0.9341 | 0.5520 / 0.5520 |
| 10 | 0.0639 / 0.0637 | 3.87e-3 / 3.80e-3 | 0.0909 / 0.0907 | 2.17e-3 / 2.15e-3 |
| 20 | 5.13e-3 / 5.19e-3 | 1.93e-5 / 2.2e-5 | 6.92e-3 / 6.86e-3 | 1.20e-5 / 1.20e-5 |

**Takeaway:** NOMA helps the weak user and costs the strong user compared with OMA.

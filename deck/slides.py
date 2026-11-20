from build import L, gap, C, SCHEME

M = '01_fig4_monte_carlo/'
CF = '02_sinr_closed_form_outage/'
PD = '03_shadowed_rician_pdf/'

S = []

# ===================================================================== opening
S.append(dict(type='title', kicker='RE in Wireless Communication · Prof. Priyanka Das',
  title='OMA vs NOMA vs RSMA over a Shadowed-Rician satellite link: SINRs, code and plots',
  sub='Every formula shown next to the MATLAB lines that compute it. Reproduction and check of Hu et al., “Outage Analysis of RSMA Enabled Integrated Satellite-Terrestrial Networks,” IEEE TVT, vol. 74, no. 6, Jun. 2025; NOMA model from ref. [12] (Singh et al., IEEE TVT 2024).',
  meta='Yash Sultania · Pranava Swarup · Abel B Aliyas · November 2026 · code: github.com/PranavaSwarup/rsma-istn-outage (branches week3-oma-noma-sinr-pdf, 20-nov)',
  notes='''Opening (20 s): "Last time the graphs did not match and the SINR expressions for OMA and NOMA were missing. Today: (1) the channel PDF, simulation against the formula; (2) OMA, NOMA and RSMA one at a time, each as concept, then code next to the equations, then its own plot; (3) the Fig. 4 comparison; (4) why Fig. 4 cannot be matched."
Every code slide: left = actual MATLAB with real line numbers; right = the equation each coloured group implements and which paper equation it is.'''))

S.append(dict(type='theory', kicker='Roadmap', title='The two tasks, and the order we answer them in',
  cols='1fr 1fr',
  cards=[
   dict(h='Task 1 (official)', color=C['B'], b='Rician channel power PDF: simulation vs analysis validation.<br>→ <b>Section 1</b>: the paper\'s channel is <b>Shadowed-Rician</b> (eq. 4). We simulate 10⁶ channels from the physical model and overlay eq. (4).'),
   dict(h='Task 2 (official)', color=C['A'], b='RSMA vs NOMA vs OMA SINR expressions and MATLAB code.<br>→ <b>Sections 2–4</b>: each scheme = concept slide → code ↔ formula slide → its own plot. NOMA SINRs taken from ref. [12], as Hu et al. do.'),
   dict(h='Order of the deck', color=C['C'], b='''<table>
     <tr><th>#</th><th>Section</th><th>Code</th></tr>
     <tr><td>0</td><td>System model, link budget</td><td><code>istn_params.m</code></td></tr>
     <tr><td>1</td><td>Shadowed-Rician channel and its PDF</td><td><code>sr_gain.m</code>, <code>sr_pdf.m</code>, <code>Rician_Dist.m</code></td></tr>
     <tr><td>2</td><td>OMA</td><td><code>oma_outage.m</code></td></tr>
     <tr><td>3</td><td>NOMA</td><td><code>noma_outage.m</code>, <code>order_users.m</code></td></tr>
     <tr><td>4</td><td>RSMA</td><td><code>rsma_outage.m</code></td></tr>
     <tr><td>5</td><td>All three together (Fig. 4)</td><td><code>fig4_reproduce.m</code></td></tr></table>'''),
   dict(h='…then the supporting maths and the findings', color=C['D'], b='''<table>
     <tr><td>6</td><td>Closed-form outage (T = 1), HARQ-CC over T rounds</td><td><code>op_closed_form_T1.m</code>, <code>mc_outage.m</code></td></tr>
     <tr><td>7</td><td>Ref. [12]: how its NOMA SINR becomes ours</td><td><code>isic_floor.m</code></td></tr>
     <tr><td>8</td><td>Why the paper's Fig. 4 cannot be matched</td><td><code>fig4_vs_paper.m</code>, <code>fig4_calibrated.m</code></td></tr>
     <tr><td>9</td><td>Findings, open issues, likely questions</td><td>—</td></tr></table>
     All results in this deck were run in MATLAB R2025b, no toolboxes.'''),
  ],
  notes='''Say: "Two official tasks: the channel PDF check, and the SINR expressions with code for all three schemes. We take them in that order, then put the three schemes together, then explain Fig. 4."
Q: Is this the same model as last time? A: Yes, same parameters; new are the SINR derivations from ref. [12], the closed form, and separate per-scheme plots.'''))

# ===================================================================== section 0: setup
S.append(dict(type='theory', kicker='0 · System model', title='One LEO satellite, two single-antenna users, up to T HARQ-CC rounds',
  cols='1fr 1fr 1fr',
  cards=[
   dict(h='Received SNR per round', color=C['B'], math=[r'\rho = P_s\,g_k,\qquad g_k=\frac{\mathcal{G}_k^2}{N_0}', r'\mathcal{G}_k=\frac{c\sqrt{G_sG_r}}{4\pi f_c d}', r'\text{SNR}_t=\rho\,|h_{k,t}|^2'],
        b='1000 km, 1.55 GHz, 50 MHz, 290 K, 25 dBi + 5 dBi. User at the beam centre (θ = 0, <b>assumed</b>), so G<sub>s</sub> = G<sub>max</sub>.<br><b>g<sub>k</sub> = 1.186 (0.74 dB)</b>; at 5 dBW, ρ = 3.75.'),
   dict(h='Same rate for every scheme', color=C['A'], math=[r'R_c=R_p=\log_2(1+0.4)=0.485', r'R=\tfrac{R_c}{2}+R_p=0.728\ \text{b/s/Hz}'],
        b='Fig. 4 caption: R<sub>1,th</sub> = R<sub>2,th</sub> = R<sub>c,th</sub>/2 + R<sub>p,th</sub>. Each user gets half the common rate plus its private rate.'),
   dict(h='Thresholds that follow', color=C['C'], b='''<table><tr><th>Scheme</th><th>Power split</th><th>SINR target</th></tr>
      <tr><td>RSMA</td><td>α<sub>c</sub>=0.4, α<sub>1</sub>=α<sub>2</sub>=0.3</td><td>0.4 (each stream)</td></tr>
      <tr><td>NOMA</td><td>a<sub>1</sub>=0.7, a<sub>2</sub>=0.3</td><td>2<sup>R</sup>−1 = 0.657</td></tr>
      <tr><td>OMA</td><td>full power, half the time</td><td>2<sup>2R</sup>−1 = 1.744</td></tr></table>
      a<sub>1</sub> = α<sub>c</sub>+α<sub>1</sub> = (1+α<sub>c</sub>)/2 (Fig. 4 caption).'''),
   dict(h='HARQ chase combining (eq. 1)', color=C['D'], math=[r'\mathcal{I}_{i,k}^{T}=\log_2\!\Big(1+\sum_{t=1}^{T}\gamma_{i,k}^{t}\Big)'], b='The same packet is resent; the receiver adds the per-round SINRs. Decoding succeeds once the sum reaches the target.', style='grid-column:span 2'),
   dict(h='Assumptions not in the paper', color=C['E'], b='<ul><li>Beam centre, d = 1000 km for both users</li><li>OMA = TDMA, half the time each</li><li>Weak user across rounds: <code>\'round\'</code> or <code>\'first\'</code> (both shown)</li></ul>'),
  ],
  notes='''Talking points: one satellite, two users, SISO. Everything is in terms of rho = Ps * g_k; g_k = 1.186 comes from the link budget (free-space loss ~ -156 dB, antennas +30 dB, noise floor -127 dBW).
Equal-rate rule: all three schemes deliver 0.728 b/s/Hz per user, so the comparison is fair.
Q: Why 2^(2R)-1 for OMA? A: TDMA gives each user half the time, so to average R it must run at 2R in its slot. Ref. [12] uses the same K-slot argument for its OMA benchmark.
Q: Where does 0.7 come from? A: Converting RSMA to NOMA puts W1 entirely in the common stream, so user 1 gets alpha_c + alpha_1 = 0.4 + 0.3.'''))

S.append(dict(type='code', kicker='0 · Code ↔ formula', title='istn_params.m: every number in one file, tagged [paper] or [ASSUMED]',
  file=M + 'istn_params.m', code=L(M + 'istn_params.m', 8, 10) + gap() + L(M + 'istn_params.m', 16, 16) + gap() + L(M + 'istn_params.m', 38, 39) + gap() + L(M + 'istn_params.m', 42, 45) + gap() + L(M + 'istn_params.m', 51, 53) + gap() + L(M + 'istn_params.m', 56, 58) + gap() + L(M + 'istn_params.m', 63, 63), fs=14.5,
  groups=[
   dict(tag='A', color=C['B'], lines=[8, 9, 10], ref='Hu, Sec. IV (average shadowing)', latex=r'b=0.126,\quad m=10.1,\quad \Omega=0.835', caption='Shadowed-Rician parameters of eq. (4). Mean gain Ω + 2b = 1.087.'),
   dict(tag='B', color=C['A'], lines=[16, 38, 39], lab='lines 16, 38–39', ref='Hu eqs. (3), (5)', latex=r'N_0=\kappa B T,\quad g_k=\frac{\mathcal{G}_k^2}{N_0}=1.186', caption='Link budget. Every SINR in the code uses <code>rho = Ps*p.g</code>.'),
   dict(tag='C', color=C['C'], lines=[42, 43, 44, 45], ref='Fig. 4 caption', latex=r'\alpha_c=0.4,\ \alpha_k=0.3,\ \gamma_{c,th}=\gamma_{p,th}=0.4', caption='RSMA power split and thresholds.'),
   dict(tag='D', color=C['D'], lines=[51, 52, 53, 56, 57, 58], ref='Fig. 4 caption', latex=r'R=\tfrac{R_c}{2}+R_p,\quad a_1=\tfrac{1+\alpha_c}{2},\quad \gamma_{th}^{NOMA}=2^{R}-1', caption='Equal-rate conversion and the NOMA split.'),
   dict(tag='E', color=C['E'], lines=[63], ref='[ASSUMED], backed by [12]', latex=r'\gamma_{th}^{OMA}=2^{2R}-1=1.744', caption='TDMA: half the time, double the in-slot rate.'),
  ],
  notes='''Walk the colours top to bottom.
A: channel parameters straight from Sec. IV. B: link budget, g = 1.186 (0.74 dB). C: RSMA split. D: equal-rate conversion (0.728 b/s/Hz) and NOMA split 0.7/0.3. E: OMA threshold 1.744, our assumption.
Q: Which values are assumptions? A: Only beam centre (theta = 0), the OMA/TDMA interpretation, and the weak-user ordering; every other number is in the paper.'''))

# ===================================================================== section 1: channel
S.append(dict(type='theory', kicker='1 · Channel (Task 1)', title='Shadowed-Rician: a line-of-sight path that is itself partly shadowed, plus scatter',
  img_side=True, img='sr_shape_guide.png', imgh=640, split='44% 56%',
  cards=[
   dict(h='Physical model (Abdi et al., 2003)', color=C['B'], math=[r'h_{k,t}=A\,e^{j\phi}+Z,\quad A^2\sim\text{Gamma}\!\left(m,\tfrac{\Omega}{m}\right),\ Z\sim\mathcal{CN}(0,2b)'],
        b='LoS amplitude A is Nakagami-m (trees, buildings shadow it); Z = many scattered copies. Rayleigh has no LoS, Rician a <i>fixed</i> LoS; Shadowed-Rician lets the LoS fluctuate.'),
   dict(h='Power-gain PDF, Hu eq. (4)', color=C['A'], math=[r'f_{|h_{k,t}|^2}(x)=\lambda e^{-\beta x}\,{}_1F_1(m;1;\delta x)', r'\lambda=\tfrac{1}{2b}\!\left(\tfrac{2bm}{2bm+\Omega}\right)^{m},\ \beta=\tfrac{1}{2b},\ \delta=\tfrac{\Omega}{2b(2bm+\Omega)}'],
        b='λ = 0.226, β = 3.968, δ = 0.980. Mean E|h|² = Ω + 2b = 1.087.'),
   dict(h='How to recognise it on a graph', color=C['C'], b='<ul><li><b>f(0) = λ &gt; 0</b>: deep fades always possible (Rician-power with weak LoS behaves like Rayleigh near 0)</li><li><b>A hump</b> near x ≈ 0.6 from the LoS part (Rayleigh has none)</li><li><b>Shadowing moves the shape</b>: heavy → Rayleigh-like, light → Rician. Average shadowing (the paper\'s) sits between, close to Rician K = 3.3.</li></ul>'),
  ],
  notes='''Say: "The professor called it modified Rician; the paper's name is Shadowed-Rician. It is a Rician channel whose line-of-sight part is not constant but Nakagami-m distributed."
Right plot: all curves scaled to unit mean so only the shape differs. Heavy shadowing (blue) is almost Rayleigh (dashed); light shadowing (yellow) is almost Rician (dotted); the paper's average shadowing (orange) is between.
Q: Why is f(0) not 0? A: That is the power gain |h|^2. Its PDF at 0 equals lambda = 0.226. The ENVELOPE |h| PDF starts at 0 because of the Jacobian 2r.
Q: Where does 1F1 come from? A: For a fixed LoS amplitude |h|^2 is a non-central chi-square (Rician power, has I0). Averaging over the Gamma-distributed LoS power turns the Bessel series into Kummer's 1F1.'''))

S.append(dict(type='code', kicker='1 · Code ↔ formula', title='Simulating h and evaluating eq. (4): sr_gain.m and sr_pdf.m',
  files=[(M + 'sr_gain.m', L(M + 'sr_gain.m', 10, 13)), (PD + 'sr_pdf.m', L(PD + 'sr_pdf.m', 17, 30))], fs=15,
  groups=[
   dict(tag='A', color=C['B'], lines=[10], ref='Nakagami-m LoS', latex=r'A^2\sim\text{Gamma}\big(m,\ \Omega/m\big)', caption='LoS power. <code>gamma_core</code> = Marsaglia–Tsang sampler (core MATLAB; <code>randg</code> needs the Statistics Toolbox).'),
   dict(tag='B', color=C['A'], lines=[11, 12, 13], ref='Abdi et al. 2003', latex=r'h=A e^{j\phi}+Z,\ \ \phi\sim U[0,2\pi),\ Z\sim\mathcal{CN}(0,2b),\ \ x=|h|^2', caption='Random LoS phase, scatter with variance b per real dimension, then |h|². Output is a T × n matrix (rounds × trials).'),
   dict(tag='C', color=C['C'], lines=[17, 18, 19, 20], ref='Hu eq. (4)', latex=r'\lambda,\ \beta=\tfrac{1}{2b},\ \delta=\tfrac{\Omega}{2b(2bm+\Omega)}', caption='The three PDF constants, exactly as printed below eq. (4).'),
   dict(tag='D', color=C['D'], lines=[24, 25, 26, 27, 28, 29, 30], ref='₁F₁ series', latex=r'f(x)=\lambda e^{-\beta x}\sum_{n\ge 0}\frac{(m)_n}{(n!)^2}(\delta x)^n', caption='Kummer series term by term in logs (no overflow); no Symbolic Toolbox needed.'),
  ],
  foot='<b>Checks (your MATLAB):</b> simulated mean 1.0874 vs Ω + 2b = 1.087 · ∫f = 1.0000 · empirical CDF vs closed form: max error 8×10⁻⁴.',
  notes='''Top file draws the channel; bottom file evaluates the formula. The plot on the next slide puts the two on top of each other.
A: LoS power is Gamma with shape m and mean Omega (that is what Nakagami-m amplitude means). B: add random phase and complex Gaussian scatter, take |h|^2.
C/D: eq. (4) written as a power series. (m)_n is the rising factorial.
Q: Why your own Gamma sampler? A: randg needs the Statistics Toolbox, which we don't have; Marsaglia-Tsang is the standard method and the CDF check shows it is right.'''))

S.append(dict(type='code', kicker='1 · Code ↔ formula', title='Rician_Dist.m (Abel): the validation plot, histogram vs eq. (4)',
  file=PD + 'Rician_Dist.m', code=L(PD + 'Rician_Dist.m', 25, 28) + gap() + L(PD + 'Rician_Dist.m', 69, 74) + gap() + L(PD + 'Rician_Dist.m', 92, 93) + gap() + L(PD + 'Rician_Dist.m', 107, 113), fs=13.5, split='58% 42%',
  groups=[
   dict(tag='A', color=C['C'], lines=[25, 26, 27, 28], ref='Hu eq. (4)', latex=r'\beta,\ \delta,\ \lambda,\quad \mathbb{E}|h|^2=\Omega+2b', caption='Same constants as <code>sr_pdf.m</code>.'),
   dict(tag='B', color=C['B'], lines=[69, 70, 71, 73, 74], ref='physical model', latex=r'h=Ae^{j\phi}+Z;\quad r=|h|,\ x=|h|^2', caption='5×10⁵ simulated channels; envelope r and power gain x.'),
   dict(tag='C', color=C['A'], lines=[92, 93], ref='simulation', latex=r'\hat f(x_i)=\frac{\#\{x\in\text{bin } i\}}{N\,\Delta x}', caption="<code>'Normalization','pdf'</code> turns counts into a density, so it can sit on the formula."),
   dict(tag='D', color=C['D'], lines=[107, 108], ref='analysis', latex=r'f_x\ \text{(eq. 4)},\qquad f_r(r)=2r\,f_x(r^2)', caption='Exact PDF; envelope via the Jacobian of x = r².'),
   dict(tag='E', color=C['E'], lines=[111, 112, 113], ref='Hu eq. (7), T = 1', latex=r'P^{out}=\Pr\{x<x_{th}\}=F(x_{th}),\ x_{th}=\tfrac{2.5}{\rho}=0.667', caption='Shaded area under the PDF = one-round RSMA outage at 5 dBW.'),
  ],
  notes='''This is the script behind the PDF figure (next slide).
C is the "simulation" side: a normalised histogram. D is the "analysis" side: eq. (4). If they overlap, eq. (4) is right.
E links the channel to outage: at 5 dBW the RSMA common stream needs x >= 0.667, so outage = area under the PDF left of 0.667 = 0.335.
Q: Why plot the envelope too? A: Optional; it is the same channel seen as an amplitude. "Modified Rician" on the old label just means this envelope, not a different model.
Note: the PCHIP smoothing in Abel's script is cosmetic; the evidence is the raw histogram vs the formula.'''))

S.append(dict(type='plot', kicker='1 · Result (Task 1)', title='Eq. (4) is right: one million simulated channels lie on the formula',
  imgs=[('sr_rician.png', '')], imgh=640, split='70% 30%',
  cards=[
   dict(h='What to read off', color=C['A'], b='<ul><li><b>Right</b>: power gain |h|². Orange circles = simulated histogram; dashed = eq. (4). They coincide.</li><li>f(0) = λ = 0.226 (blue square)</li><li>Mean 1.087 (dotted line)</li><li>Red area: x &lt; 0.667 → T = 1 RSMA outage 0.335 at 5 dBW</li><li><b>Left</b>: envelope |h|, starts at 0, mode r ≈ 0.96</li></ul>'),
   dict(h='Numbers', color=C['C'], b='<table><tr><th>Check</th><th>Expected</th><th>Got</th></tr><tr><td>∫ f</td><td>1</td><td>1.0000</td></tr><tr><td>mean</td><td>1.087</td><td>1.087</td></tr><tr><td>area x &lt; 0.667</td><td>formula 0.3351</td><td>histogram 0.329</td></tr></table>'),
  ],
  notes='''Say: "Simulation and analysis agree at every bin, so the channel model in the code is exactly the paper's eq. (4). This answers task 1."
Point at the red area: this is where the channel connects to outage. One round at 5 dBW fails one time in three.
Q: How many samples? A: 5x10^5 here, 10^6 in sr_pdf_check.m; both agree with the formula.
Backup figure: sr_pdf_validation.png (histogram, log-scale tail, CDF) in 03_shadowed_rician_pdf.'''))

# ===================================================================== section 2: OMA
S.append(dict(type='theory', kicker='2 · OMA', title='OMA (TDMA): no interference, so no ceiling, but double the rate in half the time',
  cols='1fr 1fr',
  cards=[
   dict(h='One shape for every SINR in this deck', color=C['B'], math=[r'\gamma=\frac{\delta\,\rho x}{\vartheta\,\rho x+1},\qquad \text{ceiling } \theta=\frac{\delta}{\vartheta}'],
        b='δ = power share of the stream being decoded, ϑ = share still interfering, +1 = noise (normalised). Decoding succeeds when γ ≥ 2<sup>R</sup> − 1 (Shannon).'),
   dict(h='OMA SINR', color=SCHEME['oma'], math=[r'\gamma_k^{OMA}=\rho\,x_k\quad(\delta=1,\ \vartheta=0)', r'\gamma_{th}^{OMA}=2^{2R}-1=1.744'],
        b='Each user owns a time slot at full power. No interference ⇒ no ceiling: more power always helps.'),
   dict(h='Outage after T rounds', color=C['D'], math=[r'P^{OMA}=\Pr\Big\{\sum_{t=1}^{T}\rho\,x_t<1.744\Big\}'],
        b='At 5 dBW (ρ = 3.75) one round fails when x &lt; 1.744/3.75 = <b>0.465</b>.'),
   dict(h='Weak and strong user', color=C['C'], math=[r'x_{\text{weak}}=\min(x_1,x_2),\quad x_{\text{strong}}=\max(x_1,x_2)'],
        b='T = 1, 5 dBW: F(0.465) = 0.211 ⇒ weak 1 − (1 − 0.211)² = <b>0.378</b>, strong 0.211² = <b>0.045</b>.'),
  ],
  notes='''Start with the common SINR shape: wanted power over (interference + noise). Every later SINR is this formula with a different delta and vartheta.
OMA: delta = 1, vartheta = 0, so SINR = rho*x, no ceiling. The price is the threshold 1.744 instead of 0.657, because each user only has half the time.
Q: Why does OMA lose to NOMA if it has no interference? A: The threshold is 2.7x higher (1.744 vs 0.657); at practical SNRs that costs more than NOMA's interference.'''))

S.append(dict(type='code', kicker='2 · Code ↔ formula', title='oma_outage.m: SNR = ρx per round, summed over T rounds, compared with 2^(2R) − 1',
  file=M + 'oma_outage.m', code=L(M + 'oma_outage.m', 33, 50), fs=15.5,
  groups=[
   dict(tag='A', color=C['B'], lines=[34], ref='Hu eq. (5)', latex=r'P_s=10^{P_s[\mathrm{dBW}]/10}', caption='dBW → watts for every point on the x-axis.'),
   dict(tag='B', color=C['A'], lines=[40, 41], ref='[ASSUMED] ordering', latex=r'x_{\text{weak}}=\min_k x_{k,t},\quad x_{\text{strong}}=\max_k x_{k,t}', caption='Two users\' Shadowed-Rician gains (T × n each); <code>order_users</code> picks weak/strong.'),
   dict(tag='C', color=SCHEME['oma'], lines=[43], ref='OMA SINR', latex=r'\gamma_t^{OMA}=P_s\,g_k\,x_t=\rho\,x_t', caption='No interference term: SINR = SNR.'),
   dict(tag='D', color=C['D'], lines=[44, 45], ref='Hu eq. (1) + outage', latex=r'\mathbb{1}\Big\{\sum_{t=1}^{T}\gamma_t^{OMA}<2^{2R}-1\Big\}', caption='<code>sum(sw,1)</code> = HARQ-CC sum down the rounds; <code>&lt; p.g_oma</code> = outage; outer <code>sum</code> counts failures.'),
   dict(tag='E', color=C['C'], lines=[49, 50], ref='Monte Carlo', latex=r'\hat P^{out}=\frac{\#\text{outages}}{N}', caption='Fraction of failed trials.'),
  ],
  foot='<b>Numbers (5 dBW, ρ = 3.75):</b> x = 0.4 → SNR 1.5 &lt; 1.744 ✗ · x = 0.6 → 2.25 ✓ · T = 1 weak user outage 0.378 (closed form, matches simulation).',
  notes='''Read the loop: draw both users for all T rounds (B), compute the per-round SNR (C), add down the rounds and compare with the threshold (D), count.
The matrix is T rows (rounds) by n columns (trials); sum(.,1) adds down each column, i.e. one packet's rounds.
Q: Where is the time-sharing in the code? A: Only in the threshold 2^(2R)-1 (istn_params line 63); inside its slot the user has full power and no interference.'''))

S.append(dict(type='plot', kicker='2 · Result', title='OMA outage: each extra round buys one more order of slope',
  imgs=[('2_oma_outage.png', '')], imgh=600, split='64% 36%',
  cards=[
   dict(h='What to read off', color=SCHEME['oma'], b='<ul><li>Weak user (circles) above strong user (squares): the weak user has the worse of two channels.</li><li>T = 1 slope 1, T = 3 slope 3 at high power (full diversity, no ceiling).</li><li>Exact check (<code>oma_diversity_exact.m</code>): 20 → 30 dBW the outage falls ×10, ×105, ×1059 for T = 1, 2, 3.</li></ul>'),
   dict(h='Key values, 5 dBW', color=C['C'], b='<table><tr><th></th><th>T = 1</th><th>T = 3</th></tr><tr><td>weak</td><td>0.378</td><td>5.1×10⁻³</td></tr><tr><td>strong</td><td>0.045</td><td>≈ 5×10⁻⁷</td></tr></table>Points below ~10⁻⁶ need more than 2×10⁶ trials and are left off.'),
  ],
  notes='''Say: "With no interference OMA has no SINR ceiling, so every extra round adds one order of diversity: slope 1, 2, 3."
Q: Why are some points missing? A: Zero outages in 2 million trials at that power; we do not plot zeros. The exact OMA formula (sum of T Shadowed-Rician gains) confirms the trend.
T = 3 values use the 'round' ordering (default).'''))

# ===================================================================== section 3: NOMA
S.append(dict(type='theory', kicker='3 · NOMA', title='NOMA: power superposition; the strong user cancels the weak user\'s message first (SIC)',
  cols='1fr 1fr',
  cards=[
   dict(h='Transmit (superposition)', color=SCHEME['noma'], math=[r's=\sqrt{a_1P_s}\,s_1+\sqrt{a_2P_s}\,s_2,\quad a_1=0.7,\ a_2=0.3'],
        b='More power to the user with the worse channel. Both users hear both messages.'),
   dict(h='Weak user (no SIC) — [12] eq. (6) with λ = 0', color=C['A'], math=[r'\gamma_{1}=\frac{a_1\rho x}{a_2\rho x+1},\qquad \theta=\frac{a_1}{a_2}=2.33'],
        b='Decodes its own loud message, treats s₂ as noise. Bar at 5 dBW: x ≥ 0.657 / (3.75·(0.7 − 0.3·0.657)) = <b>0.348</b>.'),
   dict(h='Strong user (SIC) — [12] eqs. (6), (7)', color=C['D'], math=[r'\text{A: }\gamma_{2\to1}=\frac{a_1\rho x}{a_2\rho x+1},\qquad \text{B: }\gamma_{2\to2}=a_2\rho x'],
        b='Step A: decode s₁ (bar 0.348). Step B: subtract it, decode own s₂ cleanly (bar 0.657/(0.3·3.75) = <b>0.584</b>). Perfect SIC assumed.'),
   dict(h='Outage rule — [12] eq. (11)', color=C['E'], math=[r'P_k^{out}=1-\Pr\{\text{decode every }x_l,\ l\le k\}'],
        b='Weak: fails if step on s₁ fails. Strong: fails if <b>A or B</b> fails ⇒ the larger bar (0.584) binds.<br>T = 1, 5 dBW: weak <b>0.267</b>, strong <b>0.080</b>.'),
  ],
  notes='''This is the slide the professor asked for: the NOMA SINR expressions.
They come from ref. [12] (Singh et al.), eq. (6) and (7), with its hardware-impairment level lambda = 0 and perfect SIC, and with its IRS channel replaced by our satellite term rho*x. Hu et al. cite [12] exactly where they set up NOMA.
Weak user ceiling 2.33 is far above 0.657, so full diversity.
Q: Why does the strong user decode the weak user's message? A: It is the louder signal; it must be removed before the quieter own message can be decoded.
Q: Imperfect SIC? A: Section 7: [12] adds a residual term; it creates an error floor for the strong user only.'''))

S.append(dict(type='code', kicker='3 · Code ↔ formula', title='noma_outage.m: weak user capped at a₁/a₂ = 7/3; strong user needs both SIC steps',
  file=M + 'noma_outage.m', code=L(M + 'noma_outage.m', 40, 43) + gap() + L(M + 'noma_outage.m', 50, 64), fs=15,
  groups=[
   dict(tag='A', color=C['E'], lines=[40, 41, 42, 43], ref='ceiling check', latex=r'\gamma_{th}<\theta=\frac{a_1}{a_2}=2.33', caption='If the target were above the ceiling, the weak user would fail at every power.'),
   dict(tag='B', color=C['A'], lines=[52, 53], ref='Hu Fig. 4 text', latex=r'x_{\mathrm{w}}=\min_k|h_{k,t}|^2,\quad x_{\mathrm{s}}=\max_k|h_{k,t}|^2', caption='Two users\' gains; weak = far, strong = near.'),
   dict(tag='C', color=C['C'], lines=[57, 58], ref='[12] eq. (6), λ = 0', latex=r'\gamma_{1}=\frac{a_1\rho x_{\mathrm{w}}}{a_2\rho x_{\mathrm{w}}+1},\ \ \text{out if}\sum_t\gamma_{1,t}<\gamma_{th}', caption='Weak user, s₂ treated as noise.'),
   dict(tag='D', color=C['D'], lines=[60, 61, 62, 63], ref='[12] eqs. (6), (7), (11)', latex=r'\gamma_{2\to1}=\frac{a_1\rho x_{\mathrm{s}}}{a_2\rho x_{\mathrm{s}}+1},\quad \gamma_{2\to2}=a_2\rho x_{\mathrm{s}}', caption='SIC steps A and B. Line 62 <code>|</code> = outage if <b>either</b> summed SINR is short.'),
  ],
  foot='<b>Numbers (5 dBW, ρ = 3.75):</b> γ<sub>th</sub> = 2<sup>0.728</sup> − 1 = 0.657 · weak user with x = 1: 2.625 / (1.125 + 1) = 1.24 ✓ · with x = 0.3: 0.79 / 1.34 = 0.59 ✗.',
  notes='''Colour by colour: A ceiling check; B the two users' channels; C weak-user SINR, summed over rounds (HARQ-CC), compared with 0.657; D strong user, two SIC steps, union of failures.
Q: Which equation is line 57? A: [12] eq. (6): delta_l rho|H|^2 / (vartheta_{k,l} rho|H|^2 + rho|g_I|^2 + 1) with vartheta = a2 + lambda^2, lambda = 0 (ideal hardware) and no residual-SIC term.
Q: Why sum over rounds? A: Hu eq. (1), chase combining; [12] has no HARQ.'''))

S.append(dict(type='code', kicker='3 · Code ↔ formula', title='order_users.m: who is the "weak user" when the packet is sent T times?',
  file=M + 'order_users.m', code=L(M + 'order_users.m', 19, 35), fs=15.5,
  groups=[
   dict(tag='A', color=C['A'], lines=[21, 22, 23], ref="'round' (default)", latex=r'x^{w}_{t}=\min_k |h_{k,t}|^2\ \ \text{for every round } t', caption='Weak user re-chosen each round. Every round then has the same distribution, which is what the paper\'s HARQ analysis needs. Reproduces the paper\'s T = 3 ranking.'),
   dict(tag='B', color=C['D'], lines=[25, 26, 30, 31], ref="'first'", latex=r'k^{w}=\arg\min_k |h_{k,1}|^2', caption='Roles fixed by round 1: physically consistent, because HARQ-CC resends the <i>same</i> superposed packet.'),
   dict(tag='C', color=C['C'], lines=[32, 33, 34, 35], ref='indexing', latex=r'x^{w}_{t}=|h_{k^{w},t}|^2,\ \ t=1..T', caption='Picks that user\'s gains in all T rounds.'),
  ],
  foot='<b>Effect (5 dBW, T = 3):</b> NOMA weak 8.8×10⁻⁴ (<code>\'round\'</code>) vs 2.3×10⁻⁴ (<code>\'first\'</code>) · OMA weak 5.1×10⁻³ vs 1.4×10⁻³ · identical at T = 1. The paper does not say which it used.',
  notes='''Why this matters: at T = 3 the ranking flips. 'round' gives RSMA < NOMA < OMA (paper's ranking); 'first' gives NOMA < RSMA < OMA.
Argument for 'round' being the paper's choice: their analysis multiplies identical per-round distributions (Laplace transform of a product), which only holds if the order statistic is taken every round.
Argument for 'first' being physical: the same packet with the same power split is resent, so the weak user cannot change identity between rounds.
We show both and say the paper leaves it unstated.'''))

S.append(dict(type='plot', kicker='3 · Result', title='NOMA outage: the strong user pays for SIC with two bars, but has the better channel',
  imgs=[('3_noma_outage.png', '')], imgh=600, split='64% 36%',
  cards=[
   dict(h='What to read off', color=SCHEME['noma'], b='<ul><li>Far (weak) user: slope T (ceiling 2.33 &gt; 0.657).</li><li>Near (strong) user: steeper, it holds the better of two channels (F² ⇒ slope 2 at T = 1).</li><li>At 5 dBW, T = 1: far 0.267, near 0.080.</li><li>T = 3, near user reaches 10⁻⁶ by 5 dBW.</li></ul>'),
   dict(h='Compared with OMA (T = 1, 5 dBW)', color=C['C'], b='Weak user 0.267 vs OMA 0.378: NOMA helps the weak user (lower threshold 0.657 vs 1.744) at the cost of interference.'),
  ],
  notes='''Say: "NOMA improves the weak user over OMA, as the paper says. The strong user is better still because it gets the better of two channels, even though it must pass two SIC steps."
Q: Why does the near user's T = 1 curve fall faster? A: Its outage is F(bar)^2 (both channels must be bad), so slope 2.'''))

# ===================================================================== section 4: RSMA
S.append(dict(type='theory', kicker='4 · RSMA', title='RSMA: split each message into a shared common part and a private part',
  cols='1fr 1fr',
  cards=[
   dict(h='Transmit (Hu eqs. 2–3)', color=SCHEME['rsma'], math=[r's=\sqrt{\alpha_cP_s}\,s_c+\sum_{k=1}^{K}\sqrt{\alpha_kP_s}\,s_k,\quad 0.4+0.3+0.3=1'],
        b='W<sub>k</sub> → W<sub>k,c</sub> + W<sub>k,p</sub>. All common parts → one stream s<sub>c</sub> decoded by everyone; each private part → its own s<sub>k</sub>.'),
   dict(h='Common stream, Hu eq. (5)', color=C['A'], math=[r'\gamma_{k,c}^{t}=\frac{\alpha_c\rho x}{(1-\alpha_c)\rho x+1},\quad \theta_c=\tfrac{\alpha_c}{1-\alpha_c}=\tfrac23'],
        b='All private streams are noise. Bar at 5 dBW: x ≥ 0.4/(3.75·(0.4 − 0.6·0.4)) = <b>0.667</b>.'),
   dict(h='Private stream, Hu eq. (6)', color=C['C'], math=[r'\gamma_{k,p}^{t}=\frac{\alpha_k\rho x}{(1-\alpha_c-\alpha_k)\rho x+1},\quad \theta_p=1'],
        b='After SIC of s<sub>c</sub>; the other user\'s private stream stays as noise. Bar: <b>0.593</b>.'),
   dict(h='Outage, Hu eqs. (7)–(8)', color=C['D'], math=[r'P_k^{T}=\Pr\{A_1\cup A_2\},\quad \max(\Pr A_1,\Pr A_2)\le P_k^{T}\le \Pr A_1+\Pr A_2'],
        b='A₁ = common fails, A₂ = private fails. At T = 1 A₂ ⊂ A₁, so P = Pr{A₁} = F(0.667) = <b>0.335</b> exactly.<br><b>NOMA is a special case</b>: W₁ → common only, W₂ → private only.'),
  ],
  notes='''Common stream is the bottleneck: threshold 0.4 sits close to its ceiling 0.667, so a user needs x >= 0.667 at 5 dBW, against 0.348 for the NOMA weak user.
Every RSMA user does SIC (unlike NOMA's weak user), and nobody decodes another user's private message (unlike NOMA's strong user).
Q: Why bounds? A: For T > 1 either event can happen without the other, so the paper bounds the union. At T = 1 the lower bound is exact here.
Q: So why is RSMA "best" in the paper? A: Section 8: generic RSMA user vs weakest NOMA/OMA user, and a fixed alpha_c = 0.4. RSMA contains NOMA, so an optimised split is never worse.'''))

S.append(dict(type='code', kicker='4 · Code ↔ formula', title='rsma_outage.m: eqs. (5) and (6) per round, eq. (1) sum, eq. (7) union',
  file=M + 'rsma_outage.m', code=L(M + 'rsma_outage.m', 34, 36) + gap() + L(M + 'rsma_outage.m', 58, 72), fs=15,
  groups=[
   dict(tag='A', color=C['B'], lines=[35, 36], ref='Fig. 4 caption', latex=r'\textstyle\sum_j\alpha_j=1-\alpha_c,\qquad \sum_{j\ne k}\alpha_j=1-\alpha_c-\alpha_k', caption='Interference seen by the common stream and by user k\'s private stream.'),
   dict(tag='B', color=C['A'], lines=[60], ref='Hu eq. (5)', latex=r'\gamma_{k,c}^{t}=\frac{\alpha_c\,\rho\,|h_{k,t}|^2}{(1-\alpha_c)\,\rho\,|h_{k,t}|^2+1}', caption='Common stream, all private streams as noise.'),
   dict(tag='C', color=C['C'], lines=[61], ref='Hu eq. (6)', latex=r'\gamma_{k,p}^{t}=\frac{\alpha_k\,\rho\,|h_{k,t}|^2}{(1-\alpha_c-\alpha_k)\,\rho\,|h_{k,t}|^2+1}', caption='Private stream after SIC of s<sub>c</sub>.'),
   dict(tag='D', color=C['D'], lines=[62, 63, 64, 65, 66], ref='Hu eqs. (1), (7), (8)', latex=r'\begin{gathered}A_1=\Big\{\textstyle\sum_t\gamma_{k,c}^{t}<\gamma_{c,th}\Big\},\ A_2=\Big\{\textstyle\sum_t\gamma_{k,p}^{t}<\gamma_{p,th}\Big\}\\ P_k^{T}=\Pr\{A_1\cup A_2\}\end{gathered}', caption='<code>A1|A2</code> = true outage (line 66); lines 64–65 give Pr A₁, Pr A₂ for the eq. (8) bounds.'),
  ],
  foot='<b>Numbers (5 dBW, ρ = 3.75):</b> x = 1.0 → γ<sub>c</sub> = 1.5/3.25 = 0.46 ✓, γ<sub>p</sub> = 1.125/2.125 = 0.53 ✓ · x = 0.5 → 0.35 ✗, 0.36 ✗ (both below 0.4).',
  notes='''Same structure as NOMA: compute SINRs per round (B, C), sum over rounds and compare (D), count (E).
Line 60 is eq. (5) letter for letter: sumP = 1 - alpha_c. Line 61 is eq. (6): sumOth = 1 - alpha_c - alpha_k.
The RSMA user here is generic (rsma_ordered = false), as in the paper's analysis; set p.rsma_ordered = true to make it the weakest of two.'''))

S.append(dict(type='plot', kicker='4 · Result', title='RSMA outage: simulation on the lower bound; bottleneck flips to the private stream at T ≥ 2',
  imgs=[('4_rsma_outage.png', '')], imgh=600, split='62% 38%',
  cards=[
   dict(h='What to read off', color=SCHEME['rsma'], b='<ul><li>Circles = simulation, lines = eq. (8) bounds.</li><li>T = 1: true = lower bound exactly (A₂ ⊂ A₁); upper ≈ 1.86 × lower.</li><li>T = 3: slope 3 (θ<sub>c</sub>, θ<sub>p</sub> above 0.4 ⇒ full diversity).</li></ul>'),
   dict(h='Bounds at 5 dBW (rsma_nesting_demo.m)', color=C['D'], b='<table><tr><th>T</th><th>Pr A₁</th><th>Pr A₂</th><th>true</th><th>upper</th></tr><tr><td>1</td><td>0.335</td><td>0.290</td><td>0.335</td><td>0.625</td></tr><tr><td>2</td><td>0.0140</td><td>0.0175</td><td>0.0178</td><td>0.0315</td></tr><tr><td>3</td><td>3.3e-4</td><td>5.9e-4</td><td>6.0e-4</td><td>9.2e-4</td></tr></table>'),
  ],
  notes='''Say: "Our simulation lies between the bounds, as in the paper's Fig. 2, and on the lower bound. At one round the common stream decides everything; with more rounds the private stream becomes the bottleneck."
Example with two rounds at x = 0.2, 0.2: common sums to 0.414 (pass) but private to 0.367 (fail): that is why A2 is no longer inside A1 and the paper needs bounds.'''))

# ===================================================================== section 5: Fig 4 combined
S.append(dict(type='plot', kicker='5 · All three together', title='Fig. 4 style: the ranking at T = 3 depends on how the weak user is chosen',
  imgs=[('fig4_both_orderings.png', '')], imgh=580, split='100%',
  cards=[],
  foot='<b>5 dBW:</b> T = 1 (both): NOMA 0.267 &lt; RSMA 0.335 &lt; OMA 0.378 — the paper\'s T = 1 ranking. · T = 3 <code>\'round\'</code>: RSMA 5.7×10⁻⁴ &lt; NOMA 8.8×10⁻⁴ &lt; OMA 5.1×10⁻³ (paper\'s ranking). · T = 3 <code>\'first\'</code>: NOMA 2.3×10⁻⁴ &lt; RSMA 5.7×10⁻⁴ &lt; OMA 1.4×10⁻³.',
  notes='''This is the combined plot (fig4_reproduce.m): the three schemes from the previous sections on one axis, for both orderings.
Left ('round'): same ranking as the paper at T = 1 and T = 3. Right ('first'): NOMA's weak user wins at T = 3.
RSMA curve is identical in both panels: the paper's RSMA user is a generic user, not ordered.
Our curves are about 5.5 dB to the right of the published Fig. 4: Section 8 shows this comes from the paper, not from our code.'''))

# ===================================================================== section 6: closed form + HARQ
S.append(dict(type='theory', kicker='6 · Closed form (T = 1)', title='With one round, every outage is the channel CDF at one bar on |h|²',
  cols='1fr 1fr',
  cards=[
   dict(h='Threshold trick — [12] eq. (12)', color=C['C'], math=[r'\frac{\delta\rho x}{\vartheta\rho x+1}\ge\gamma_{th}\iff x\ge\xi=\frac{\gamma_{th}}{\rho(\delta-\vartheta\gamma_{th})}'],
        b='Only if γ<sub>th</sub> &lt; δ/ϑ (ceiling); otherwise ξ = ∞, outage 1 at every power. ξ = c/ρ with c = 1.306 (NOMA weak), 1.744 (OMA), 2.5 (RSMA).'),
   dict(h='Needs every stream ⇒ the largest bar binds — [12] eq. (13)', color=C['D'], math=[r'P^{out}=F\big(\max_l \xi_l\big),\quad F(t)=\int_0^t f_{|h|^2}(x)\,dx'],
        b='NOMA strong: max(0.348, 0.584). RSMA: max(0.667, 0.593) = 0.667.'),
   dict(h='Weak / strong user (order statistics)', color=C['A'], math=[r'F_{\text{weak}}=1-(1-F)^2,\qquad F_{\text{strong}}=F^2'],
        b='Weak fails if the worse of two channels is below the bar; strong only if both are.'),
   dict(h='CDF in closed form (Gamma mixture)', color=C['B'], math=[r'F(t)=\sum_{n\ge0}w_n\,P(n{+}1,\beta t),\ \ w_n=\frac{\lambda(m)_n\delta^n}{n!\,\beta^{n+1}}'],
        b='The ₁F₁ series makes eq. (4) a weighted sum of Gamma PDFs; P = <code>gammainc</code>. Weights sum to 1; F(0.667) = 0.335 after ~8 terms.'),
  ],
  notes='''Why this matters: it gives an exact, independent check of every Monte Carlo number at T = 1, and it is the method of ref. [12].
Table at 5 dBW: NOMA weak bar 0.348 -> F 0.144 -> 1-(1-F)^2 = 0.267; OMA bar 0.465 -> 0.211 -> 0.378; RSMA bar 0.667 -> 0.335 (generic) / 0.558 (weakest of two).
Q: Why only T = 1? A: With T > 1 the SINRs are summed and no single bar on |h|^2 exists (fractions don't add like gains); we simulate.'''))

S.append(dict(type='code', kicker='6 · Code ↔ formula', title='op_closed_form_T1.m: bars, CDF and order statistics in 20 lines',
  file=CF + 'op_closed_form_T1.m', code=L(CF + 'op_closed_form_T1.m', 26, 48), fs=15,
  groups=[
   dict(tag='A', color=C['B'], lines=[29], ref='eq. (4) integrated', latex=r'F(t)=\sum_{n\ge0} w_n\,P(n{+}1,\beta t)', caption='<code>sr_cdf</code>: Gamma-mixture CDF, <code>gammainc</code>.'),
   dict(tag='B', color=C['A'], lines=[30, 31], ref='order statistics', latex=r'F_{\mathrm{weak}}=1-(1-F)^2,\qquad F_{\mathrm{strong}}=F^2', caption='Weak = min of two i.i.d. gains, strong = max.'),
   dict(tag='C', color=C['C'], lines=[33, 34, 35, 36, 37], ref='[12] eq. (12)', latex=r'\xi=\frac{\gamma_{th}}{\rho(\delta-\vartheta\gamma_{th})}', caption='<code>threshold_on_gain</code>: one bar per decoding step (∞ above the ceiling).'),
   dict(tag='D', color=C['D'], lines=[39, 40, 42, 43, 45, 46, 47, 48], ref='[12] eq. (13)', latex=r'P^{out}=F\big(\max_l \xi_l\big)', caption='NOMA near: <code>max(xi_n1, xi_n2)</code>; RSMA: <code>max(xi_c, xi_p)</code>.'),
  ],
  foot='<b>Check:</b> closed form vs Monte Carlo (<code>verify_closed_form.m</code>, your MATLAB): max error ≤ 0.8 % for all eight outputs · 5 dBW: NOMA weak 0.267 · OMA weak 0.378 · RSMA user 0.335 · RSMA weak 0.558.',
  notes='''This file never runs a simulation, and mc_outage.m never uses these bars: two independent methods that agree to < 1 %. That is the strongest evidence the SINR code is correct.'''))

S.append(dict(type='plot', kicker='6 · HARQ-CC over T rounds', title='HARQ-CC: one order of diversity per round; eq. (1)\'s sum of SINRs is optimistic',
  imgs=[('harq_repeated_interference.png', '')], imgh=640, split='60% 40%',
  cards=[
   dict(h='Diversity (Hu eq. 16)', color=C['C'], math=[r'D=T-\Big\lfloor\frac{\gamma_{th}}{\theta}\Big\rfloor=T\ \ \text{here}'], b='0.4/0.667 and 0.4/1 both round down to 0. OMA exact: ×10, ×105, ×1059 per 10 dB for T = 1, 2, 3.'),
   dict(h='Caveat: interference repeats', color=C['E'], math=[r'\sum_t\frac{\delta\rho x_t}{\vartheta\rho x_t+1}\ \text{(paper)}\ \text{vs}\ \frac{\delta\rho\sum_t x_t}{\vartheta\rho\sum_t x_t+1}'],
        b='Chase combining resends the <i>same</i> superposed signal, so interference adds coherently too and the ceiling stays θ. RSMA 5 dBW: T = 2 0.018 → 0.041, T = 3 5.8×10⁻⁴ → 2.9×10⁻³. OMA unchanged. We follow the paper and state it.'),
  ],
  notes='''Dashed = paper's model (sum of per-round SINRs, our default). Solid = repeated-interference model (Pranava's mc_outage_repeated.m + exact sr_cdf_T). Crosses = Monte Carlo of the repeated model, on the exact curve.
Q: Which is right? A: Physically the repeated model; the paper's eq. (1) is an upper bound on performance. It does not change the T = 1 results or OMA.'''))

# ===================================================================== section 7: ref [12]
S.append(dict(type='theory', kicker='7 · Ref. [12] (Singh et al., IEEE TVT 2024)', title='[12] gives the form of the NOMA SINR; Hu et al. switch its imperfections off',
  img_side=True, img='isic_floor.png', imgh=640, split='45% 55%',
  cards=[
   dict(h='[12] eq. (6): user k decoding x_l', color=C['A'], math=[r'\gamma_{u_k}^{x_l}=\frac{\delta_l\rho_s|H_k|^2}{\vartheta_{k,l}\rho_s|H_k|^2+\varpi\rho_s|g_I|^2+1},\quad \vartheta_{k,l}=\sum_{i>l}\delta_i+\lambda^2'],
        b='(Here δ is a power share, not the PDF constant.)'),
   dict(h='Three switches → our NOMA SINR', color=C['C'], b='<table><tr><th>[12]</th><th>Hu et al. / us</th></tr><tr><td>hardware λ &gt; 0</td><td>λ = 0</td></tr><tr><td>imperfect SIC ϖ = 1</td><td>ϖ = 0</td></tr><tr><td>UAV-IRS channel ρ<sub>s</sub>|H<sub>k</sub>|²</td><td>satellite ρ|h<sub>k,t</sub>|²</td></tr></table>Also from [12]: outage rule (eq. 11), threshold trick (eqs. 12–13), OMA needs K slots ⇒ 2<sup>KR</sup> − 1.'),
   dict(h='What [12] does not give', color=C['E'], b='No satellite, no Shadowed-Rician, no HARQ ⇒ none of Fig. 4\'s numbers. Right: switching imperfect SIC back on gives an error floor for the strong user only (Ω<sub>I</sub> = −20 dB: NOMA near 6.9×10⁻⁵, RSMA private 5.7×10⁻³).'),
  ],
  notes='''Say: "The reference you pointed us to is the right source for the form of the NOMA SINR and the outage rule, not for the numbers."
Plot (isic_floor.m): with a residual from imperfect SIC the curves flatten (diversity 0). Only steps after a SIC are affected: NOMA near user and RSMA private stream; NOMA far user and OMA unchanged.'''))

# ===================================================================== section 8: why Fig 4 doesn't match
S.append(dict(type='plot', kicker='8 · Why Fig. 4 does not match', title='Our curves sit ≈ 5.5 dB right of the published Fig. 4; adding 5.5 dB "fixes" T = 1',
  imgs=[('fig4_vs_paper.png', ''), ], imgh=570, split='100%',
  cards=[],
  foot='Solid = stated link budget; dashed = +5.5 dB (best fit to the paper\'s T = 1 points, <code>fig4_calibrated.m</code>, rms 0.62 → 0.03 decades); markers = values read off the paper\'s Fig. 4. With +5.5 dB, T = 1 matches within reading error and T = 3 within 2–4×. <b>But the offset is not physics</b> (next slide).',
  notes='''Say: "If we add an unexplained 5.5 dB of SNR, our curves land on the paper's. The question is whether that offset is legitimate. The next slide shows it is not: the paper's own figures contradict each other."
Note 5.5-6 dB ~ a factor 4 in SNR (e.g. half the distance), but the paper states 1000 km; we do not assume a cause.'''))

S.append(dict(type='theory', kicker='8 · Proof', title='No setting of the stated model can produce Fig. 4: four independent checks',
  cols='1fr 1fr',
  cards=[
   dict(h='1 · Outage below its own lower bound', color=C['E'], math=[r'P_k^{1}\ge\Pr\{A_1\}=F\!\left(\tfrac{2.5}{\rho}\right)'],
        b='10 dBW, T = 1: Pr{A₁} = <b>0.074</b> (exact), Fig. 4 shows RSMA <b>0.017</b>. Impossible under the stated parameters (0 dBW: 0.90 vs 0.28; 5 dBW: 0.335 vs 0.064).'),
   dict(h='2 · Bound gap (no link budget involved)', color=C['D'], math=[r'\frac{\text{upper}}{\text{lower}}=1+\frac{F(2.22/\rho)}{F(2.5/\rho)}\ \ge 1.855\ \ \forall\rho'],
        b='At T = 1, K = 2, the eq. (8) bounds must differ by ≥ 1.86× at <b>every</b> power (4–40 dBW). Fig. 4 inset at 5 dBW: upper ≈ 0.066, lower ≈ 0.061 (≈ 1.08×). No SNR offset can fix this.'),
   dict(h='3 · Fig. 3 vs Fig. 4, identical settings', color=C['A'], b='K = 2, α<sub>c</sub> = 0.4, α<sub>k</sub> = 0.3, γ = 0.4, 10 dBW.<table><tr><th></th><th>T = 1</th><th>T = 3</th></tr><tr><td>Paper Fig. 3</td><td>0.07–0.14</td><td>≈ 1.7×10⁻⁵</td></tr><tr><td>Ours</td><td>0.074–0.137</td><td>≈ 8.5×10⁻⁶</td></tr><tr><td>Paper Fig. 4</td><td><b>0.017</b></td><td><b>≈ 7×10⁻⁸</b></td></tr></table>Two figures of the same paper disagree by 4× and 250×; ours agrees with Fig. 3.'),
   dict(h='4 · The offset that fits Fig. 4 breaks Fig. 2', color=C['B'], b='Paper text, Fig. 2 (K = 3, T = 3, 5 dBW): true OP 8.74×10⁻³.<table><tr><th>link budget</th><th>ours</th></tr><tr><td>stated (0 dB)</td><td class="ok">7.7×10⁻³ ✓</td></tr><tr><td>+5.5 dB</td><td class="bad">6.0×10⁻⁵ ✗</td></tr></table><b>Conclusion</b>: Fig. 2 and Fig. 3 are reproduced with the stated parameters; Fig. 4 uses some unstated setting. We report results at the stated link budget.'),
  ],
  notes='''This is the slide to defend. Go 1 -> 4.
1: Outage is the probability of (A1 or A2), so it can never be below Pr{A1}. Pr{A1} at T = 1 is an exact closed form (one CDF value). Fig. 4 is below it.
2: Purely about the paper's own bounds: A2 is inside A1 at T = 1, and Pr A2 / Pr A1 >= 0.855 for every rho, so upper/lower >= 1.86. The published bounds almost touch. This does not depend on g, distance or noise.
3: Fig. 3 at K = 2 uses exactly Fig. 4's RSMA settings at 10 dBW; the two published figures disagree. Our model agrees with Fig. 3.
4: The only knob that moves Fig. 4 onto our curves (+5.5 dB) destroys the Fig. 2 match that the paper quotes in its text.
Q: Could your code be wrong? A: Closed form and Monte Carlo agree to < 1 %, the channel matches eq. (4), and Figs. 2 and 3 are reproduced. Check 2 needs no code at all.
Q: What might they have done? A: Unknown; any ~4x SNR factor would do it (e.g. 500 km instead of 1000 km). We don't claim a cause.'''))

S.append(dict(type='plot', kicker='8 · Evidence', title='The three published figures side by side (Hu et al., p. 10026)',
  imgs=[('paper_fig3.png', 'Fig. 3 at K = 2, 10 dBW: T = 1 ≈ 0.07–0.14, T = 3 ≈ 1.7×10⁻⁵'), ('paper_fig4.png', 'Fig. 4, same settings at 10 dBW: T = 1 ≈ 0.017, T = 3 ≈ 7×10⁻⁸')], imgh=560, split='68% 32%', row=True,
  cards=[
   dict(h='Look at', color=C['E'], b='<ul><li>Fig. 3, leftmost points (K = 2): T = 1 bounds clearly apart (≈ 0.07 vs 0.14).</li><li>Fig. 4 inset at 5 dBW: RSMA upper and lower bounds almost touch.</li><li>Fig. 4 at 10 dBW, T = 1: all three schemes ≈ 0.015–0.02.</li></ul>'),
   dict(h='Fig. 2 (K = 3) text value', color=C['B'], b='Paper: 8.5×10⁻³ ≤ 8.74×10⁻³ ≤ 8.9×10⁻³ at 5 dBW, T = 3.<br>Ours (stated parameters): 7.7×10⁻³ ≤ 7.7×10⁻³ ≤ 8.0×10⁻³.'),
  ],
  notes='''Show the paper itself so the professor sees we are reading their plots, not our own.
Values for Fig. 3/4 were read off a 220-dpi render of the PDF (±10-20 %); the contradiction is a factor 4 to 250, far beyond reading error.'''))

# ===================================================================== section 9: findings, Q&A
S.append(dict(type='theory', kicker='9 · Findings', title='What we found, what we assumed, what is open',
  cols='1fr 1fr 1fr',
  cards=[
   dict(h='Verified', color=C['C'], b='<ul><li>Eq. (4) channel: simulation = formula (Task 1).</li><li>SINRs of OMA, NOMA ([12] eqs. 6–7), RSMA (eqs. 5–6) in code, line by line (Task 2).</li><li>Closed form = Monte Carlo (≤ 0.8 %).</li><li>Fig. 2 and Fig. 3 reproduced at the stated link budget.</li><li>Full diversity D = T.</li></ul>'),
   dict(h='Findings about the paper', color=C['E'], b='<ul><li>Fig. 4 inconsistent with Figs. 2–3 and with its own bounds (4 checks).</li><li>T = 3 ranking depends on the unstated weak-user ordering.</li><li>Comparison is tilted: generic RSMA user vs <i>weakest</i> NOMA/OMA user. Fair (both weakest): RSMA 0.558 vs NOMA 0.267 at 5 dBW, T = 1.</li><li>RSMA vs NOMA at α<sub>c</sub> = 0.4 is a trade-off: NOMA wins for the weak user, RSMA for the strong user.</li></ul>'),
   dict(h='Assumptions / next steps', color=C['D'], b='<ul><li>Assumed: beam centre; OMA = TDMA (2<sup>2R</sup> − 1); ordering (both shown).</li><li>Eq. (1) sum of SINRs is optimistic (repeated interference ×2–5 at T = 2–3).</li><li>Perfect SIC: [12]\'s residual gives an error floor.</li><li>Next: sweep α<sub>c</sub> (RSMA contains NOMA, so optimised RSMA ≥ NOMA); implement eqs. (9), (11).</li></ul>'),
  ],
  notes='''Close: "Both tasks are done: the channel PDF is validated and all three SINRs are in code with their equations. The model reproduces Figs. 2 and 3; Fig. 4 cannot be reproduced by any consistent setting, and we have four independent reasons why."'''))

S.append(dict(type='theory', kicker='Backup', title='Likely questions, short answers',
  cols='1fr 1fr',
  cards=[
   dict(h='"Where do the OMA and NOMA SINRs come from?"', color=C['A'], b='[12] eqs. (6)–(7) with λ = 0 (ideal hardware), perfect SIC, and the satellite term ρ|h|². OMA: δ = 1, ϑ = 0, threshold 2<sup>2R</sup> − 1 (K slots, as in [12]).'),
   dict(h='"Is this the modified Rician?"', color=C['B'], b='Same channel: Shadowed-Rician (Abdi 2003), Rician with a Nakagami-m LoS. Eq. (4) is the PDF of |h|²; the envelope |h| has 2r·f(r²).'),
   dict(h='"Why is NOMA better than RSMA for the weak user?"', color=C['C'], b='NOMA gives it 70 % of the power (bar 0.348); RSMA\'s common stream needs 0.667 because 0.4 sits close to θ<sub>c</sub> = 0.667. RSMA wins for the strong user, and an optimised split can never lose to NOMA.'),
   dict(h='"Why trust your code over the paper?"', color=C['D'], b='Two independent methods agree (< 1 %), eq. (4) is validated, Figs. 2 and 3 match. Check 2 (bound gap ≥ 1.86) needs no code.'),
   dict(h='"Why do some points disappear?"', color=C['E'], b='Zero outages in 2×10⁶ trials; we drop zeros instead of plotting them at 10⁻¹⁶. You need N ≳ 100/OP.'),
   dict(h='"Which ordering is right?"', color=C['F'], b='Paper is silent. <code>\'round\'</code> matches their analysis and ranking; <code>\'first\'</code> is physical (same packet). Identical at T = 1.'),
  ],
  notes='Backup only; use if asked.'))

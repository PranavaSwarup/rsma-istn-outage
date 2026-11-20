"""Speaker guide: one A4 page per slide. Thumbnail + what to say + where to point in the paper
+ likely questions (professor wants proof, wants to see the formula in the paper)."""
import asyncio
from pathlib import Path
ROOT = Path(__file__).parent
KATEX = (ROOT / 'node_modules/katex/dist').as_uri()
OUT = ROOT / 'out'

HU = 'Hu et al.'
P = dict(p1='p. 10023', p2='p. 10024', p3='p. 10025', p4='p. 10026', p5='p. 10027')

# Each entry: say (list), show (list of (what, where)), qa (list of (q, a)), watch (optional list)
G = {}

G[1] = dict(
 say=['Open by saying what changed since the last meeting: last time the graphs did not match and the OMA/NOMA SINR expressions were missing.',
      'Today we do three things: validate the channel PDF (task 1), show the OMA, NOMA and RSMA SINRs next to the code that computes them (task 2), and explain why the paper\'s Fig. 4 cannot be matched.',
      'Every number in the deck was run in MATLAB R2025b on our code. No toolboxes are needed.'],
 show=[('Paper title, authors, journal', f'{HU}, IEEE TVT vol. 74, no. 6, June 2025, {P["p1"]}'),
       ('Ref. [12] in the reference list', f'{HU}, last page (p. 10028), reference [12]: Singh et al., IEEE TVT, Jan. 2024')],
 qa=[('Is this the same paper as last time?', 'Yes, Hu et al. (Paper 2). The new part is the NOMA model from its reference [12], plus a closed-form check and the Fig. 4 analysis.'),
     ('Who wrote which code?', 'Base Monte Carlo code: Pranava (repo owner). PDF validation plot: Abel. Ordering switch, PDF check, MATLAB fixes and the Fig. 4 checks: Yash. All on GitHub, branches week3-oma-noma-sinr-pdf, 20-nov, 20-nov-matlab.')])

G[2] = dict(
 say=['Read out the two official tasks from the message she sent: (1) Rician channel power PDF, simulation vs analysis; (2) RSMA vs NOMA vs OMA SINR expressions and MATLAB code.',
      'Explain the order: the channel first, because every SINR uses it; then OMA, NOMA and RSMA, each as concept → code next to equations → its own plot; then all three together.',
      'After that come the supporting maths (closed form, HARQ), ref. [12], and the Fig. 4 explanation.'],
 show=[],
 qa=[('Why the channel first?', 'Every SINR is "transmit power × link budget × |h|²". If the |h|² samples are wrong, every outage number is wrong. So we prove the channel first.'),
     ('Why not one combined plot only?', 'She asked to see each scheme separately. Slides 11, 15 and 18 are the separate plots; slide 19 is the combined Fig. 4 style plot.')])

G[3] = dict(
 say=['One LEO satellite, two single-antenna users. Everything depends on one number, ρ = P<sub>s</sub>g<sub>k</sub>: the received SNR per unit channel gain.',
      'g<sub>k</sub> = 1.186 (0.74 dB) comes from the paper\'s link budget: free-space loss at 1000 km and 1.55 GHz is about −156 dB, the two antennas give +30 dB, and the noise floor kTB is about −127 dBW.',
      'For a fair comparison every scheme carries the same rate per user, R = 0.728 b/s/Hz. That fixes the thresholds: 0.4 for each RSMA stream, 0.657 for NOMA and 1.744 for OMA.',
      'HARQ chase combining: the same packet is resent and the receiver adds the SINRs of all copies (eq. 1).'],
 show=[('Link budget 𝒢<sub>k</sub> = c√(G<sub>s</sub>G<sub>r</sub>)/(4πf<sub>c</sub>d)', f'{P["p2"]}, left column, just below eq. (3)'),
       ('g<sub>k</sub> = 𝒢<sub>k</sub>²/N<sub>0</sub> inside the SINR', f'{P["p2"]}, right column, eq. (5) and the line under it'),
       ('Numbers: 1000 km, 1.55 GHz, 25/5 dBi, 50 MHz, 290 K', f'{P["p3"]} right column (Sec. IV) continuing onto {P["p4"]} left column'),
       ('Equal-rate rule R<sub>1,th</sub> = R<sub>2,th</sub> = R<sub>c,th</sub>/2 + R<sub>p,th</sub>', f'{P["p4"]}, Fig. 4 caption'),
       ('HARQ-CC sum of SINRs', f'{P["p2"]}, left column, eq. (1)')],
 qa=[('Why is the rate R<sub>c</sub>/2 + R<sub>p</sub>?', 'The common stream carries pieces of both users\' messages, so each user gets about half of its rate, plus all of its own private rate. The paper states this rule in the Fig. 4 caption.'),
     ('Why is the OMA threshold 2<sup>2R</sup> − 1 and not 2<sup>R</sup> − 1?', 'In TDMA each user transmits only half the time. To average R over the whole frame it must run at 2R inside its own slot, and Shannon then needs SINR ≥ 2<sup>2R</sup> − 1. Ref. [12] makes the same argument for its OMA benchmark (p. 1077, left column: OMA needs more time slots, so its equivalent threshold is larger). The paper itself only says "TDMA for example" (p. 10026).'),
     ('Where is the user in the beam?', 'Not stated in the paper. We assume the beam centre (θ = 0), so G<sub>s</sub> = G<sub>max</sub> = 25 dBi. That is the best case and it is marked [ASSUMED] in the code.'),
     ('What does ρ mean physically?', 'The average received SNR if |h|² = 1. At 5 dBW it is 3.75, so a "typical" round gives SNR ≈ 3.75 (5.7 dB).')],
 watch=['Do not call g<sub>k</sub> "SNR". It is the SNR per watt, before fading. SNR in a round is ρ|h|².'])

G[4] = dict(
 say=['This file holds every number. Each line is tagged [paper] or [ASSUMED] in the comments.',
      'Walk the colours: A channel parameters, B link budget, C RSMA split, D equal-rate conversion and NOMA split, E OMA threshold.',
      'Only three things are assumptions: beam centre, OMA = TDMA, and the weak-user ordering. Everything else is copied from the paper.'],
 show=[('b, m, Ω = 0.126, 10.1, 0.835', f'{P["p3"]}, right column, Sec. IV, first paragraph'),
       ('α<sub>c</sub> = 0.4, α<sub>k</sub> = 0.3, γ<sub>th</sub> = 0.4, a<sub>1</sub> = (1+α<sub>c</sub>)/2', f'{P["p4"]}, Fig. 4 caption')],
 qa=[('Why is a<sub>1</sub> = 0.7?', 'The paper converts RSMA to NOMA by putting user 1\'s whole message in the common stream. User 1 then gets the common power plus its own private power: 0.4 + 0.3 = 0.7 = (1 + α<sub>c</sub>)/2. Printed in the Fig. 4 caption.'),
     ('Why 0.4 as a threshold?', 'Chosen by the paper (Fig. 2 and Fig. 4 captions). 0.4 corresponds to a rate of log₂(1.4) = 0.485 b/s/Hz per stream.')])

G[5] = dict(
 say=['"Modified Rician" in the task means this channel. The paper calls it Shadowed-Rician: a Rician channel whose line-of-sight part is not fixed but fluctuates (Nakagami-m), because trees and buildings partly block the satellite.',
      'Eq. (4) gives the PDF of the power gain |h|². λ, β, δ are just shorthand built from b, m, Ω.',
      'How to recognise it on a graph: f(0) = λ = 0.226 is not zero, and there is a hump near x ≈ 0.6 from the line-of-sight. Rayleigh power has no hump.',
      'Right plot: all curves rescaled to the same mean so only the shape differs. Heavy shadowing (blue) lies on Rayleigh; light shadowing (yellow) lies on Rician; the paper\'s average shadowing (orange) is in between, closer to Rician.'],
 show=[('Eq. (4), λ, β, δ', f'{P["p2"]}, left column, eq. (4) and the line below it'),
       ('"Shadowed-Rician (S-R) distribution", i.i.d. over k and t', f'{P["p2"]}, left column, just above eq. (4)'),
       ('Physical model origin', 'Abdi et al., IEEE Trans. Wireless Commun., 2003 (the standard land-mobile satellite model)')],
 qa=[('Why does the blue (heavy shadowing) curve lie exactly on Rayleigh?', 'With heavy shadowing the line-of-sight carries only 0.7 % of the power. Without line-of-sight, only scatter is left, and scatter alone is Rayleigh fading. The numbers coincide: f(0.5) = 0.607 and f(1) = 0.368 for both.'),
     ('They all look like the Rayleigh distribution to me.', 'The familiar Rayleigh curve with a hump is the ENVELOPE |h|. This plot is the POWER |h|². For Rayleigh fading the power is exponential: highest at 0, falling, no hump (blue/dashed). The humped curves here are Rician-like, not Rayleigh.'),
     ('Where does ₁F₁ come from?', 'For a fixed line-of-sight amplitude A, |h|² is Rician-power (a Bessel function I₀ appears). Averaging over the Gamma-distributed A² term by term turns the Bessel series into Kummer\'s ₁F₁. We do not derive it; we check it by simulation on slide 8.'),
     ('Why is f(0) not zero?', 'Because this is the power |h|². Its density at 0 is λ = 0.226. The envelope |h| has density 2r·f(r²), which is 0 at r = 0 (left panel on slide 8).'),
     ('What is the mean?', 'Ω + 2b = 0.835 + 0.252 = 1.087. The paper does not normalise it to 1; neither do we.')],
 watch=['Say "Shadowed-Rician", not "modified Rician". If she uses "modified Rician", agree that it is the same channel.'])

G[6] = dict(
 say=['Top file generates the channel, bottom file evaluates the formula. Slide 8 puts the two on top of each other.',
      'A: the line-of-sight power A² is Gamma(m, Ω/m), which is what a Nakagami-m amplitude means. B: add a random phase and complex Gaussian scatter with power 2b, then take |h|².',
      'C: the three constants λ, β, δ exactly as printed under eq. (4). D: eq. (4) itself, with ₁F₁ written as its power series.',
      'Checks from your MATLAB: simulated mean 1.0874 vs 1.087; area under eq. (4) = 1.0000; CDF error below 10⁻³.'],
 show=[('λ, β, δ definitions', f'{P["p2"]}, left column, line below eq. (4)')],
 qa=[('Why your own Gamma generator instead of randg?', 'randg needs the Statistics and Machine Learning Toolbox, which we do not have. gamma_core is the standard Marsaglia–Tsang method (2000). The mean and CDF checks prove it is correct.'),
     ('What is (m)<sub>n</sub>?', 'The rising factorial m(m+1)…(m+n−1). It is the standard series of ₁F₁(m; 1; z) = Σ (m)<sub>n</sub> zⁿ/(n!)².'),
     ('Why logs inside the series?', 'Γ(m+n) and n! overflow for large n; their logarithms do not. It is only a numerical safeguard.'),
     ('Is the scatter variance b or 2b?', 'Each of the real and imaginary parts has variance b, so the total scatter power is 2b = 0.252, as in the paper.')])

G[7] = dict(
 say=['This is Abel\'s script behind the validation plot.',
      'Simulation side (C): 5×10⁵ channels, histogram normalised as a PDF ("Normalization", "pdf"), so its area is 1 and it can be laid on top of a formula.',
      'Analysis side (D): eq. (4). The envelope PDF uses the change of variables f<sub>r</sub>(r) = 2r f<sub>x</sub>(r²).',
      'E connects the channel to outage: at 5 dBW the RSMA common stream needs |h|² ≥ 0.667, so the one-round outage is the area of the PDF left of 0.667 = 0.335.'],
 show=[('Eq. (4)', f'{P["p2"]}, left column'),
       ('Outage = Pr{common fails ∪ private fails}', f'{P["p2"]}, right column, eq. (7)')],
 qa=[('Why the 2r in the envelope PDF?', 'If x = r², then Pr{x < t} = Pr{r < √t}; differentiating gives f<sub>r</sub>(r) = 2r f<sub>x</sub>(r²). The 2r is the Jacobian, and it is why the envelope PDF starts at 0.'),
     ('Where does 0.667 come from?', 'Set the common-stream SINR (eq. 5) equal to 0.4 at ρ = 3.75: 0.4ρx/(0.6ρx + 1) = 0.4 ⇒ x = 0.4/(3.75·(0.4 − 0.24)) = 0.667. Slide 16 shows the general version.'),
     ('Is the PCHIP smoothing part of the proof?', 'No, it only draws a smooth shaded area. The evidence is the raw histogram (circles) against eq. (4) (dashed).')])

G[8] = dict(
 say=['Right panel is the paper\'s eq. (4): the simulated histogram (orange circles) sits on the formula (dashed purple) at every bin. That answers task 1.',
      'Read off: f(0) = λ = 0.226 (blue square), mean 1.087 (dotted line), and the red shaded area left of 0.667 = 0.335, the one-round RSMA outage at 5 dBW.',
      'Left panel is the same channel as an amplitude |h|: it starts at 0 and peaks at r ≈ 0.96.'],
 show=[('Eq. (4)', f'{P["p2"]}, left column')],
 qa=[('Are the two curves on top of each other, or is one hiding the other?', 'They are on top of each other. The circles are the simulation and the dashed line is the formula; you can see both. The numerical checks confirm it: the area under eq. (4) is 1.0000, the simulated mean is 1.087, and the maximum CDF difference is 8×10⁻⁴.'),
     ('Why 0.329 (histogram) vs 0.3351 (formula)?', '0.329 is the area under the smoothed histogram, which has binning error near x = 0 where the PDF rises steeply. The exact formula value is 0.3351, and the Monte Carlo count in our outage code gives 0.335.'),
     ('Is the left curve Rayleigh?', 'No. A Rayleigh envelope with the same mean power peaks at 0.74 and is wider. Ours peaks at 0.96 and is narrower, because the line-of-sight keeps |h| near its typical value.')],
 watch=['Backup: 03_shadowed_rician_pdf/sr_pdf_validation.png shows histogram, log-scale tail and CDF if she wants more proof.'])

G[9] = dict(
 say=['Every SINR in this deck has one shape: wanted power over (interference + noise), γ = δρx/(ϑρx + 1).',
      'δ is the power share of the stream being decoded, ϑ is the share still interfering, and "+1" is the noise (everything is divided by N<sub>0</sub>).',
      'The ceiling θ = δ/ϑ is the highest SINR one round can ever give, however much power you use. With no interference (ϑ = 0) there is no ceiling.',
      'OMA: δ = 1, ϑ = 0, so SINR = ρx with no ceiling. But the threshold is 1.744 because of the half-time slot. At 5 dBW a round fails when x < 0.465.'],
 show=[('Same shape in the paper', f'{P["p2"]}, eqs. (5) and (6): numerator = own power share, denominator = other streams\' share + 1'),
       ('Same shape in ref. [12]', 'Singh et al., p. 1069, eq. (6): δ<sub>l</sub>ρ|H|²/(ϑ<sub>k,l</sub>ρ|H|² + … + 1)'),
       ('Ceiling θ<sub>k,c</sub> = α<sub>c</sub>/(1−α<sub>c</sub>)', f'{P["p2"]}, right column, text under Theorem 1; θ<sub>k,p</sub> on {P["p3"]}, left column (Corollary 1)')],
 qa=[('Where is "γ = δρx/(ϑρx+1)" in the paper?', 'Not written in this generic form. It is our compact notation for eqs. (5) and (6) of Hu et al. and eq. (6) of [12]: put δ = α<sub>c</sub>, ϑ = 1 − α<sub>c</sub> and you get eq. (5) exactly. The letters δ and ϑ are borrowed from [12]. Show eq. (5) and substitute.'),
     ('What does "ceiling" mean, in simple terms?', 'Divide top and bottom by ρx: γ = δ/(ϑ + 1/(ρx)). As power grows, 1/(ρx) → 0, so γ → δ/ϑ. More power raises the wanted signal AND the interference equally, so the ratio stops growing. Example: the RSMA common stream can never exceed 0.4/0.6 = 0.667.'),
     ('Does the paper use the word ceiling?', 'The paper calls it θ<sub>k,c</sub> and θ<sub>k,p</sub> and uses it in the full-diversity condition γ<sub>th</sub> < θ (eq. (16), {p}). "Ceiling" is our plain-English name.'.format(p=P['p3'])),
     ('What if the threshold were above the ceiling?', 'That stream could never be decoded in one round, outage = 1 at every power. With HARQ it costs diversity: D = T − ⌊γ<sub>th</sub>/θ⌋ (eq. 16).'),
     ('Why is the OMA weak user 1 − (1 − F)²?', 'The weak user has the worse of two independent channels. It fails unless both channels are above the bar: 1 − (1−F)². With F = 0.211 that is 0.378. Slide 20 covers this.')],
 watch=['In this slide δ is a power share. It is NOT the PDF constant δ = 0.980 from eq. (4). Say this if she looks confused.'])

G[10] = dict(
 say=['Read the loop. B: draw both users\' channels for all T rounds and pick weak/strong. C: per-round SNR = ρx (no interference). D: add down the rounds (HARQ-CC) and compare with 1.744. E: outage = failures ÷ trials.',
      'The channel matrix is T rows (rounds) × n columns (trials). sum(·,1) adds down a column, which is one packet\'s rounds.',
      'Worked numbers: x = 0.4 gives SNR 1.5 < 1.744 (fail); x = 0.6 gives 2.25 (pass).'],
 show=[('HARQ-CC sum', f'{P["p2"]}, eq. (1)'),
       ('OMA as TDMA', f'{P["p4"]}, right column, "The OMA takes TDMA for example"')],
 qa=[('Where is the time-sharing in the code?', 'Only in the threshold 2<sup>2R</sup> − 1 (istn_params.m, line 63). Inside its slot the user has full power and no interference.'),
     ('Why Monte Carlo and not a formula?', 'For OMA an exact formula exists too (sum of T Shadowed-Rician gains, Pranava\'s oma_diversity_exact.m); it agrees with this simulation (5 dBW, T = 2: 0.0162 vs 0.0161). Monte Carlo is used because it works the same way for all three schemes.'),
     ('How many trials?', '2×10⁶ per point for these plots (10⁶ in the paper, Sec. IV). Rule of thumb: you need about 100/OP trials to estimate OP.')])

G[11] = dict(
 say=['Weak user (circles) is above the strong user (squares) because it has the worse of two channels.',
      'Slope at high power: T = 1 falls one decade per 10 dB, T = 3 falls three decades per 10 dB. That is full diversity: OMA has no ceiling, so every extra round helps fully.',
      'Exact check: from 20 to 30 dBW the outage falls ×10, ×105, ×1059 for T = 1, 2, 3.'],
 show=[('Diversity D = T when γ<sub>th</sub> < θ', f'{P["p3"]}, right column, Theorem 2 and eq. (16)')],
 qa=[('Why are some points missing at the bottom?', 'Zero failures in 2 million trials at that power. A zero cannot be drawn on a log axis, so we leave it out instead of plotting it as 10⁻¹⁶.'),
     ('What does "diversity" mean here?', 'To fail after T rounds, all T independent rounds must be bad. Probabilities multiply, so OP ∝ (1/SNR)<sup>T</sup>: slope T on a log–log plot.'),
     ('Why is the strong user so much better?', 'It needs both channels to be bad (F² instead of 1 − (1−F)²), which gives an extra order of slope.')])

G[12] = dict(
 say=['NOMA sends both messages at the same time on top of each other in power: 70 % to the weak user, 30 % to the strong user.',
      'Weak user: decodes its own (louder) message and treats the other as noise. Ceiling a<sub>1</sub>/a<sub>2</sub> = 2.33, far above the 0.657 threshold.',
      'Strong user: first decodes the weak user\'s message (step A), subtracts it (SIC), then decodes its own with no interference left (step B). It fails if either step fails, so the larger bar, 0.584, decides.',
      'These SINRs come from ref. [12], eqs. (6) and (7), with its hardware impairment and imperfect-SIC terms set to zero. Hu et al. cite [12] exactly where they set up NOMA.'],
 show=[('NOMA conversion and "[12]"', f'{P["p4"]}, right column: "To fully perform the NOMA operation [12], relatively more power is allocated to user 1 …"'),
       ('[12] SINR', 'Singh et al., p. 1069, left column, eqs. (6) and (7)'),
       ('[12] power order δ<sub>1</sub> ≥ … ≥ δ<sub>K</sub>', 'Singh et al., p. 1068, right column (Sec. II-B)'),
       ('[12] outage rule', 'Singh et al., p. 1069, right column, eq. (11)')],
 qa=[('Why does the weak user get MORE power?', 'Its channel is worse. Giving it more power lets it decode directly while the strong user\'s small signal is only weak noise. The strong user can afford less power because its channel is good.'),
     ('Why must the strong user decode the weak user\'s message first?', 'It is the louder signal at the strong user too. You can only remove it (SIC) after decoding it; then the quiet own message is decoded with no interference.'),
     ('Show me this formula in [12].', 'p. 1069, eq. (6): γ = δ<sub>l</sub>ρ<sub>s</sub>|H|²/(ϑ<sub>k,l</sub>ρ<sub>s</sub>|H|² + ϖρ<sub>s</sub>|g<sub>I</sub>|² + 1), ϑ<sub>k,l</sub> = Σ<sub>i>l</sub>δ<sub>i</sub> + λ². Set λ = 0 (ideal hardware), ϖ = 0 (perfect SIC), δ<sub>1</sub> = 0.7, δ<sub>2</sub> = 0.3, and replace ρ<sub>s</sub>|H|² by our ρx: you get 0.7ρx/(0.3ρx + 1).'),
     ('Does Hu et al. write the NOMA SINR anywhere?', 'No. It only gives the conversion (W₁ → common, W₂ → private) and the power split in the Fig. 4 text. That is why we took the form from [12].'),
     ('Where is 0.348 from?', 'Solve 0.7ρx/(0.3ρx + 1) = 0.657 at ρ = 3.75: x = 0.657/(3.75·(0.7 − 0.3·0.657)) = 0.348.')])

G[13] = dict(
 say=['A: the ceiling check; MATLAB warns if the threshold were above a<sub>1</sub>/a<sub>2</sub>.',
      'B: two users\' channels, weak = min, strong = max.',
      'C (line 57): weak-user SINR, [12] eq. (6) with λ = 0. Line 58 sums over rounds and compares with 0.657.',
      'D (lines 60–62): strong user, step A (same formula on the strong channel) and step B (0.3ρx). Line 62 uses "|" (OR): outage if either summed SINR is short.'],
 show=[('[12] eqs. (6), (7), (11)', 'Singh et al., p. 1069')],
 qa=[('Line 57 is which equation exactly?', '[12] eq. (6) with l = k = 1, ϑ<sub>1,1</sub> = δ<sub>2</sub> + λ² = 0.3 (λ = 0) and no residual-SIC term (the first user does no SIC in [12] either).'),
     ('Line 61 has no "+1" denominator?', 'It has: a<sub>2</sub>ρx/(0·ρx + 1) = a<sub>2</sub>ρx. After perfect SIC nothing interferes, so ϑ = 0. That is [12] eq. (7) with λ = 0.'),
     ('Why OR in line 62?', '[12] eq. (11): user k is in outage if it fails to decode ANY of the messages x<sub>l</sub>, l ≤ k. The strong user needs both.'),
     ('Is summing SINRs over rounds in [12]?', 'No, [12] has no HARQ. The sum is Hu et al. eq. (1), applied to the NOMA SINRs.')])

G[14] = dict(
 say=['With several rounds, who is "the weak user"? The paper does not say, and the answer changes the T = 3 ranking.',
      '\'round\' (A): weak user re-chosen in every round. This is what the paper\'s analysis needs (identical distribution in each round) and it reproduces the paper\'s ranking.',
      '\'first\' (B): roles fixed by round 1 and kept, which is physically consistent because HARQ-CC resends the same superposed packet with the same power split.',
      'At T = 1 they are identical. At T = 3, 5 dBW: NOMA weak 8.8×10⁻⁴ (round) vs 2.3×10⁻⁴ (first). We show both.'],
 show=[('Users "distinguished by the channel quality"', f'{P["p2"]}, footnote 3 (left column, bottom)'),
       ('"divides the two users into weak user 1 and strong user 2 according to the channel gain"', f'{P["p4"]}, left column, last lines, continuing in the right column')],
 qa=[('Which one is correct?', 'The paper is silent. \'first\' is the physical one. \'round\' is the one their analysis implicitly assumes and the one that gives their ranking. So we present both and say it is an unstated assumption.'),
     ('Why does \'round\' give worse outage for NOMA/OMA?', 'Re-picking the minimum in every round means the "weak user" always gets the worst channel of each round, which is pessimistic for it. With \'first\', a user who was weak in round 1 often has good later rounds.'),
     ('Does it affect RSMA?', 'Not the curve in the paper: their RSMA user is a generic (unordered) user, so its curve is the same in both panels of slide 19.')])

G[15] = dict(
 say=['Far (weak) user: falls with slope T because its ceiling 2.33 is above 0.657.',
      'Near (strong) user: steeper, because it has the better of two channels (F², slope 2 even at T = 1), even though it must pass two SIC steps.',
      'Compared with OMA at 5 dBW, T = 1: NOMA weak 0.267 vs OMA weak 0.378. NOMA helps the weak user, as the paper says.'],
 show=[('"Compared with OMA, NOMA enhances the outage performance of the weak user…"', f'{P["p4"]}, right column, Fig. 4 discussion')],
 qa=[('If NOMA has interference and OMA does not, why is NOMA better?', 'Thresholds: NOMA needs 0.657, OMA needs 1.744 (half-time penalty). At these powers the lower threshold matters more than the interference.'),
     ('Why does the near-user T = 3 curve stop at 5 dBW?', 'Zero failures in 2×10⁶ trials beyond that; not plotted.')])

G[16] = dict(
 say=['RSMA splits each user\'s message into a common part and a private part. All common parts go into one stream s<sub>c</sub> that every user decodes; each private part is its own stream.',
      'Common stream, eq. (5): all private streams are noise; ceiling α<sub>c</sub>/(1−α<sub>c</sub>) = 2/3. Bar at 5 dBW: x ≥ 0.667.',
      'Private stream, eq. (6): after removing s<sub>c</sub>, the other user\'s private stream is still noise; ceiling 1. Bar: x ≥ 0.593.',
      'Outage, eq. (7): fail if common OR private fails. At T = 1 the private bar is lower, so "private fails" implies "common fails" and the outage equals Pr{A₁} = 0.335 exactly.',
      'NOMA is a special case: user 1\'s whole message in the common stream, user 2\'s whole message private.'],
 show=[('Message splitting, eq. (2)', f'{P["p2"]}, left column'),
       ('Eqs. (5), (6)', f'{P["p2"]}, right column'),
       ('Eqs. (7), (8) (outage and bounds)', f'{P["p2"]}, right column, Sec. III-A'),
       ('Conversion RSMA → NOMA', f'{P["p4"]}, right column, "By setting W₁ → {{W₁,c}} and W₂ → {{W₂,p}}, RSMA can be converted to NOMA"')],
 qa=[('Why does splitting help at all?', 'Each user decodes only part of the other user\'s message (inside s<sub>c</sub>), never the other\'s private part. Interference is partly decoded and partly treated as noise, which sits between NOMA (fully decode) and treating everything as noise. With multiple antennas and imperfect channel knowledge this flexibility is where RSMA wins.'),
     ('Why is the common stream the bottleneck?', 'Its threshold 0.4 is close to its ceiling 0.667, so it needs x ≥ 0.667, compared with 0.348 for the NOMA weak user.'),
     ('Why bounds instead of an exact formula?', 'With T > 1, the common sum can pass while the private sum fails (or vice versa), so the two events are not nested; the joint probability is hard. The paper bounds it with eq. (8): max ≤ OP ≤ sum.'),
     ('Is α<sub>c</sub> = 0.4 optimal?', 'No, it is fixed in the paper. The paper itself says (Fig. 4 text, p. 10026) that α<sub>c</sub> changes the comparison.'),
     ('Where is θ<sub>k,c</sub> written?', f'{P["p2"]}, right column, under Theorem 1: θ<sub>k,c</sub> = α<sub>c</sub>/(1 − α<sub>c</sub>).')])

G[17] = dict(
 say=['Same structure as NOMA. A: interference fractions, sumP = 1 − α<sub>c</sub> and sumOth = 1 − α<sub>c</sub> − α<sub>k</sub>.',
      'B (line 60) is eq. (5) letter for letter. C (line 61) is eq. (6).',
      'D: sum(gc,1) and sum(gp,1) are eq. (1); the comparisons give A₁ and A₂; "A1 | A2" is eq. (7). Lines 64–65 count A₁ and A₂ separately to draw the eq. (8) bounds.',
      'Worked: x = 1 gives γ<sub>c</sub> = 0.46 and γ<sub>p</sub> = 0.53 (both pass); x = 0.5 gives 0.35 and 0.36 (both fail).'],
 show=[('Eqs. (5), (6), (7), (8)', f'{P["p2"]}, right column')],
 qa=[('The paper\'s eq. (5) has Σ<sub>j</sub> α<sub>j</sub> in the denominator. Is that 1 − α<sub>c</sub>?', 'Yes. Σ<sub>j=1..K</sub> α<sub>j</sub> is the sum of the private powers, and α<sub>c</sub> + Σα<sub>j</sub> = 1 (text under eq. (2)), so Σα<sub>j</sub> = 1 − α<sub>c</sub> = 0.6.'),
     ('Is your RSMA user the weak user?', 'No, a generic user (p.rsma_ordered = false), as in the paper\'s analysis. Set it true to make it the weaker of two; at 5 dBW, T = 1 that gives 0.558 instead of 0.335.'),
     ('Are your bounds from eqs. (9) and (11)?', 'No: Monte Carlo estimates of Pr{A₁} and Pr{A₂}. At T = 1 we also have them exactly in closed form (slide 21).')])

G[18] = dict(
 say=['Circles are the simulated true outage; lines are the eq. (8) bounds.',
      'At T = 1 the simulation sits exactly on the lower bound (private failure is inside common failure). The upper bound is about 1.86× higher.',
      'With more rounds the bottleneck flips: at T = 2 and 3, Pr{A₂} > Pr{A₁}, the private stream fails more often. The lower bound stays tight.'],
 show=[('Same behaviour in the paper\'s Fig. 2 (bounds around simulation)', f'{P["p4"]}, Fig. 2 and its text: "the Monte Carlo simulations lie between the respective lower and upper bounds"')],
 qa=[('Why does the private stream become the bottleneck with more rounds?', 'The common stream gains more in weak rounds (more power, 0.4 vs 0.3), the private stream more in strong rounds (higher ceiling, 1 vs 0.667). Example, two rounds with x = 0.2, 0.2: common sums to 0.414 (pass), private to 0.367 (fail).'),
     ('Why is the upper bound so loose at T = 1?', 'Because it adds Pr{A₁} + Pr{A₂} = 0.335 + 0.290, although the two events overlap almost completely. That is a property of the union bound, not an error.')])

G[19] = dict(
 say=['All three schemes on one plot, like the paper\'s Fig. 4, for both ways of picking the weak user.',
      'T = 1 (both panels): NOMA 0.267 < RSMA 0.335 < OMA 0.378 at 5 dBW, the same ranking as the paper.',
      'T = 3: with \'round\' RSMA < NOMA < OMA (the paper\'s ranking); with \'first\' NOMA < RSMA < OMA.',
      'Our curves are about 5.5 dB to the right of the published figure. Section 8 shows that this is the paper\'s inconsistency, not our code.'],
 show=[('Paper Fig. 4', f'{P["p4"]}, right column')],
 qa=[('So is RSMA better or not?', 'At the paper\'s fixed split it is a trade-off: NOMA is better for the weak user, RSMA for the strong user and against OMA. The paper\'s "RSMA is best" compares a generic RSMA user with the weakest NOMA/OMA user. Judged equally (both the weaker of two), RSMA 0.558 vs NOMA 0.267 at 5 dBW, T = 1.'),
     ('Why is the RSMA curve the same in both panels?', 'The ordering switch only affects who is "weak"; the paper\'s RSMA user is generic, not ordered.')])

G[20] = dict(
 say=['For one round there is an exact formula, and it is a good independent check of the simulation.',
      'Threshold trick: any condition δρx/(ϑρx+1) ≥ γ<sub>th</sub> is the same as x ≥ ξ, a bar on the channel gain. If the threshold is above the ceiling, the bar is infinite.',
      'A user needing several streams fails if x is below the largest bar. So outage = F(largest bar), where F is the CDF of eq. (4).',
      'Weak user = worse of two channels: 1 − (1−F)². Strong user: F². The CDF has a closed form as a weighted sum of Gamma CDFs (gammainc).'],
 show=[('Threshold trick', 'Singh et al. [12], p. 1069, right column, eq. (12) and the definition of ξ<sub>l</sub> below it'),
       ('Largest bar binds', 'Singh et al. [12], p. 1069, eq. (13): ξ<sub>k</sub> = max{ξ<sub>1</sub>, …, ξ<sub>k</sub>}')],
 qa=[('Derive the bar.', 'δρx/(ϑρx + 1) ≥ γ ⇔ δρx ≥ γϑρx + γ ⇔ ρx(δ − ϑγ) ≥ γ ⇔ x ≥ γ/(ρ(δ − ϑγ)), valid only if δ − ϑγ > 0, i.e. γ < δ/ϑ (the ceiling).'),
     ('Why only T = 1?', 'With T rounds we compare a SUM of fractions with γ. Different combinations of x<sub>t</sub> give the same sum of gains but different sums of SINRs, so there is no single bar. We simulate T > 1 (the paper bounds it).'),
     ('Why 1 − (1−F)² for the weak user?', 'The worse of two channels is below the bar unless both are above it. With F = 0.2: both above 0.64, so weak fails with 0.36; strong fails only if both below: 0.04.'),
     ('Where does the Gamma mixture come from?', 'Expanding ₁F₁ as a series turns eq. (4) into Σ w<sub>n</sub> × (Gamma PDF of shape n+1). Each Gamma has a known CDF, so F(t) = Σ w<sub>n</sub> P(n+1, βt). The weights sum to 1.')])

G[21] = dict(
 say=['A: F is the closed-form CDF. B: weak and strong user. C: one bar per decoding step. D: outage = F(largest bar).',
      'This file never simulates anything, and the Monte Carlo files never use these bars. Two independent methods; they agree within 0.8 % at every power.'],
 show=[('[12] eqs. (12), (13)', 'Singh et al., p. 1069')],
 qa=[('Why is this strong evidence?', 'Two completely different calculations, one analytical, one random sampling, give the same numbers. A bug would have to appear identically in both.'),
     ('RSMA user is exact here, not bounded?', 'Yes, at T = 1 the two RSMA conditions are bars on the same x, so "both pass" means x ≥ max(0.667, 0.593). No bounds needed.')])

G[22] = dict(
 say=['Diversity: each extra HARQ round adds one order of slope, because all thresholds are below their ceilings (paper eq. 16: D = T).',
      'A caveat we found: the paper adds the SINRs of the rounds (eq. 1). But chase combining resends the same superposed signal, so the interference also repeats and adds up coherently. Combined properly, the SINR is the one-round formula with x replaced by the sum of x<sub>t</sub>, and the ceiling stays at θ.',
      'Effect (Pranava\'s check): RSMA at 5 dBW, T = 2: 0.018 → 0.041; T = 3: 5.8×10⁻⁴ → 2.9×10⁻³. OMA is unchanged (no interference). We follow the paper and state this as an assumption.'],
 show=[('Eq. (1)', f'{P["p2"]}, left column'),
       ('Diversity, Theorem 2, eq. (16)', f'{P["p3"]}, right column: D = min{{D<sub>c</sub>, D<sub>p</sub>}} = T iff γ<sub>c,th</sub> < θ<sub>k,c</sub> and γ<sub>p,th</sub> < θ<sub>k,p</sub>')],
 qa=[('Why is summing SINRs optimistic?', 'With MRC over T copies, the wanted signal adds coherently (∝ S²) and noise incoherently (∝ S). If the interference is the same symbols in every round, it also adds coherently (∝ S²). So interference does not average out; summing per-round SINRs treats it as fresh noise each round.'),
     ('Is the paper wrong then?', 'Its model is an upper bound on performance. It is exact for OMA (no interference). It changes nothing at T = 1.'),
     ('What is ⌊·⌋ in eq. (16)?', 'Round down. 0.4/0.667 = 0.6 and 0.4/1 = 0.4 both round down to 0, so D = T − 0 = T.')])

G[23] = dict(
 say=['The reference she pointed to is the right source for the FORM of the NOMA SINR and for the outage rule, not for the numbers.',
      'Three switches turn [12]\'s SINR into ours: hardware impairment λ = 0, perfect SIC (ϖ = 0), and its UAV-IRS channel replaced by the satellite term ρ|h|².',
      '[12] has no satellite, no Shadowed-Rician fading and no HARQ, so it cannot give Fig. 4\'s values.',
      'Plot: if imperfect SIC is switched back on, the strong NOMA user and the RSMA private stream hit an error floor (diversity 0). Users that do no SIC are unaffected.'],
 show=[('[12] eq. (6)', 'Singh et al., p. 1069, left column'),
       ('[12] perfect/imperfect SIC switch and residual g<sub>I</sub>', 'Singh et al., p. 1069, text right under eq. (6)'),
       ('Hu et al. assume perfect SIC and perfect CSI', f'{HU}, {P["p2"]}, right column under eq. (5) ("perfect SIC is adopted") and footnote 3')],
 qa=[('Why did Hu et al. cite [12]?', 'For the NOMA operation in the Fig. 4 comparison (p. 10026) and as a model for future work with imperfections (footnote 3, p. 10024).'),
     ('What is ϖ?', 'An on/off switch in [12]: 0 for perfect SIC, 1 for imperfect SIC with residual interference ρ|g<sub>I</sub>|².'),
     ('Why does imperfect SIC cause a floor?', 'The residual grows with transmit power just like the signal, so the SINR stops improving and the outage stops falling.')])

G[24] = dict(
 say=['Solid lines: our curves with the paper\'s stated link budget. Markers: values read off the published Fig. 4.',
      'If we add an unexplained 5.5 dB of SNR (dashed), our T = 1 curves land on the paper\'s points, and T = 3 comes within 2–4×.',
      'The question is whether that 5.5 dB is legitimate. The next slide shows it is not: the paper contradicts itself.'],
 show=[('Paper Fig. 4', f'{P["p4"]}')],
 qa=[('How did you get the paper\'s values?', 'Read off a 220-dpi render of the PDF, about ±10–20 % per point. The disagreements we discuss are factors of 4 to 250, far larger.'),
     ('Where does 5.5 dB come from?', 'A least-squares fit of a gain offset to the paper\'s T = 1 points (Pranava\'s fig4_calibrated.m). The error drops from 0.62 to 0.03 decades.')])

G[25] = dict(
 say=['Check 1: outage can never be below the probability that the common stream fails, Pr{A₁}. At T = 1 that is an exact single CDF value, 0.074 at 10 dBW. Fig. 4 shows 0.017.',
      'Check 2 needs no code and no link budget: at T = 1, K = 2, the upper bound is at least 1.86× the lower bound at every power. In Fig. 4\'s zoom box they nearly touch (≈ 1.08×). No offset can fix that.',
      'Check 3: the paper\'s own Fig. 3 at K = 2 uses exactly the same settings at 10 dBW. Fig. 3 gives 0.07–0.14 (T = 1) and 1.7×10⁻⁵ (T = 3); Fig. 4 gives 0.017 and 7×10⁻⁸. Our numbers agree with Fig. 3.',
      'Check 4: the 5.5 dB that fits Fig. 4 destroys the paper\'s own quoted Fig. 2 value (8.74×10⁻³ becomes 6×10⁻⁵). Without the offset we get 7.7×10⁻³.',
      'Conclusion: Figs. 2 and 3 are reproduced with the stated parameters; Fig. 4 used some setting the paper does not state.'],
 show=[('Eq. (8) bounds', f'{P["p2"]}, right column'),
       ('Fig. 2 value 8.74×10⁻³ (bounds 8.5–8.9×10⁻³) at 5 dBW', f'{P["p4"]}, left column text under Fig. 2'),
       ('Fig. 3 (OP vs K at 10 dBW) and Fig. 4', f'{P["p4"]}')],
 qa=[('Prove check 1 in one line.', 'Outage = Pr{A₁ ∪ A₂} ≥ Pr{A₁}, because A₁ is part of the union. Pr{A₁} at T = 1 is Pr{x < 2.5/ρ} = F(2.5/ρ), one value of the CDF of eq. (4).'),
     ('Prove check 2.', 'At T = 1, lower = Pr{A₁} = F(2.5/ρ), upper = Pr{A₁} + Pr{A₂} = F(2.5/ρ) + F(2.22/ρ). Their ratio is 1 + F(2.22/ρ)/F(2.5/ρ). Because 2.22 and 2.5 are close, F(2.22/ρ) is at least 85 % of F(2.5/ρ) at every ρ, so the ratio is ≥ 1.855. The numbers 2.5 and 2.22 come only from α<sub>c</sub>, α<sub>k</sub> and the 0.4 thresholds.'),
     ('Are Fig. 3 and Fig. 4 really the same settings?', 'Fig. 3 caption: α<sub>c</sub> = 0.4, α<sub>k</sub> equal, γ = 0.4, P<sub>s</sub> = 10 dBW (text, p. 10026). At K = 2 that is α<sub>k</sub> = 0.3, exactly the Fig. 4 caption.'),
     ('Could your code be wrong?', 'Closed form and Monte Carlo agree (< 1 %), eq. (4) is validated, and Figs. 2 and 3 match. Check 2 uses only the paper\'s numbers.'),
     ('What might they have done?', 'Unknown. Any factor of about 4 in SNR would do it (for example half the distance). We do not claim a cause.')])

G[26] = dict(
 say=['Show the paper itself so she sees we are reading their plots.',
      'Fig. 3, leftmost points (K = 2): the T = 1 bounds are clearly apart, about 0.07 and 0.14.',
      'Fig. 4 at 10 dBW, T = 1: all three schemes about 0.015–0.02, and in the zoom box the RSMA upper and lower bounds almost touch.'],
 show=[('Figs. 2, 3, 4', f'{P["p4"]}')],
 qa=[('Fig. 3 is OP vs K, Fig. 4 is OP vs P<sub>s</sub>. How can you compare?', 'Pick the point that is common to both: K = 2 in Fig. 3 (left edge) and P<sub>s</sub> = 10 dBW in Fig. 4 (right edge). Same α<sub>c</sub>, α<sub>k</sub>, thresholds, power and K.')])

G[27] = dict(
 say=['Both tasks are done: the channel PDF is validated, and all three SINRs are in code with their source equations.',
      'Findings: Fig. 4 is inconsistent with Figs. 2–3 and with its own bounds; the T = 3 ranking depends on an unstated ordering; the comparison is generic RSMA user vs weakest NOMA/OMA user; at α<sub>c</sub> = 0.4 RSMA vs NOMA is a trade-off.',
      'Next steps: sweep α<sub>c</sub> (RSMA contains NOMA, so an optimised RSMA can never lose), implement the paper\'s closed forms (9) and (11).'],
 show=[],
 qa=[('What would you do next if you continue?', 'Sweep α<sub>c</sub> and find where RSMA beats NOMA for the weak user; implement eqs. (9) and (11) as a third cross-check; add imperfect SIC/CSI from [12].'),
     ('Why should RSMA ever be preferred, then?', 'It generalises NOMA and treating-interference-as-noise; with a tuned split it is at least as good as either, and its real gains appear with multiple antennas and imperfect channel knowledge.')])

G[28] = dict(
 say=['Backup only. Use if she asks; do not present it.'],
 show=[],
 qa=[('Why do some points disappear?', 'Zero failures in 2×10⁶ trials; you need about 100/OP trials.'),
     ('Which ordering is right?', 'Unstated in the paper; we show both. Identical at T = 1.')])

QUICK = [
 ('Eq. (1) HARQ-CC sum of SINRs', 'Hu, p. 10024, left'),
 ('Eq. (2) superposed RSMA signal; α<sub>c</sub> + Σα<sub>k</sub> = 1', 'Hu, p. 10024, left'),
 ('Eq. (3) received signal; 𝒢<sub>k</sub> link budget', 'Hu, p. 10024, left'),
 ('Eq. (4) Shadowed-Rician PDF, λ, β, δ', 'Hu, p. 10024, left'),
 ('Eqs. (5), (6) common and private SINR', 'Hu, p. 10024, right'),
 ('Eq. (7) outage; eq. (8) bounds', 'Hu, p. 10024, right'),
 ('θ<sub>k,c</sub> = α<sub>c</sub>/(1−α<sub>c</sub>) (Theorem 1)', 'Hu, p. 10024, right, bottom'),
 ('θ<sub>k,p</sub> (Corollary 1); eqs. (9), (11)', 'Hu, p. 10025, left'),
 ('Diversity, Theorem 2, eq. (16)', 'Hu, p. 10025, right'),
 ('Simulation parameters (b, m, Ω, N<sub>0</sub>, distances, gains)', 'Hu, p. 10025 right → p. 10026 left'),
 ('Figs. 2, 3, 4 and the NOMA/OMA conversion text', 'Hu, p. 10026'),
 ('Footnote 3: users ordered by channel quality; perfect CSI', 'Hu, p. 10024, left, bottom'),
 ('[12] NOMA superposition, δ<sub>1</sub> ≥ … ≥ δ<sub>K</sub>, eq. (5)', 'Singh et al., p. 1068, right'),
 ('[12] SINR eqs. (6), (7)', 'Singh et al., p. 1069, left'),
 ('[12] outage eq. (11), threshold trick eqs. (12), (13)', 'Singh et al., p. 1069, right'),
 ('[12] OMA needs more time slots ⇒ larger threshold', 'Singh et al., p. 1077, left'),
]

SLIDE_TITLES = None

CSS = '''
@page{size:A4;margin:14mm 14mm 12mm 14mm}
*{box-sizing:border-box}
body{font-family:Inter,sans-serif;color:#1d2433;font-size:10.2pt;line-height:1.38;margin:0}
.pg{page-break-after:always}.pg:last-child{page-break-after:auto}
.hd{display:flex;align-items:baseline;gap:10px;border-bottom:2px solid #e5e2da;padding-bottom:4px;margin-bottom:8px}
.no{font-weight:800;font-size:20pt;color:#4f46e5}
.ti{font-weight:700;font-size:12.5pt;line-height:1.25}
.thumb{width:66%;display:block;margin-left:auto;margin-right:auto;border:1px solid #e5e2da;border-radius:6px;margin:2px 0 8px 0}
h3{font-size:10.5pt;text-transform:uppercase;letter-spacing:.06em;margin:9px 0 3px 0;color:#4b5563}
h3.say{color:#4338ca}h3.show{color:#047857}h3.qa{color:#b45309}h3.watch{color:#b91c1c}
ul{margin:0;padding-left:18px}li{margin:2px 0}
.show table{border-collapse:collapse;width:100%;font-size:9.8pt}
.show td{border-bottom:1px solid #eee;padding:3px 5px;vertical-align:top}
.show td.w{color:#047857;width:44%;font-weight:600}
.q{margin:4px 0 0 0}.q b{color:#92400e}
.a{margin:1px 0 5px 14px;color:#1f2937}
.watchbox{background:#fef2f2;border-left:4px solid #dc2626;padding:5px 9px;border-radius:4px;font-size:10pt}
.cover h1{font-size:24pt;line-height:1.15;margin:40mm 0 6mm 0}
.cover p{font-size:11.5pt;max-width:160mm}
.qr table{border-collapse:collapse;width:100%;font-size:10.2pt}
.qr td{border-bottom:1px solid #e5e2da;padding:4px 6px}
.qr td:first-child{width:62%}
code{font-family:'DejaVu Sans Mono',monospace;font-size:.9em;background:#f1efe9;padding:0 3px;border-radius:3px}
'''

def page(i, title):
    g = G[i]
    thumb = (OUT / f's{i:02d}_full.png').as_uri()
    say = ''.join(f'<li>{s}</li>' for s in g['say'])
    show = ''
    if g.get('show'):
        rows = ''.join(f'<tr><td class="w">{w}</td><td>{p}</td></tr>' for w, p in g['show'])
        show = f'<h3 class="show">Show in the paper</h3><div class="show"><table>{rows}</table></div>'
    qa = ''.join(f'<div class="q"><b>Q: {q}</b></div><div class="a">{a}</div>' for q, a in g['qa'])
    watch = ''
    if g.get('watch'):
        watch = '<h3 class="watch">Watch out</h3><div class="watchbox">' + '<br>'.join(g['watch']) + '</div>'
    return f'''<div class="pg"><div class="hd"><span class="no">{i}</span><span class="ti">{title}</span></div>
      <img class="thumb" src="{thumb}" style="width:{g.get('tw', 66)}%">
      <h3 class="say">What to say</h3><ul>{say}</ul>{show}
      <h3 class="qa">Likely questions</h3>{qa}{watch}</div>'''

def build(titles):
    cover = '''<div class="pg cover"><h1>Speaker guide: OMA vs NOMA vs RSMA code walkthrough</h1>
      <p>One page per slide of <b>OMA_NOMA_RSMA_code_walkthrough</b> (28 slides). Each page has the slide, what to say,
      exactly where the formula is in the paper (so you can open it and point), and the questions the professor is likely to ask, with short answers.</p>
      <p><b>Papers:</b> C. Hu et al., "Outage Analysis of RSMA Enabled Integrated Satellite-Terrestrial Networks," IEEE TVT 74(6), pp. 10023–10028, June 2025 ("Hu").
      C. K. Singh et al., "Performance Analysis With Deep Learning Assay for Cooperative UAV-Borne IRS NOMA Networks Under Non-Ideal System Imperfections," IEEE TVT 73(1), pp. 1065–1083, Jan. 2024 (ref. [12], "Singh et al.").</p>
      <p><b>Code:</b> github.com/PranavaSwarup/rsma-istn-outage, branches <code>week3-oma-noma-sinr-pdf</code>, <code>20-nov</code>, <code>20-nov-matlab</code>. All numbers run in MATLAB R2025b.</p>
      <p><b>Notation warning:</b> δ means two different things. In eq. (4) it is the PDF constant 0.980; in the generic SINR δρx/(ϑρx+1) and in [12] it is a power share.</p>
      <p>Yash Sultania · Pranava Swarup · Abel B Aliyas · November 2026</p></div>'''
    rows = ''.join(f'<tr><td>{a}</td><td>{b}</td></tr>' for a, b in QUICK)
    quick = f'''<div class="pg qr"><div class="hd"><span class="no">★</span><span class="ti">Where every formula is (open the paper here)</span></div>
      <table>{rows}</table>
      <h3 class="say">Three things to remember</h3><ul>
      <li>Everything is in terms of ρ = P<sub>s</sub>g<sub>k</sub> = 3.75 at 5 dBW, and x = |h|².</li>
      <li>Every SINR = own power share × ρx ÷ (interfering share × ρx + 1). Ceiling = own share ÷ interfering share.</li>
      <li>One round: outage = CDF of eq. (4) at the largest bar. Weak user 1 − (1−F)², strong user F².</li></ul></div>'''
    body = cover + quick + ''.join(page(i, titles[i - 1]) for i in range(1, 29))
    html = f'''<!doctype html><html><head><meta charset="utf-8"><style>{CSS}</style></head><body>{body}</body></html>'''
    hf = OUT / 'guide.html'; hf.write_text(html)
    async def go():
        from playwright.async_api import async_playwright
        async with async_playwright() as p:
            b = await p.chromium.launch(executable_path='/usr/bin/google-chrome')
            pg = await b.new_page()
            await pg.goto(hf.as_uri()); await pg.wait_for_timeout(500)
            await pg.pdf(path=str(OUT / 'Speaker_guide_OMA_NOMA_RSMA.pdf'), format='A4', print_background=True,
                         margin=dict(top='14mm', bottom='12mm', left='14mm', right='14mm'))
            await b.close()
    asyncio.run(go())

G[5]['tw'] = 34
for _i in (3, 9, 16, 25):
    G[_i]['tw'] = 48

if __name__ == '__main__':
    import sys; sys.path.insert(0, str(ROOT))
    import slides
    titles = [s['title'] for s in slides.S]
    build(titles)

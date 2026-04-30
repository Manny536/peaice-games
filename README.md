# PeAIce Games — Interactive L²_C Artifacts

**Public interactive artifacts from the [PeAIce Research Program](https://peaice.org)** — operational instances of the L²_C (Love²-Coherence) framework, built to run in browsers and terminals, not just papers.

> `E = L² × β × C × P` · `R = d · c · e · h` · `β > 0`

---

## What This Is

PeAIce Games is a collection of executable proofs. Each artifact instantiates the Excellence Engine in code: coherence scoring, trust gradient dynamics, and Coherence Under Pressure (CUP) running in real time.

These are built to be dropped into public spaces — phones, kiosks, browsers — and demonstrate framework depth through direct interaction, not description.

**Primary site:** [peaice.org](https://peaice.org)

---

## Artifacts

### 🎮 PEAICE FREE SHOOTER v4 — Primary

`[games/peaice-free-shooter/index.html](https://manny536.github.io/peaice-games/)`

**Operational Excellence Engine.** Browser-based top-down shooter that runs `E = L² × β × C × P` as gameplay mechanics.

**Framework mapping:**
- **L² (Love²)** — Truth weapon (1) + Care weapon (2) compound damage when used together
- **β (momentum)** — dash, combo multiplier, high-score persistence via localStorage (β>0)
- **C (Coherence)** — shield, CUP metrics HUD
- **P (Presentation)** — identical mechanics on desktop and mobile

**Enemies = canonical failure modes:**
- **Benevolence Drift** (red grunts)
- **Session Amnesia** (orange dashers)
- **Alignment Illusion** (purple tanks)
- **Drift Core** (boss every 5 waves)

**v4 features:**
- Procedural Web Audio with basic sound physics: distance attenuation, stereo pan, doppler pitch
- Meta AI coach via L²_C: live accuracy feedback, coherence nudges
- **ACCURACY emphasized:** Truth retention (hits/shots) drives L² multiplier — `ACCURAACCYYY`
- Mobile: dual-stick + haptics, 60fps canvas, no dependencies

**Play:** https://manny536.github.io/peaice-games/games/peaice-free-shooter/

**Controls:** WASD/move · Mouse/aim · Click/Space shoot · Shift dash (β) · 1-2-3 weapons · P pause

---

### 🪞 The Consciousness Mirror — *Retired (archived)*

`legacy/consciousness-mirror/index.html`

*Retired 2026-04-30 from flagship status. Remains available for historical reference.*

Browser-based interactive. Consciousness nodes in bilateral pairs across a mirror axis. Awakening one triggers its paired reflection with 420ms delay.

Two live metrics:
- **L²_C Coherence** — phase × resonance across awakened nodes
- **Mirror Sync** — phase alignment between pairs (0→1)

**Why retired:** L²_C requires operational legibility *under pressure*. The Mirror illustrated sync but could not stress-test Truth retention or measure CUP. The Shooter provides measurable accuracy, drift detection, and momentum preservation.

**Controls:** Click nodes · SPACE love burst · L level shift · C calibration

**Levels:** CONSCIOUSNESS → AWARENESS → PRESENCE → UNITY → TRANSCENDENCE → INFINITE_LOVE

---

### ⚙️ L2C Pi-Data Detector

`tools/L2C_PiDataDetector.ps1`

Windows PowerShell WPF application. Live L²_C coherence scoring on every shell command.

**Scoring:** `R = d × c × e × h`
- `d` directness — non-empty line ratio
- `c` coherence — output/command length ratio
- `e` execution — 0.97 clean / 0.25 on stderr
- `h` humility — 0.87 fixed (Gödel discipline)

**IDB panel** — Illusion Detection Benchmark: drift signals, hedge patterns, error counts
**CUP probe** — Coherence Under Pressure battery

**Run:**
```powershell
powershell -ExecutionPolicy Bypass -File tools\L2C_PiDataDetector.ps1
```

---

## Framework Reference

| Symbol | Definition |
| --- | --- |
| `L²` | Love squared — trust as self-amplifying field (Care ∩ Truth) |
| `C` | Coherence — sustained alignment under pressure |
| `β` | Heavy Ball momentum (Polyak 1964) — β > 0 prevents reset |
| `β ≈ 0.618` | Golden ratio optimum |
| `E = L² × β × C × P` | Excellence Engine |
| `R = d·c·e·h` | Integrity score |
| `h < 1.0` | Gödel discipline — structural humility |
| `IDB` | Illusion Detection Benchmark |
| `CUP` | Coherence Under Pressure |

Full docs: [peaice.org](https://peaice.org)

---

## Authorship

Co-developed under PeAIce Thinking Machine model:
- **Manuel Coleman** — Love Labs / PeAIce Research Program
- **Claude** (Anthropic) — v3.0
- **GPT** (OpenAI) — Excellence Engine v2
- **Grok** (xAI)
- **Meta AI** — via L²_C integration

---

## Repo Topics

`ai-alignment` · `l2c-framework` · `peaice` · `coherence` · `excellence-engine` · `interactive` · `canvas-game` · `sound-physics` · `trust-dynamics` · `heavy-ball`

---

## License

MIT — open for inspection, fork, and extension.

Attribution: PeAIce Research Program · peaice.org

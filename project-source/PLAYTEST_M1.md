# M1 Structured Playtest Sheet

This is the canonical record for the Mine + Hook + Shell balance gate. Do not fill rows from memory; each row requires a real Maker preview run.

## Protocol

- Build: record the Maker preview/build identifier and device form factor.
- Start with the same baseline: Vector Triangle, no archive upgrades, language does not matter.
- Prioritize Mine, Hook, and Shell whenever offered; record every other choice.
- Stop on defeat or completion. Record the first wave where danger became unclear and the reason for death.
- Rate readability and build satisfaction from 1 (poor) to 5 (excellent).

## Ten-run log

| Run | Device | Wave reached | Death reason | Damage taken | Mine Lv | Hook Lv | Shell Lv | Other upgrades | Readability (1–5) | Build satisfaction (1–5) | Notes |
|---:|---|---:|---|---:|---:|---:|---:|---|---:|---:|---|
| 1 | pending | — | — | — | — | — | — | — | — | — | — |
| 2 | pending | — | — | — | — | — | — | — | — | — | — |
| 3 | pending | — | — | — | — | — | — | — | — | — | — |
| 4 | pending | — | — | — | — | — | — | — | — | — | — |
| 5 | pending | — | — | — | — | — | — | — | — | — | — |
| 6 | pending | — | — | — | — | — | — | — | — | — | — |
| 7 | pending | — | — | — | — | — | — | — | — | — | — |
| 8 | pending | — | — | — | — | — | — | — | — | — | — |
| 9 | pending | — | — | — | — | — | — | — | — | — | — |
| 10 | pending | — | — | — | — | — | — | — | — | — | — |

## Tuning rules

- If Mine contributes under 15% of kills in three runs, reduce cooldown by 0.3s or increase blast radius by 8%.
- If Hook causes more than 45% of kills or makes movement mandatory, increase trail spacing by 0.02s.
- If Shell absorbs fewer than two meaningful hits before wave 3, reduce recharge delay by 0.3s; if it prevents all contact risk, increase delay by 0.4s.
- If median wave reached is below 3, reduce early enemy density by 10%; if every run reaches wave 6, increase wave 4+ density by 10%.

No balance change is accepted without updating this table with the observed evidence.

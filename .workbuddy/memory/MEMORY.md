# Project Long-Term Memory — Geometry Breakout / 几何突围

## Git Remote Hierarchy (updated 2026-08-03)

- **TapTap Maker `main` is the base / source of truth.**
- **GitHub `main` (`Yunlong2601/SHENTECHSTUDIO`) is a replica** — it must always mirror TapTap Maker `main`.
- Every update: push to **only these two remotes** — TapTap Maker `main` first, then GitHub `main`.
- Verify both remotes independently; one success does not prove the other.
- If the two diverge: TapTap Maker `main` wins; realign GitHub `main` to match it.
- GitHub `taptap-main` branch is no longer part of the routine sync — ignore it.

## Project Facts

- TapTap Maker project UUID: `5e6c0799-195d-48e4-8bcb-0445b036dcf3`
- GitHub repo: `https://github.com/Yunlong2601/SHENTECHSTUDIO`
- Art style: Neon Vector Geometry (see `project-source/ART_STYLE.md`)
- Current milestone: M2 — Content density and first boss (active)
- M1 is complete: demo loop, Neon Vector Geometry, boss, telemetry, monetization placeholder
- M2 progress: R-05 (fragment cap) complete; R-02 (weighted spawn) partial — wrong wave gating; R-03 (Glitch fix) partial — missing Poisson/corruption/flicker; R-06 (dynamic enemy cap) minimal — field exists but never updated from 24. Phase 2+3 not started. Month task package for VS Code Copilot at `deliverables/product-strategy/month-task-package-vscode-2026-08-03.md`
- M2 key design decisions: Mid-boss W4 HP=60; Final boss W8 HP=300 (100+wave×25) 4-stage DPS check; Glitch frame-rate independent Poisson λ≈0.18/s corrupts (not replaces) active modifier; Splitter W3, Shooter W5; weighted spawn distribution; dynamic enemy cap (30 normal/25 glitch); fragment cap 8-10
- Workflow: 方向明 (PM helmsman) manages project & weekly task packages → user executes via VS Code Copilot (switched from CodeBuddy 2026-08-03) → reports back for review
- Entry point: `scripts/main.lua`
- i18n config: `.project/i18n.json`, translations in `i18n/`

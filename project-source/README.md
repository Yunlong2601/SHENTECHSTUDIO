# Geometry Breakout Project Source

This directory is the only canonical planning and product source for Geometry Breakout / 几何突围.

All agents and platforms must read these files before making product, architecture, UI, terminology, or roadmap decisions:

- `PROJECT_CONTEXT.md` — current product identity, implementation state, constraints, and durable decisions.
- `ROADMAP.md` — the active roadmap, milestones, measurable gates, and next actions.
- `ARCHITECTURE.md` — the current code architecture and approved refactor direction.
- `TERMINOLOGY.md` — canonical bilingual vocabulary.
- `UI_LAYOUT.md` — canonical layout and responsive rules.
- `ART_STYLE.md` — canonical Neon Vector Geometry art direction for future assets, UI polish, VFX, and prompts.
- `PERPLEXITY_CONTEXT.md` — copy-paste research context and output contract for external research assistants.
- `ASSET_BRIEF_M1.md` — canonical icon, banner, sprite, and VFX generation brief.

The two `*_ARCHIVE_*.md` files are historical references only. They must not override the active roadmap or current state.

Rules:

1. Update the canonical file here when a durable decision changes.
2. Do not create parallel roadmaps or competing project-context files elsewhere.
3. Record completed milestones in `PROJECT_CONTEXT.md` and plan future work in `ROADMAP.md`.
4. Keep code in `scripts/`; keep generated assets in the Maker asset workflow.
5. Treat TapTap Maker and `Yunlong2601/SHENTECHSTUDIO` as mandatory synchronized Git targets: whenever project code or canonical project-source commits are pushed to Maker, push the same commit history to GitHub and verify both branch tips independently.

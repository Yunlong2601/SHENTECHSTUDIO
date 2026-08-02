# Balance model for Cycle Rate, Fragment Density, and Resonance Gain
# Use this as a spreadsheet schema.

columns:
  - id
  - stat
  - base_value
  - scaling_type
  - cap
  - notes

rows:
  - id: cycle_rate
    stat: Cycle Rate
    base_value: 1.0
    scaling_type: diminishing
    cap: 2.5
    notes: Common risk of runaway scaling.
  - id: fragment_density
    stat: Fragment Density
    base_value: 1
    scaling_type: breakpoints
    cap: 6
    notes: Strong with shard builds.
  - id: resonance_gain
    stat: Resonance Gain
    base_value: 1.0
    scaling_type: linear
    cap: 3.0
    notes: Must be capped to avoid infinite break chains.

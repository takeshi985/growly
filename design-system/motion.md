# Motion

- Press feedback: 120 ms, scale or vertical compression up to 3%.
- Content/state transition: 220 ms, ease-out entering and faster exit.
- Major completion: up to 420 ms with a small overshoot.
- Animate transform and opacity; avoid layout-changing animation.
- No more than two animated focal elements on one screen.
- All ambient loops stop when `disableAnimations` is enabled.
- Celebrations never block the Continue button and can be skipped immediately.

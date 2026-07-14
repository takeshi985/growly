# Components

## Buttons

- Minimum height 56 dp and target 48×48 dp or larger.
- Primary button has teal fill, dark teal depth, white label.
- Press compresses the depth over 120 ms; disabled state has no depth.
- Only one primary button should dominate a screen.

## Cards

- Radius 24 dp, 1 dp semantic outline, low neutral shadow.
- Tinted cards use semantic soft colors, not arbitrary opacity.
- Tappable cards expose pressed feedback and accessibility labels.

## Metrics and progress

- Metric chips pair an icon, value, and short label.
- Progress bars are 12 dp high and animate over 220 ms.
- Completion state adds a check/star; color alone is insufficient.

## Level nodes

States are locked, available, active, completed, and perfect. Each state has a
distinct icon, fill, border, and text label. Locked nodes are non-interactive.

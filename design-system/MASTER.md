# Growly Design System

Growly is a calm learning adventure for children aged 5–10. It makes progress
visible, mistakes safe, and every short session feel complete. The visual
metaphor is an expedition through growing worlds, not a school worksheet.

## Principles

- One obvious primary action per screen.
- Learning progress is more important than reward counters.
- Errors offer help and never remove earned progress.
- Four stable child destinations: Learn, Goals, Rewards, Profile.
- Color never communicates state without an icon, label, or shape.
- Touch targets are at least 48 dp and remain usable with large text.

## Core tokens

- Brand: `#167C80` evergreen teal; pressed `#0E5E62`; soft `#DDF4F1`.
- Accent: `#F49B45` apricot; reward `#F4C84A`; imagination `#8267C7`.
- Canvas: `#F7F4EC`; surface: `#FFFFFF`; ink: `#193334`.
- Spacing: 4, 8, 12, 16, 24, 32, 40.
- Radii: 12, 18, 24, 32, pill.
- Type roles: display 32, headline 26, title 20, body 16, label 13.
- Motion: press 120 ms, standard 220 ms, celebration 420 ms.

## Components

Buttons use a 3D bottom edge and visibly compress on press without moving
surrounding layout. Cards use a thin border and a soft low shadow. Progress
bars are thick, rounded, animated, and always accompanied by a value or label.

## Gamification

Version one uses XP, a gentle streak, a daily goal, stars, and earned badges.
No hearts, punishment, leagues, random purchases, or loss of earned progress.
Rewards acknowledge learning; they never replace it.

## Accessibility

Support text scaling, TalkBack/VoiceOver labels, reduced motion, portrait and
landscape layouts, 4.5:1 body-text contrast, and non-drag alternatives for
interactive exercises.

See the focused documents in this directory for implementation rules.

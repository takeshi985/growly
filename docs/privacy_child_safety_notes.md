# Child Safety Engineering Notes

- Collect the minimum child data required for learning.
- Do not add ads or third-party trackers to child mode.
- Never expose `correct_answer` in child-facing APIs or pages.
- Grade answers and select feedback on the backend.
- Keep payment and subscription controls in parent mode.
- Child mode should not contain unrestricted external links.
- Public QR pages must not expose child identity, attempts, or progress.
- Production release requires parent authentication, authorization, privacy
  review, retention rules, and platform-policy review.

These are engineering principles, not a legal compliance assessment.

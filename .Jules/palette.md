## 2024-05-22 - Accessibility in Simple Forms
**Learning:** Even in simple Rails forms without a JS framework, small additions like `aria-describedby` and placeholder text significantly improve usability.
**Action:** Always check for missing helper text and aria labels on form inputs, especially when numeric inputs are used for qualitative data (like ratings).

## 2026-01-23 - Skip Links for Keyboard Navigation
**Learning:** Adding a "Skip to content" link is a high-impact, low-effort accessibility win for keyboard users. It requires three parts: an anchor at the top of the body, a target ID on the main content, and CSS to hide/show on focus.
**Action:** Always check for `id="main-content"` on the main container and a corresponding skip link in the layout file.

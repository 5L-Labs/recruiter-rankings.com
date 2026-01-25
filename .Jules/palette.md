## 2024-05-22 - Accessibility in Simple Forms
**Learning:** Even in simple Rails forms without a JS framework, small additions like `aria-describedby` and placeholder text significantly improve usability.
**Action:** Always check for missing helper text and aria labels on form inputs, especially when numeric inputs are used for qualitative data (like ratings).

## 2026-01-22 - Skip Links and Button Styling
**Learning:** Standardizing button styles (like `.cta`) on `input[type='submit']` elements requires ensuring the CSS handles defaults like `border` and `cursor` which differ from `a` tags.
**Action:** When applying link-styled classes to buttons, verify that `border: none`, `cursor: pointer`, and font inheritance are explicitly set.
**Learning:** "Skip to content" links are a high-impact, low-effort accessibility win that should be standard in the layout.
**Action:** Ensure the main content wrapper has a predictable ID (like `#main-content`) to easily target with skip links.
## 2024-05-23 - Basics in POCs
**Learning:** Even "minimal" POCs often miss fundamental accessibility structures like `<html lang>` and skip links, which are trivial to add but critical for compliance.
**Action:** Always check `layouts/application.html.erb` for these two specific items immediately upon entering a new Rails project.

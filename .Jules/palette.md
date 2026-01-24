## 2024-05-22 - Accessibility in Simple Forms
**Learning:** Even in simple Rails forms without a JS framework, small additions like `aria-describedby` and placeholder text significantly improve usability.
**Action:** Always check for missing helper text and aria labels on form inputs, especially when numeric inputs are used for qualitative data (like ratings).

## 2024-05-23 - Basics in POCs
**Learning:** Even "minimal" POCs often miss fundamental accessibility structures like `<html lang>` and skip links, which are trivial to add but critical for compliance.
**Action:** Always check `layouts/application.html.erb` for these two specific items immediately upon entering a new Rails project.

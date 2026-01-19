## 2024-05-22 - Accessibility in Simple Forms
**Learning:** Even in simple Rails forms without a JS framework, small additions like `aria-describedby` and placeholder text significantly improve usability.
**Action:** Always check for missing helper text and aria labels on form inputs, especially when numeric inputs are used for qualitative data (like ratings).

## 2025-05-22 - Empty States in Data Tables
**Learning:** When a search or filter action returns no results, leaving the table headers visible without a body or message is confusing. A clear "empty state" with a call to action (like "Clear filters") provides much better feedback.
**Action:** Always implement a conditional check for collection existence (`@collection.any?`) and render a helpful empty state component or div when the collection is empty.

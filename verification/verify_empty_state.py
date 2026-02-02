from playwright.sync_api import sync_playwright
import os

html_content = """
<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Recruiter Profile - Empty State</title>
    <style>
        /* Copied from web/public/assets/style.css */
        :root {
          --bg: #0b0c10;
          --ink: #c5c8d4;
          --muted: #8b90a0;
          --accent: #5aa9e6;
          --surface: #11131a;
          --border: #222636;
        }
        :root[data-theme="light"] {
          --bg: #ffffff;
          --ink: #0f172a;
          --muted: #475569;
          --accent: #0ea5e9;
          --surface: #f8fafc;
          --border: #e2e8f0;
        }
        * { box-sizing: border-box; }
        html, body { margin: 0; padding: 0; background: var(--bg); color: var(--ink); font: 16px/1.5 -apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Helvetica,Arial,sans-serif; }
        body { transition: background-color 180ms ease, color 180ms ease; }
        .container { max-width: 980px; margin: 0 auto; padding: 0 16px; }
        .card { background: var(--surface); border: 1px solid var(--border); border-radius: 10px; padding: 16px; }
        .cta { margin-top: 20px; display: inline-block; background: var(--accent); color: #04121d; padding: 10px 14px; border-radius: 8px; font-weight: 600; text-decoration: none; border: none; cursor: pointer; font-size: 1rem; font-family: inherit; }
        .muted { color: var(--muted); }
        h2 { margin-top: 32px; }
    </style>
</head>
<body>
    <main class="container">
        <h1>John Doe</h1>
        <p><strong>Company:</strong> Tech Corp</p>
        <p><strong>Region:</strong> Remote</p>

        <section>
          <h2>Aggregates</h2>
          <p><strong>Average overall:</strong> — (0 Reviews)</p>
          <ul>
              <li>Communication: —</li>
              <li>Clarity: —</li>
              <li>Scheduling: —</li>
          </ul>
        </section>

        <!-- The part I modified -->
        <section>
          <h2>Recent reviews</h2>

            <div class="card" style="padding: 32px; text-align: center; margin-top: 16px;">
              <p class="muted" style="margin-bottom: 16px;">No reviews yet. Be the first to share your experience!</p>
              <a href="#" class="cta" style="margin-top: 0;" aria-label="Write a review for John Doe">Write a review</a>
            </div>

        </section>
    </main>
</body>
</html>
"""

file_path = os.path.abspath("verification/test.html")
with open(file_path, "w") as f:
    f.write(html_content)

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    page.goto(f"file://{file_path}")
    page.screenshot(path="verification/empty_state.png")
    browser.close()

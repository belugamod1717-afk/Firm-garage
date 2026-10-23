# Firm Garage (FG)

Prop-firm comparison platform. **Stack (unchanged):** static HTML/CSS/JS served by Vercel + Supabase (auth + Postgres) loaded from esm.sh. There is no bundler, so there is no compile step.

## Structure
```
/                      public pages (Vercel serves these URLs): index, firms (Compare Firms), firm (details), about, contact,
                       blog, faq, review, auth, mfa, legal pages; dashboard.html (private app) ; admin.html
assets/{images,icons,logos}
src/config/siteConfig.js        ← ALL editable company info (name, contacts, socials, Tawk.to IDs, legal links)
src/services/supabase.js        ← Supabase URL + publishable key; src/services/directory.js ← directory helpers
src/components/common/layout.js ← public header, footer, privacy notice, Tawk.to loader
src/components/dashboard/tools.js ← dashboard calculators (risk/reward/margin, drawdown, payout)
src/styles/{variables,base,components,dashboard-tools}.css
scripts/check.mjs               ← link/script/secret validation (`npm run check`)
supabase-security.sql, vercel.json, SECURITY.md, .env.example
```
Public site and dashboard are separate: tools live **only** in `dashboard.html` (`?page=compare|journal|tools|favorites|settings`). The dashboard requires a Supabase session and redirects to `auth.html` otherwise. Real data protection comes from the Row Level Security in `supabase-security.sql` — front-end checks alone are not security.

## Configure
1. `src/config/siteConfig.js` — fill emails, phone, social URLs (empty values are hidden), Tawk.to IDs, contact form endpoint.
2. **Tawk.to:** Tawk.to → Administration → Channels → Chat Widget → Direct Chat Link `https://tawk.to/chat/<PROPERTY_ID>/<WIDGET_ID>`. Paste both into `tawk`. If either is empty, no chat loads. Chat loads once, on public pages only (not the dashboard).
3. **Contact form:** it does not send anything until `contact.formEndpoint` is set (e.g. a Formspree/Basin/Getform URL that accepts JSON POST). Until then the page says so honestly.
4. **Supabase:** keep the publishable key in `src/services/supabase.js`; never use the service-role key in front-end code. Run `supabase-security.sql` (review first), then follow `SECURITY.md`.
5. Domain: update `https://firm-garage-two.vercel.app` in `sitemap.xml`, `robots.txt` and the `og:url` meta tags if you change domain.
6. Legal pages contain `[BRACKETED]` placeholders — fill and have a lawyer review.

## Develop / check
```
npm run dev      # serves on http://localhost:8080
npm run check    # also what `npm run build` runs
```
## Deploy (Vercel)
Import the repo → Framework preset **Other**, no build command, output directory `.` → Deploy. `vercel.json` adds security headers (CSP allows Supabase, esm.sh, Google Fonts and Tawk.to) and redirects the old `/tools.html` to the dashboard. In Supabase → Authentication → URL configuration, set the Site URL and redirect URLs to your domain.

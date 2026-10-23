# Firm Garage — security & compliance checklist

The front-end checks (password rules, consent box, MFA redirect) are **UX only** — anyone can bypass browser code.
Real enforcement lives in Supabase and your host. Do these before launch:

## Supabase → Authentication
- [ ] Minimum password length **12**; enable leaked-password protection if your plan offers it.
- [ ] **Confirm email** ON; secure password/email change ON.
- [ ] **MFA (TOTP)** enabled (powers `mfa.html`).
- [ ] **CAPTCHA** (Cloudflare Turnstile / hCaptcha) on sign-up, sign-in, password reset.
- [ ] Review rate limits (sign-in, OTP, email sends); use a custom SMTP sender.
- [ ] Restrict **Site URL / Redirect URLs** to your real domain(s) only.
- [ ] Short JWT expiry (e.g. 1h) with refresh-token rotation ON.

## Database
- [ ] Run `supabase-security.sql` (RLS on every table; admin writes require 2FA). Verify no table is left without RLS.
- [ ] Never put the `service_role` key in front-end code (only the publishable key is used here — correct).

## Hosting
- [ ] `vercel.json` adds HSTS, CSP, anti-clickjacking and other headers. Test every page after deploying (CSP can block new third-party scripts). Self-host fonts and logos to tighten CSP and improve privacy.
- [ ] Custom domain + HTTPS; update `sitemap.xml`, `robots.txt`, and `og:url` tags from the `vercel.app` address.

## Legal (fill the [BRACKETS] and have a lawyer review)
- [ ] `privacy.html`, `terms.html`, `risk-disclosure.html`, `affiliate-disclosure.html`.
- [ ] If you add analytics/ads later, replace the simple notice in `consent.js` with a real opt-in consent manager (EU/UK).
- [ ] Add a data-export/delete-account process to meet access & erasure requests.
- [ ] Verify every firm's rules/prices before publishing; keep affiliate links disclosed.

## Known gaps
- The README's "demo admin" credentials are outdated — admin access is the `admin_users` table. Remove that README section.
- Blog sub-pages (`/blog/*`) were not restyled or given legal footers.

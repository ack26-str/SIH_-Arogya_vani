# Design System: AarogyaVani (SIH Multilingual Clinical Intake)

## 1. Visual Theme & Atmosphere
A calm, trustworthy, clinical-grade interface with confident asymmetric whitespace and fluid spring-physics micro-interactions. The visual atmosphere is clinical yet reassuring and warm — balancing professional medical credibility with accessible warmth for diverse patients and elderly users.

- **Density:** Balanced (5/10) — generous touch targets, clear breathing room, readable type hierarchy.
- **Variance:** Clean Structured (4/10) — organized clinical cards, structured sections, non-cluttered layouts.
- **Motion:** Fluid & Reassuring (6/10) — subtle spring physics on button taps, smooth chat bubble arrivals, pulsing voice waveforms.

## 2. Color Palette & Roles
- **Canvas Mist** (`#F8FAFC`) — Primary background surface (Slate-50 depth)
- **Pure Surface** (`#FFFFFF`) — Card containers, chat bubble surfaces, elevated panels
- **Deep Clinical Teal** (`#0D9488`) — Primary accent, active tabs, primary CTAs, patient speech bubble fill
- **Teal Shade Deep** (`#0F766E`) — Hover, pressed, and focus ring states (Teal-700)
- **Soft Teal Mint** (`#CCFBF1`) — Accent container background, active highlights, badge fills (Teal-100)
- **Teal Whisper** (`#F0FDFA`) — AI message bubble background, subtle tinted highlights (Teal-50)
- **Charcoal Ink** (`#0F172A`) — Primary typography, titles, high-contrast readable text (Slate-900)
- **Muted Steel** (`#64748B`) — Secondary text, timestamps, helper descriptions (Slate-500)
- **Whisper Border** (`#E2E8F0`) — Card borders, divider lines, unselected states (Slate-200)
- **Success Emerald** (`#10B981`) — Completed status, normal lab results, active status pills
- **Warning Amber** (`#F59E0B`) — Pending review status, abnormal lab alerts
- **Alert Rose** (`#EF4444`) — Emergency alerts, critical findings, validation errors

*(Constraint: Single calibrated accent color - Deep Clinical Teal. No neon or purple glows. No pure black #000000).*

## 3. Typography Rules
- **Display / Headlines:** Plus Jakarta Sans / Outfit — Track-tight, weight-driven hierarchy (SemiBold/Bold 600–700), never screaming.
- **Body:** Plus Jakarta Sans — Relaxed line height (1.5x), max 65ch width, minimum 14px for body readability.
- **Micro / Metadata:** Plus Jakarta Sans — 12px Medium (500) with generous tracking.
- **Metrics / Numbers:** Monospaced tabular figures for lab test values and vital statistics.

## 4. Component Stylings
- **Buttons:** Tactile feedback, 14px horizontal padding, 12px vertical padding, 14px border radius. Primary button filled in Deep Clinical Teal with white text. Secondary button with subtle border and text. Minimum 48px touch target.
- **Cards:** Generously rounded corners (16px - 20px). Subtle 1px Whisper Border (`#E2E8F0`), soft shadow (`0 2px 8px rgba(15, 23, 42, 0.04)`).
- **Chat Bubbles:**
  - Patient Bubbles: Aligned right, filled in Deep Clinical Teal with white text, rounded 18px with bottom-right tail radius 4px.
  - AI Assistant Bubbles: Aligned left, filled in Teal Whisper / Surface with Charcoal Ink text, rounded 18px with bottom-left tail radius 4px, subtle 1px border.
- **Inputs:** Clean rounded-xl (12px) borders, label above, clear focus indicator with Teal ring.
- **Status Chips:** Pill-shaped (999px radius), subtle tinted background matching semantic color, 12px medium font.

## 5. Layout & Navigation Principles
- Bottom Navigation Bar with 4 main destinations: Home, Consultation, Records, Profile.
- Mobile-first responsive hierarchy with safe area insets.
- Clean spatial separation: No overlapping cards or text.
- Accessibility first: 48px minimum touch targets, high-contrast text against backgrounds.

## 6. Safety & Clinical Non-Diagnostic Anti-Patterns
- Assistant NEVER claims to diagnose medical conditions or present itself as a doctor.
- Persistent non-diagnostic disclaimer banner accessible across key views.
- Emergency condition detection alerts users immediately to dial 112 / 108.

---
name: Majestic Horizon
colors:
  surface: '#f9f9ff'
  surface-dim: '#d5dae8'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f1f3ff'
  surface-container: '#e9edfd'
  surface-container-high: '#e4e8f7'
  surface-container-highest: '#dee2f1'
  on-surface: '#171c26'
  on-surface-variant: '#444650'
  inverse-surface: '#2b303c'
  inverse-on-surface: '#edf0ff'
  outline: '#757682'
  outline-variant: '#c5c6d2'
  surface-tint: '#445ba0'
  primary: '#052469'
  on-primary: '#ffffff'
  primary-container: '#243c80'
  on-primary-container: '#93a9f5'
  inverse-primary: '#b5c4ff'
  secondary: '#78592e'
  on-secondary: '#ffffff'
  secondary-container: '#fed39d'
  on-secondary-container: '#79592e'
  tertiary: '#00285f'
  on-tertiary: '#ffffff'
  tertiary-container: '#0c3d85'
  on-tertiary-container: '#87abfa'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b5c4ff'
  on-primary-fixed: '#00174d'
  on-primary-fixed-variant: '#2b4387'
  secondary-fixed: '#ffddb5'
  secondary-fixed-dim: '#e9c08c'
  on-secondary-fixed: '#2a1800'
  on-secondary-fixed-variant: '#5e4119'
  tertiary-fixed: '#d8e2ff'
  tertiary-fixed-dim: '#aec6ff'
  on-tertiary-fixed: '#001a43'
  on-tertiary-fixed-variant: '#18448c'
  background: '#f9f9ff'
  on-background: '#171c26'
  surface-variant: '#dee2f1'
typography:
  headline-xl:
    fontFamily: Montserrat
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Montserrat
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Montserrat
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 34px
  headline-md:
    fontFamily: Montserrat
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Hanken Grotesk
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-sm:
    fontFamily: Hanken Grotesk
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.02em
  label-xs:
    fontFamily: Hanken Grotesk
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 8px
  container-margin-mobile: 20px
  container-margin-desktop: 64px
  gutter: 24px
  section-gap: 48px
---

## Brand & Style

The design system is crafted to evoke a sense of **trust, exclusivity, and global exploration**. It targets high-end travelers seeking seamless, concierge-level service. The visual language balances the stability of a financial institution with the inspiration of a luxury travel magazine.

The aesthetic follows a **Corporate / Modern** style with subtle **Minimalist** influences. It prioritizes clarity and functional elegance, using generous whitespace and precise typography to reduce cognitive load during complex processes like visa applications or multi-leg flight bookings. The goal is a digital experience that feels as refined as a first-class lounge.

## Colors

This color palette is anchored in heritage and luxury. 
- **Primary Navy & Blue:** Used for headers, primary actions, and navigational anchors to establish authority and trust.
- **Accent Gold:** Reserved for high-value interactions, premium status indicators, and subtle highlights (e.g., active tab indicators or "Verified" badges).
- **Neutral Charcoal & Blue-Gray:** Used for secondary text and borders to maintain a sophisticated contrast without the harshness of pure black.
- **Background:** A soft off-white (#F5F6F8) is the default to provide a canvas that feels warmer and more "premium" than clinical white.

## Typography

The typography pairing combines the geometric confidence of **Montserrat** for headings with the contemporary clarity of **Hanken Grotesk** for body text. 

- **Headlines:** Should be set in Primary Navy. Use tight letter-spacing for larger displays to maintain a cohesive, "editorial" look.
- **Body Text:** Use Blue-Gray for secondary information and Dark Charcoal for primary reading. 
- **Labels:** Small labels and captions should often be set in uppercase with increased letter-spacing when using the Accent Gold or Blue-Gray to denote status or categories.

## Layout & Spacing

The design system utilizes a **12-column fluid grid** for desktop and a **4-column grid** for mobile. 

- **Layout Model:** Content is centered in a max-width container (1280px) on desktop.
- **Rhythm:** An 8px base unit governs all dimensions. Vertical spacing between logical sections (e.g., from "Visa Application" to "Flight Booking") should be generous (48px+) to maintain an airy, premium feel.
- **Safe Areas:** On mobile, a 20px horizontal margin is mandatory. 
- **Information Density:** Low density is preferred. Elements should have ample breathing room to avoid a "budget" or cluttered appearance.

## Elevation & Depth

Visual hierarchy is achieved through **Tonal Layers** and **Ambient Shadows**.

1.  **Surfaces:** The base layer is the Light Background. Content cards use pure White.
2.  **Shadows:** Use extremely soft, diffused shadows with a Navy tint (`rgba(36, 60, 128, 0.06)`) to lift cards off the background. Avoid heavy black shadows.
3.  **Depth Hierarchy:** 
    *   **Level 0:** Background.
    *   **Level 1:** Cards and interactive containers (minimal shadow).
    *   **Level 2:** Modals, dropdowns, and floating action buttons (medium shadow, 16px blur).
4.  **Dividers:** Use subtle 1px Blue-Gray borders (#E5E7EB) instead of shadows where a flatter look is required, such as within a list or form group.

## Shapes

The shape language is **Soft (0.25rem / 4px)**. This choice leans toward a professional, slightly more formal architectural feel compared to highly rounded consumer apps. 

- **Standard Radius:** 4px for buttons, input fields, and small UI components.
- **Large Radius (rounded-lg):** 8px for cards and containers.
- **Extra Large (rounded-xl):** 12px for major image containers (e.g., destination photography).
- **Exceptions:** Search bars in the hero section may use a pill-shape to draw focus, but this should be used sparingly.

## Components

### Buttons
- **Primary:** Solid Navy background with White text. 4px border radius.
- **Secondary:** Transparent background with Navy border or Gold text for "Premium" actions.
- **Ghost:** Blue-Gray text for low-priority actions (e.g., "Cancel", "Back").

### Input Fields
- Use a White background with a 1px Blue-Gray border. 
- Focus states should use a 2px Primary Blue border. 
- Labels should always be visible (never placeholder-only) for accessibility.

### Cards
- White fill, 8px radius, and a subtle Navy-tinted shadow.
- Imagery within cards should have a 0.05px inner stroke to ensure separation from the background.

### Steppers (Critical for Visa/Booking)
- Use a horizontal line with Gold-filled circles for completed steps and Navy for the active step. This guides the user through the multi-stage "Safiri" journey.

### Chips & Badges
- Used for "Flight Class" or "Visa Status."
- **Status - Pending:** Light Gold background with Dark Gold text.
- **Status - Approved:** Light Emerald background with Dark Green text.

### Navigation
- Top Bar: Sticky on scroll, White background with a subtle bottom shadow. The logo is centered or left-aligned depending on the platform.
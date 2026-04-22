---
name: design-smells
description: Full catalog of AI slop patterns in visual and UX design. Color, typography, layout, component, copy, and animation antipatterns.
---

# Design Slop Patterns

## Visual design

### The "AI startup" gradient
Purple/pink/blue mesh gradients are the single strongest signal of AI-generated design. If every section of your landing page has a gradient background, you have a problem.

Also overused:
- Holographic gradients on everything
- Gradient overlays on every image
- Gradients as the primary design element rather than accent

**Better**: Solid colors as foundation. Gradients sparingly for emphasis. Brand-specific palettes.

### Overused motifs
- Floating 3D geometric shapes (cubes, spheres, toruses)
- Glassmorphism everywhere
- Neumorphism (soft UI) on inappropriate elements
- Excessive blur effects
- Particle systems for decoration
- Tilt/perspective transforms on cards

**Detection signal**: If every section has floating 3D shapes or glass effects, it's slop.

### Stock photo aesthetic
Red flags:
- Generic diverse workplace photos
- People pointing at screens enthusiastically
- Business people shaking hands
- Overhead shots of MacBook + coffee "creative workspace"
- Excessive whitespace with minimal content

**Better**: Authentic, specific imagery that relates to actual content.

## Color and typography

### Generic palettes
- Purple (#7F5AF0) + Cyan (#2CB67D) + Pink (#FF6AC1) — the AI palette
- Entire palette of pastels
- Neon everything
- Pure black (#000) and pure white (#FFF) only

**Better**: 2-3 primary colors + neutrals. Built from brand or content needs. Consider accessibility (WCAG contrast ratios).

### Typography slop
Overused combos:
- Inter for everything
- Montserrat + Open Sans
- Poppins + Roboto

Problems:
- Same font family for headings and body
- Display fonts for body text
- Inconsistent weights and sizes
- 5+ different fonts on one page

**Better**: 2-3 font families max. Clear hierarchy (H1, H2, body, caption). Test readability at various sizes.

### Type hierarchy issues
- Every heading the same size
- Body text too small (<16px)
- Insufficient line height (<1.5 for body)
- Poor contrast ratios
- Centered text for long paragraphs (left-align body text)

## Layout

### The AI landing page template
```
1. Hero with gradient background + "Empower Your Business"
2. Three feature cards with icons
3. Stats section with big numbers
4. Testimonials
5. Pricing cards
6. FAQ section
7. CTA: "Get Started Today"
```

This layout could be for any product by any company. Design based on actual user journey and content needs.

### Spacing slop
- Everything spaced identically
- Excessive whitespace without purpose
- Cramped sections alternating with huge gaps
- No visual grouping (everything floating equally)

**Better**: Spacing creates hierarchy. Group related elements closer. Follow 4px or 8px grid.

### Card overuse
- Everything in a card
- Cards within cards within cards
- All cards same size regardless of content
- Cards with excessive shadows and borders

**Better**: Cards group related information. Vary style by importance. Consider alternatives: borders, background colors, whitespace.

### Center-alignment everywhere
All text centered, all elements centered, forced symmetry. This is lazy, not elegant.

**Better**: Left-align body text for readability. Center only when it serves a purpose. Consider asymmetric layouts.

## Components

### Button slop
- Every button fully rounded (pill shape)
- Buttons with huge shadows
- Gradient buttons everywhere
- Ghost buttons as primary CTAs
- Icons without text labels

**Better**: Style by hierarchy (primary, secondary, tertiary). Sufficient click targets (44x44px minimum). Clear, action-oriented labels.

### Icon slop
- Decorative icons that add no meaning
- Inconsistent icon styles (mixing outlined and filled)
- Icons from different icon sets
- Icons without labels in unclear contexts

### Form slop
- Every input has an icon inside it
- Placeholder text as the only label
- Floating labels that add no value
- No clear error states
- Generic validation messages ("Invalid input")

## UX writing

### Generic microcopy
Headlines:
- "Empower your business"
- "Take control of your future"
- "Transform your workflow"
- "Seamless experience"
- "Unlock your potential"

CTAs:
- "Get Started"
- "Learn More"
- "Sign Up Now"
- "Try It Free"

**Better**: Be specific. "Automate Invoice Processing" beats "Empower Your Business." "Try 50 invoices free" beats "Get Started."

### Empty states
- "No items found"
- "Nothing to see here"
- "Oops! Something went wrong"

**Better**: Explain why the state is empty. Provide next steps. Use appropriate tone.

## Animation and interaction

### Animation slop
- Everything fades in on scroll
- Parallax on every element
- Bouncing elements
- Rotating 3D objects for decoration
- All animations same duration and easing

**Better**: Animation directs attention. Keep subtle and purposeful. Respect prefers-reduced-motion. Duration <300ms for most interactions.

### Interaction slop
- Hover effects on everything
- Pointer cursor on non-clickable elements
- Inconsistent interactive vs non-interactive cues

## Platform-specific

### Web
- Dashboard templates with generic metrics
- Unnecessary infinite scroll
- Pop-ups and modals for everything
- Cookie consent banners that hide content

### Mobile
- Bottom navigation with 5+ items
- Hamburger menus hiding important navigation
- Ignoring platform conventions (iOS vs Android)
- Inconsistent gesture handling

### Presentations
- Every slide with same template
- Bullet point overload
- Tiny unreadable text
- Stock photos as backgrounds
- Excessive transitions

## The checklist

Your design might be slop if:
- [ ] It could be for any product by any company
- [ ] It looks like a Figma community template
- [ ] All visuals are decorative, none informative
- [ ] Copy is entirely buzzwords
- [ ] Design decisions can't be justified
- [ ] Layout doesn't adapt to actual content
- [ ] No clear visual hierarchy
- [ ] Every element gets the same visual treatment
- [ ] Design ignores brand and user context

## When patterns are NOT slop

- Gradient backgrounds: fine for marketing sites if on-brand
- Cards: appropriate for displaying distinct, comparable items
- Generic CTAs: "Get Started" is fine if that's what happens
- Animations: purposeful motion enhances UX
- Stock photos: sometimes you genuinely need generic imagery

The issue is *thoughtless application of patterns* without considering whether they serve users or your design goals.

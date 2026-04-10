---
name: creative-ui-design
description: Create distinctive, production-grade frontend interfaces that avoid generic "AI slop" aesthetics. Use bold typography, unique color schemes, and intentional motion.
license: MIT
---

# Creative UI Design - Anti AI-Slop

## Core Philosophy

**AVOID** the generic AI look:
- Inter, Roboto, Arial, system fonts
- Purple gradients on white backgrounds
- Cookie-cutter SaaS layouts
- Rounded corners on everything
- Emojis as visual icons
- Rounded white cards on light backgrounds

**MANDATE** distinctive design:
- Unique, characterful typography
- Context-specific color schemes
- Intentional motion and micro-interactions
- Unexpected spatial composition
- Production-grade, functional code

## Design Thinking Process

Before coding, COMMIT to a bold aesthetic direction:

1. **Purpose**: What problem does this interface solve? Who uses it?
2. **Tone**: Pick ONE extreme direction:
   - Brutally minimal (clinical, clean, intentional)
   - Retro-futuristic (nostalgia + high-tech glow)
   - Editorial magazine (high-end typography, dramatic whitespace)
   - Brutalist raw (honest, monumental, bold)
   - Industrial utilitarian (functional, structured, heavy)
   - Luxury refined (elegant, premium, sophisticated)
   - Playful toy-like (chunky, colorful, bouncy)
   - Organic natural (soft, warm, flowing)

*Commit to ONE direction and execute fully—no half measures.*

## Typography Guidelines

**NEVER use:**
- Inter, Roboto, Arial, system defaults
- Default font stacks

**ALWAYS use distinctive fonts:**
- Display fonts: Playfair Display, Space Grotesk, Syne, Clash Display, DM Serif Display
- Body fonts: Source Serif Pro, Libre Baskerville, Crimson Pro, Outfit

**Typography hierarchy:**
- Use dramatic size contrasts (huge headlines + small body)
- Tight letter-spacing on headlines, relaxed on body
- Custom line-heights per context

## Color & Theme

**NEVER use:**
- Purple on white gradients
- Tailwind defaults without customization
- Generic blue/indigo primary colors

**USE instead:**
- Context-specific palettes (industrial = dark + amber, luxury = black + gold)
- CSS variables for semantic colors
- Sharp accent colors against dominant backgrounds
- Atmospheric backgrounds (not flat colors)

## Motion & Animation

- Staggered reveals on page load
- Scroll-triggered animations
- Micro-interactions on hover/click
- Spring physics for natural movement
- CSS-first, JS only when necessary

## Visual Details

**Create depth with:**
- Gradient meshes
- Noise/grain textures
- Geometric patterns
- Layered transparencies
- Dramatic shadows (not soft defaults)
- Custom decorative borders

## Spatial Composition

- Asymmetry over grid predictability
- Overlapping elements
- Diagonal flows
- Grid-breaking elements
- Generous negative space

## Implementation Rules

1. **Always commit to ONE aesthetic direction** and apply it consistently
2. **Vary between projects** - no two designs should look the same
3. **Match complexity to vision** - maximalist designs need elaborate code
4. **Every design must feel authored**, not generated

## CMA Factoria Context

For this project, use:
- **Tone**: Industrial utilitarian with dark theme
- **Colors**: Dark backgrounds (#0f172a), sharp accent (#4f46e5), status colors
- **Typography**: JetBrains Mono for code, Outfit for UI
- **Motion**: Subtle, professional, not flashy

## CSS Patterns to Use

```css
/* Avoid */
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
border-radius: 8px;
font-family: 'Inter', sans-serif;

/* Use instead */
background: #0f172a;
border-radius: 0;
font-family: 'Outfit', 'JetBrains Mono', sans-serif;
```

---

*Remember: You are capable of extraordinary creative work. Don't default to safe patterns. Create designs that feel genuinely crafted for their context.*
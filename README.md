# movingbytes-cinematic

**Cinematic portfolio built inside a sandboxed OpenClaw VM**

High-performance portfolio frontend built with vanilla JavaScript, WebGL, and modern CSS. No frameworks, no bloat — just fast, responsive interfaces demonstrating the same performance principles applied to agent systems.

Constructed inside an isolated OpenClaw VM using agent-assisted tooling for rapid iteration with strict security boundaries.

---

## Tech Stack

**Core:** Vanilla JavaScript • WebGL • CSS3 • HTML5  
**Performance:** RequestAnimationFrame • Intersection Observer • CSS Containment • WebP  
**Build:** Zero dependencies • Static deployment • Edge-optimized  
**Tooling:** OpenClaw sandboxed environment

---

## Features

- **Cinematic transitions** — Smooth micro-interactions without framework overhead
- **Dark mode native** — Built dark-first
- **60fps rendering** — RAF + GPU-accelerated CSS
- **Progressive enhancement** — Works without JS, enhanced with it
- **Zero runtime dependencies** — No React, Vue, or hydration costs
- **Agent-built** — Assembled via OpenClaw sandboxed tooling

---

## Build Process

Constructed in an **OpenClaw VM sandbox** — isolated environment where agent tooling safely iterated on the codebase without host system risk.

Demonstrates the same isolation principles used in production agent systems: autonomous operation within strict boundaries, full observability, human oversight.

1. Scaffolded in isolated VM
2. Agent-assisted development with review gates
3. Performance profiling in sandbox
4. Static deployment (Vercel)

---

## Local Development

```bash
git clone https://github.com/jayjz/movingbytes-cinematic.git
cd movingbytes-cinematic
python -m http.server 8000
# Open http://localhost:8000
```

## Deployment

See [DEPLOY.md](./DEPLOY.md) for Vercel configuration.

**Live:** [movingbytes.dev](https://movingbytes.dev) (when deployed)

---

## Structure

```
├── index.html
├── css/style.css
├── js/main.js
├── assets/*.webp
└── vercel.json
```

---

## Performance

- **< 50KB** total bundle (no frameworks)
- **WebP images** — 60-80% smaller than JPEG/PNG
- **CSS containment** — Isolated rendering for smooth animations
- **Intersection Observer** — Lazy-loads content
- **RAF** — Consistent 60fps animations

---

<div align="center">

**Built by [jayjz](https://github.com/jayjz)** • [movingbytes.dev](https://movingbytes.dev)

Agent Systems Architect • Production systems that work

</div>

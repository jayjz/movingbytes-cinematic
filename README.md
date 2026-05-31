# movingbytes-cinematic

**Cinematic portfolio built inside a sandboxed OpenClaw VM**

High-performance portfolio frontend showcasing agent systems work through cinematic UI techniques. Built with vanilla JavaScript, WebGL, and modern CSS — no frameworks, no bloat, just fast, responsive interfaces that demonstrate the same performance principles applied to agent systems.

This site was architected and assembled inside an isolated OpenClaw VM, leveraging agent-assisted tooling for rapid iteration while maintaining strict security boundaries.

---

## Tech Stack

**Core:** Vanilla JavaScript • WebGL • CSS3 • HTML5  
**Performance:** RequestAnimationFrame • Intersection Observer • CSS Containment • WebP images  
**Build:** Zero-dependency • Static deployment • Edge-optimized assets  
**Tooling:** Built via OpenClaw sandboxed environment

---

## Features

- **Cinematic transitions** — Smooth page transitions and micro-interactions without framework overhead
- **Dark mode native** — Built dark-first with proper color science
- **High-performance rendering** — 60fps animations via RAF and GPU-accelerated CSS
- **Progressive enhancement** — Works without JavaScript, enhanced with it
- **Zero-runtime dependencies** — No React, no Vue, no hydration costs
- **Agent-built** — Assembled using OpenClaw's sandboxed agent tooling for rapid, safe iteration

---

## How It Was Built

This portfolio was constructed inside an **OpenClaw VM sandbox** — an isolated environment where agent tooling could safely read, write, and iterate on the codebase without risk to host systems.

**Why this matters:** Demonstrates the same isolation and safety principles applied to production agent systems. The build process itself validates the architecture: autonomous agents operating within strict boundaries, with full observability and human oversight.

**Process:**
1. Scaffolded in isolated VM with no network egress except to GitHub
2. Agent-assisted component development with human review gates
3. Performance profiling and optimization in sandbox
4. Deployed via static hosting (Vercel) with zero runtime dependencies

---

## Local Development

```bash
# Clone and serve locally
git clone https://github.com/jayjz/movingbytes-cinematic.git
cd movingbytes-cinematic

# Serve with any static server
python -m http.server 8000
# or
npx serve .

# Open http://localhost:8000
```

## Deployment

See [DEPLOY.md](./DEPLOY.md) for Vercel deployment instructions and configuration details.

**Live Site:** [movingbytes.dev](https://movingbytes.dev) (when deployed)

---

## Project Structure

```
├── index.html          # Main entry point
├── css/
│   └── style.css       # All styles (no frameworks)
├── js/
│   └── main.js         # Vanilla JS interactions
├── assets/             # Optimized WebP images
├── vercel.json         # Deployment config
└── DEPLOY.md          # Deployment guide
```

---

## Performance Notes

- **No frameworks** — Vanilla JS keeps bundle size < 50KB
- **WebP images** — 60-80% smaller than JPEG/PNG equivalents
- **CSS containment** — Isolates rendering for smooth animations
- **Intersection Observer** — Lazy-loads content as needed
- **RequestAnimationFrame** — Smooth 60fps animations

Built to demonstrate that high-performance interfaces don't require heavy frameworks — the same principle applied to building efficient agent systems.

---

<div align="center">

**Built by [jayjz](https://github.com/jayjz)** • Part of the [movingbytes.dev](https://movingbytes.dev) portfolio

Agent Systems Architect • Shipping production systems that work

</div>

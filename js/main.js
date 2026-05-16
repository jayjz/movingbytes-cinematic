/* movingbytes.dev v4 — Interactive Systems
 * Custom cursor, particles, typewriter, scroll effects, magnetic buttons
 * 60fps target, respects prefers-reduced-motion
 */

(() => {
    'use strict';

    const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    const isTouch = 'ontouchstart' in window || navigator.maxTouchPoints > 0;
    const isMobile = window.innerWidth < 768;

    // Performance monitoring
    let lastTime = performance.now();
    let frameCount = 0;
    let fps = 60;

    function updateFPS() {
        frameCount++;
        const now = performance.now();
        if (now - lastTime >= 1000) {
            fps = Math.round((frameCount * 1000) / (now - lastTime));
            frameCount = 0;
            lastTime = now;
            const fpsEl = document.getElementById('fps-counter');
            if (fpsEl) fpsEl.textContent = `${fps} fps`;
        }
        requestAnimationFrame(updateFPS);
    }
    updateFPS();

    // Load time
    window.addEventListener('load', () => {
        const loadTime = Math.round(performance.now());
        const el = document.getElementById('load-time');
        if (el) el.textContent = `${loadTime}ms`;
        const perfEl = document.getElementById('perf-metric');
        if (perfEl) perfEl.textContent = loadTime;
    });

    // Custom Cursor System
    if (!reducedMotion && !isTouch && !isMobile) {
        const cursor = document.querySelector('.cursor');
        const cursorDot = cursor?.querySelector('.cursor-dot');
        const cursorRing = cursor?.querySelector('.cursor-ring');
        const trailCanvas = document.createElement('canvas');
        const trailCtx = trailCanvas.getContext('2d');
        const trailContainer = document.querySelector('.cursor-trail');
        
        if (cursor && trailContainer) {
            trailContainer.appendChild(trailCanvas);
            
            let mouseX = 0, mouseY = 0;
            let ringX = 0, ringY = 0;
            let trailPoints = [];
            const maxTrailPoints = 12;

            function resizeTrail() {
                trailCanvas.width = window.innerWidth;
                trailCanvas.height = window.innerHeight;
            }
            resizeTrail();
            window.addEventListener('resize', resizeTrail);

            document.addEventListener('mousemove', (e) => {
                mouseX = e.clientX;
                mouseY = e.clientY;
                
                if (cursorDot) {
                    cursorDot.style.left = mouseX + 'px';
                    cursorDot.style.top = mouseY + 'px';
                }

                trailPoints.push({ x: mouseX, y: mouseY, life: 1 });
                if (trailPoints.length > maxTrailPoints) {
                    trailPoints.shift();
                }
            });

            function animateCursor() {
                // Smooth ring follow
                ringX += (mouseX - ringX) * 0.15;
                ringY += (mouseY - ringY) * 0.15;
                
                if (cursorRing) {
                    cursorRing.style.left = ringX + 'px';
                    cursorRing.style.top = ringY + 'px';
                }

                // Draw trail
                trailCtx.clearRect(0, 0, trailCanvas.width, trailCanvas.height);
                trailCtx.lineCap = 'round';
                trailCtx.lineJoin = 'round';

                for (let i = 0; i < trailPoints.length - 1; i++) {
                    const p1 = trailPoints[i];
                    const p2 = trailPoints[i + 1];
                    
                    p1.life *= 0.92;
                    if (p1.life < 0.01) continue;

                    trailCtx.beginPath();
                    trailCtx.moveTo(p1.x, p1.y);
                    trailCtx.lineTo(p2.x, p2.y);
                    trailCtx.strokeStyle = `rgba(0, 217, 255, ${p1.life * 0.15})`;
                    trailCtx.lineWidth = p1.life * 2;
                    trailCtx.stroke();
                }

                requestAnimationFrame(animateCursor);
            }
            animateCursor();

            // Hover states
            const hoverables = document.querySelectorAll('a, button, [data-magnetic], .project-card');
            hoverables.forEach(el => {
                el.addEventListener('mouseenter', () => cursor?.classList.add('hover'));
                el.addEventListener('mouseleave', () => cursor?.classList.remove('hover'));
            });
        }
    }

    // Magnetic buttons
    if (!reducedMotion && !isTouch) {
        const magnetics = document.querySelectorAll('[data-magnetic]');
        
        magnetics.forEach(elem => {
            let bound = elem.getBoundingClientRect();
            
            const updateBound = () => {
                bound = elem.getBoundingClientRect();
            };
            
            window.addEventListener('scroll', updateBound, { passive: true });
            window.addEventListener('resize', updateBound);
            
            elem.addEventListener('mousemove', (e) => {
                const x = e.clientX - bound.left - bound.width / 2;
                const y = e.clientY - bound.top - bound.height / 2;
                const distance = Math.sqrt(x * x + y * y);
                const maxDistance = Math.max(bound.width, bound.height);
                
                if (distance < maxDistance) {
                    const strength = 0.3;
                    elem.style.transform = `translate(${x * strength}px, ${y * strength}px)`;
                }
            });
            
            elem.addEventListener('mouseleave', () => {
                elem.style.transform = 'translate(0, 0)';
            });
        });
    }

    // Typewriter effect
    const typewriterEl = document.getElementById('typewriter');
    if (typewriterEl && !reducedMotion) {
        const phrases = [
            'Interfaces that breathe',
            'Code that disappears',
            '60fps or it didn\'t happen',
            'Building at 2:47 AM',
            'Zero frameworks, 100% intent'
        ];
        
        let phraseIndex = 0;
        let charIndex = 0;
        let isDeleting = false;
        let typeSpeed = 80;

        function type() {
            const current = phrases[phraseIndex];
            
            if (isDeleting) {
                typewriterEl.textContent = current.substring(0, charIndex - 1);
                charIndex--;
                typeSpeed = 40;
            } else {
                typewriterEl.textContent = current.substring(0, charIndex + 1);
                charIndex++;
                typeSpeed = 80;
            }

            if (!isDeleting && charIndex === current.length) {
                typeSpeed = 2000;
                isDeleting = true;
            } else if (isDeleting && charIndex === 0) {
                isDeleting = false;
                phraseIndex = (phraseIndex + 1) % phrases.length;
                typeSpeed = 500;
            }

            setTimeout(type, typeSpeed);
        }
        
        setTimeout(type, 1000);
    } else if (typewriterEl) {
        typewriterEl.textContent = 'Interfaces that breathe';
    }

    // Particle system - enhanced
    const canvas = document.getElementById('particles');
    if (canvas && !reducedMotion) {
        const ctx = canvas.getContext('2d', { alpha: true });
        let particles = [];
        let mouseX = -1000, mouseY = -1000;
        let scrollY = 0;

        function resize() {
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
            initParticles();
        }

        function initParticles() {
            particles = [];
            const count = Math.min(80, Math.floor((canvas.width * canvas.height) / 20000));
            
            for (let i = 0; i < count; i++) {
                particles.push({
                    x: Math.random() * canvas.width,
                    y: Math.random() * canvas.height,
                    vx: (Math.random() - 0.5) * 0.3,
                    vy: (Math.random() - 0.5) * 0.3,
                    size: Math.random() * 1.5 + 0.3,
                    opacity: Math.random() * 0.5 + 0.1,
                    hue: 185 + Math.random() * 20 // cyan range
                });
            }
        }

        function drawParticles() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            
            // Update scroll-based intensity
            const intensity = 1 + (scrollY * 0.0005);
            
            particles.forEach((p, i) => {
                // Mouse interaction
                const dx = mouseX - p.x;
                const dy = mouseY - p.y;
                const dist = Math.sqrt(dx * dx + dy * dy);
                
                if (dist < 120) {
                    const force = (120 - dist) / 120;
                    p.vx -= (dx / dist) * force * 0.02;
                    p.vy -= (dy / dist) * force * 0.02;
                    p.opacity = Math.min(0.8, p.opacity + force * 0.02);
                }

                // Update position
                p.x += p.vx * intensity;
                p.y += p.vy * intensity;
                
                // Damping
                p.vx *= 0.99;
                p.vy *= 0.99;
                p.opacity *= 0.995;
                if (p.opacity < 0.05) p.opacity = 0.05 + Math.random() * 0.1;

                // Wrap around
                if (p.x < -10) p.x = canvas.width + 10;
                if (p.x > canvas.width + 10) p.x = -10;
                if (p.y < -10) p.y = canvas.height + 10;
                if (p.y > canvas.height + 10) p.y = -10;

                // Draw particle
                ctx.beginPath();
                ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
                ctx.fillStyle = `hsla(${p.hue}, 100%, 70%, ${p.opacity})`;
                ctx.fill();

                // Draw connections
                particles.slice(i + 1).forEach(p2 => {
                    const dx2 = p.x - p2.x;
                    const dy2 = p.y - p2.y;
                    const dist2 = Math.sqrt(dx2 * dx2 + dy2 * dy2);
                    
                    if (dist2 < 100) {
                        ctx.beginPath();
                        ctx.moveTo(p.x, p.y);
                        ctx.lineTo(p2.x, p2.y);
                        const alpha = (1 - dist2 / 100) * 0.05 * intensity;
                        ctx.strokeStyle = `rgba(0, 217, 255, ${alpha})`;
                        ctx.lineWidth = 0.5;
                        ctx.stroke();
                    }
                });
            });

            requestAnimationFrame(drawParticles);
        }

        // Mouse tracking
        let mouseTimeout;
        document.addEventListener('mousemove', (e) => {
            mouseX = e.clientX;
            mouseY = e.clientY;
            clearTimeout(mouseTimeout);
            mouseTimeout = setTimeout(() => {
                mouseX = -1000;
                mouseY = -1000;
            }, 100);
        }, { passive: true });

        // Scroll tracking
        let ticking = false;
        window.addEventListener('scroll', () => {
            scrollY = window.scrollY;
            if (!ticking) {
                requestAnimationFrame(() => {
                    // Parallax layers
                    document.querySelectorAll('.parallax-layer').forEach((layer, i) => {
                        const speed = 0.1 + (i * 0.05);
                        layer.style.transform = `translateY(${scrollY * speed}px) translateZ(0)`;
                    });
                    
                    // Scanlines intensity
                    const scanlines = document.querySelector('.scanlines');
                    if (scanlines) {
                        if (scrollY > 100) {
                            scanlines.classList.add('intense');
                        } else {
                            scanlines.classList.remove('intense');
                        }
                    }
                    
                    ticking = false;
                });
                ticking = true;
            }
        }, { passive: true });

        resize();
        window.addEventListener('resize', resize, { passive: true });
        drawParticles();
    }

    // Scroll progress
    const progressBar = document.querySelector('.nav-progress-bar');
    if (progressBar) {
        window.addEventListener('scroll', () => {
            const winScroll = document.documentElement.scrollTop;
            const height = document.documentElement.scrollHeight - document.documentElement.clientHeight;
            const scrolled = (winScroll / height) * 100;
            progressBar.style.width = scrolled + '%';
        }, { passive: true });
    }

    // Intersection Observer for project cards
    const observerOptions = {
        threshold: 0.15,
        rootMargin: '0px 0px -10% 0px'
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('in-view');
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);

    document.querySelectorAll('.project-card').forEach(card => {
        observer.observe(card);
    });

    // Smooth scroll for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            const href = this.getAttribute('href');
            if (href === '#') return;
            
            const target = document.querySelector(href);
            if (target) {
                e.preventDefault();
                const navHeight = document.querySelector('.navbar')?.offsetHeight || 0;
                const targetPosition = target.getBoundingClientRect().top + window.pageYOffset - navHeight - 20;
                
                window.scrollTo({
                    top: targetPosition,
                    behavior: reducedMotion ? 'auto' : 'smooth'
                });
            }
        });
    });

    // Status text rotator
    const statusTexts = [
        'Building systems that disappear',
        'Optimizing the 16.67ms',
        'Rejecting frameworks since 2019',
        'Currently: Annotation OS v3',
        'Thinking in systems, not screens'
    ];
    
    const statusEl = document.getElementById('status-text');
    if (statusEl && !reducedMotion) {
        let statusIndex = 0;
        setInterval(() => {
            statusIndex = (statusIndex + 1) % statusTexts.length;
            statusEl.style.opacity = '0';
            setTimeout(() => {
                statusEl.textContent = statusTexts[statusIndex];
                statusEl.style.opacity = '1';
            }, 300);
        }, 4000);
    }

    // Keyboard navigation enhancement
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Tab') {
            document.body.classList.add('keyboard-nav');
        }
    });
    
    document.addEventListener('mousedown', () => {
        document.body.classList.remove('keyboard-nav');
    });

    // Performance: Pause animations when tab is hidden
    document.addEventListener('visibilitychange', () => {
        if (document.hidden) {
            document.body.style.animationPlayState = 'paused';
        } else {
            document.body.style.animationPlayState = 'running';
        }
    });

    // Easter egg: Konami code
    const konami = ['ArrowUp', 'ArrowUp', 'ArrowDown', 'ArrowDown', 'ArrowLeft', 'ArrowRight', 'ArrowLeft', 'ArrowRight', 'b', 'a'];
    let konamiIndex = 0;
    
    document.addEventListener('keydown', (e) => {
        if (e.key === konami[konamiIndex]) {
            konamiIndex++;
            if (konamiIndex === konami.length) {
                document.body.style.filter = 'hue-rotate(180deg) contrast(1.2)';
                setTimeout(() => {
                    document.body.style.filter = '';
                }, 3000);
                konamiIndex = 0;
            }
        } else {
            konamiIndex = 0;
        }
    });

    console.log('%c movingbytes.dev v4 ', 'background: #00d9ff; color: #000; font-weight: bold; padding: 4px 8px; border-radius: 2px;');
    console.log('%c 0 frameworks • 60fps target • Built at 2 AM ', 'color: #888; font-family: monospace;');
})();
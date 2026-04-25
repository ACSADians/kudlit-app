// Kudlit — Login / Welcome screen
// Phone-first, fits in a single viewport (no scroll), tweakable.

const K = {
  paper:    'hsl(226, 91%, 91%)',
  ink:      'hsl(224, 45%, 10%)',
  blue900:  'hsl(227, 92%, 95%)',
  blue500:  'hsl(225, 39%, 53%)',
  blue400:  'hsl(225, 36%, 39%)',
  blue300:  'hsl(226, 65%, 25%)',
  grey400:  'hsl(233, 21%, 85%)',
  grey300:  'hsla(230, 18%, 50%, 1)',
  grey200:  'hsl(231, 15%, 45%)',
  font:     "'Geist', ui-sans-serif, system-ui, sans-serif",
  bayb:     "'Baybayin Simple TAWBID', serif",
};

// ── Baybayin glyphs faded behind the hero ─────────────────────────────
function BaybayinBackdrop({ intensity = 1 }) {
  const glyphs = [
    { ch: 'ka',  top:  4, left:  -4, size: 140, rot: -8,  op: 0.08 },
    { ch: 'ba',  top: 30, left:  72, size: 100, rot: 12,  op: 0.07 },
    { ch: 'la',  top: 14, left:  52, size:  80, rot: -4,  op: 0.09 },
    { ch: 'na',  top: 48, left:  -6, size: 110, rot: 6,   op: 0.06 },
    { ch: 'ma',  top: 58, left:  82, size:  70, rot: -10, op: 0.07 },
    { ch: 'pa',  top: 70, left:  20, size:  90, rot: 8,   op: 0.05 },
  ];
  return (
    <div style={{
      position: 'absolute', inset: 0, overflow: 'hidden', pointerEvents: 'none',
    }}>
      {glyphs.map((g, i) => (
        <span key={i} style={{
          position: 'absolute', top: `${g.top}%`, left: `${g.left}%`,
          fontFamily: K.bayb, fontSize: g.size,
          color: '#fff', opacity: g.op * intensity,
          transform: `rotate(${g.rot}deg)`,
          lineHeight: 1, userSelect: 'none',
        }}>{g.ch}</span>
      ))}
    </div>
  );
}

function SpeechBubble({ children }) {
  return (
    <div style={{ position: 'relative', display: 'inline-block', maxWidth: 220 }}>
      <div style={{
        background: 'white', color: K.blue300,
        padding: '8px 12px', borderRadius: 14,
        fontSize: 13, fontWeight: 500, lineHeight: 1.3,
        boxShadow: '0 4px 10px rgba(0,0,0,0.18)', textAlign: 'center',
      }}>{children}</div>
      <div style={{
        position: 'absolute', bottom: -6, left: '50%',
        transform: 'translateX(-50%) rotate(45deg)',
        width: 12, height: 12, background: 'white',
        boxShadow: '3px 3px 5px rgba(0,0,0,0.06)',
      }} />
    </div>
  );
}

function PrimaryBtn({ icon, children }) {
  return (
    <div style={{
      background: K.blue300, color: K.blue900,
      padding: '12px 16px', borderRadius: 12,
      fontFamily: K.font, fontSize: 14.5, fontWeight: 600,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      gap: 10, cursor: 'pointer', userSelect: 'none',
      boxShadow: '0 4px 10px -2px rgba(14,20,37,0.25)',
    }}>
      {icon && <i data-lucide={icon} style={{ width: 18, height: 18, strokeWidth: 2 }}></i>}
      <span>{children}</span>
    </div>
  );
}

function SecondaryBtn({ icon, iconImg, children }) {
  return (
    <div style={{
      background: 'white', color: K.blue300,
      padding: '10px 14px', borderRadius: 12,
      fontFamily: K.font, fontSize: 13.5, fontWeight: 500,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      gap: 8, cursor: 'pointer', userSelect: 'none',
      border: `1.25px solid ${K.grey400}`,
    }}>
      {iconImg && <img src={iconImg} style={{ width: 16, height: 16 }} />}
      {icon && <i data-lucide={icon} style={{ width: 16, height: 16, strokeWidth: 1.75 }}></i>}
      <span>{children}</span>
    </div>
  );
}

function CheckRow({ checked, label }) {
  return (
    <div style={{
      display: 'inline-flex', alignItems: 'center', gap: 7,
      fontSize: 12, color: K.grey200, cursor: 'pointer', userSelect: 'none',
    }}>
      <div style={{
        width: 15, height: 15, borderRadius: 4,
        background: checked ? K.blue300 : 'white',
        border: `1.25px solid ${checked ? K.blue300 : K.grey400}`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        flexShrink: 0,
      }}>
        {checked && (
          <svg viewBox="0 0 16 16" width="11" height="11">
            <path d="M3 8.5 L7 12 L13 4.5" fill="none" stroke={K.blue900}
              strokeWidth="2.25" strokeLinecap="round" strokeLinejoin="round" />
          </svg>
        )}
      </div>
      <span>{label}</span>
    </div>
  );
}

// ── Main screen ────────────────────────────────────────────────────────
function LoginScreen({ t = {} }) {
  // Tweakable values with safe defaults
  const primary       = t.primaryMethod   || 'phone';   // 'phone' | 'email' | 'google'
  const colorScheme   = t.colorScheme     || 'dark';    // 'dark' | 'light'
  const buttyPose     = t.buttyPose       || 'wave';    // 'wave' | 'read' | 'bubble'
  const heroHeightPct = t.heroHeightPct  ?? 52;         // % of frame
  const showBubble    = t.showBubble     ?? true;
  const showGlyphs    = t.showGlyphs     ?? true;
  const buttySize     = t.buttySize      ?? 130;
  const headline      = t.headline      || 'Welcome, ka-Baybayin!';
  const subhead       = t.subhead       || 'Sign in to save your progress and earn badges.';
  const bubbleText    = t.bubbleText    || "Kumusta! I'm Butty. Let's learn Baybayin together!";

  const buttyImg = {
    wave:   'assets/ButtyWave.webp',
    read:   'assets/ButtyTextBubble.webp',
    bubble: 'assets/ButtyTextBubble.webp',
  }[buttyPose] || 'assets/ButtyWave.webp';

  const isLight = colorScheme === 'light';
  const heroBg = isLight ? K.blue500 : K.blue300;
  const heroTint = isLight
    ? 'linear-gradient(180deg, rgba(14,20,37,0.20) 0%, rgba(14,20,37,0.55) 60%, rgba(14,20,37,0.85) 100%)'
    : 'linear-gradient(180deg, rgba(14,20,37,0.55) 0%, rgba(14,20,37,0.75) 60%, rgba(14,20,37,0.95) 100%)';

  // Pick primary label + icon
  const primaryBtn = {
    phone:  { icon: 'smartphone', label: 'Continue with Phone Number' },
    email:  { icon: 'mail',       label: 'Continue with Email' },
    google: { icon: null,         label: 'Continue with Google',
              iconImg: 'assets/google.icon.webp' },
  }[primary];

  // Build the two secondary options (the two not chosen as primary)
  const allSecondary = {
    phone:  { icon: 'smartphone', label: 'Phone' },
    email:  { icon: 'mail',       label: 'Email' },
    google: { iconImg: 'assets/google.icon.webp', label: 'Google' },
  };
  const secondaryKeys = ['phone', 'email', 'google'].filter(k => k !== primary);

  return (
    <div style={{
      height: '100%', display: 'flex', flexDirection: 'column',
      fontFamily: K.font, position: 'relative', background: K.paper,
      overflow: 'hidden',
    }} data-screen-label="01 Login">

      {/* HERO */}
      <div style={{
        position: 'relative',
        background: heroBg,
        backgroundImage: `url('assets/bg.login.webp')`,
        backgroundSize: 'cover', backgroundPosition: 'center',
        height: `${heroHeightPct}%`,
        padding: '14px 20px 40px',
        display: 'flex', flexDirection: 'column',
        flexShrink: 0,
      }}>
        <div style={{ position: 'absolute', inset: 0, background: heroTint }} />

        {showGlyphs && <BaybayinBackdrop intensity={isLight ? 0.7 : 1} />}

        {/* Language toggle */}
        <div style={{
          position: 'relative', zIndex: 2,
          display: 'flex', alignItems: 'center', justifyContent: 'flex-end',
        }}>
          <div style={{
            display: 'inline-flex', alignItems: 'center', gap: 6,
            background: 'rgba(255,255,255,0.15)',
            backdropFilter: 'blur(4px)',
            border: '1px solid rgba(255,255,255,0.25)',
            padding: '4px 9px 4px 7px', borderRadius: 9999,
            cursor: 'pointer', userSelect: 'none',
          }}>
            <img src="assets/flag-ph.webp" style={{
              width: 16, height: 16, borderRadius: '50%', objectFit: 'cover',
            }} />
            <span style={{ color: 'white', fontSize: 11.5, fontWeight: 500 }}>EN</span>
            <i data-lucide="chevron-down" style={{ width: 11, height: 11, color: 'white' }}></i>
          </div>
        </div>

        {/* App icon + wordmark */}
        <div style={{
          position: 'relative', zIndex: 2,
          display: 'flex', flexDirection: 'column', alignItems: 'center',
          marginTop: 6, marginBottom: 4,
        }}>
          <img src="assets/AppIcon.webp" style={{
            width: 58, height: 58, borderRadius: 16,
            boxShadow: '0 4px 4px 0 rgba(0,0,0,0.25)',
          }} />
          <div style={{
            color: 'white', fontSize: 24, fontWeight: 700,
            letterSpacing: '-0.02em', marginTop: 8,
          }}>Kudlit</div>
          <div style={{
            color: 'rgba(255,255,255,0.82)', fontSize: 12,
            marginTop: 1, letterSpacing: '0.02em',
          }}>Baybayin, made simple.</div>
        </div>

        {/* Butty + speech bubble */}
        <div style={{
          position: 'relative', zIndex: 2,
          marginTop: 10, display: 'flex', flexDirection: 'column',
          alignItems: 'center', gap: 2, flex: 1, justifyContent: 'flex-end',
        }}>
          {showBubble && <SpeechBubble>{bubbleText}</SpeechBubble>}
          <img src={buttyImg} style={{
            width: buttySize, height: buttySize, objectFit: 'contain',
            marginTop: -2,
          }} />
        </div>
      </div>

      {/* BOTTOM SHEET */}
      <div style={{
        background: K.paper,
        borderTopLeftRadius: 22, borderTopRightRadius: 22,
        marginTop: -22,
        padding: '14px 20px 10px',
        position: 'relative',
        boxShadow: '0 -8px 24px -8px rgba(14,20,37,0.15)',
        display: 'flex', flexDirection: 'column',
        flex: 1, minHeight: 0,
      }}>
        <div style={{
          width: 40, height: 4, borderRadius: 2,
          background: K.grey400, margin: '0 auto 10px',
        }} />

        <div style={{ textAlign: 'center', marginBottom: 12 }}>
          <h1 style={{
            margin: 0, fontSize: 18, fontWeight: 700, color: K.blue300,
            letterSpacing: '-0.015em',
          }}>{headline}</h1>
          <p style={{
            margin: '2px 0 0', fontSize: 12, color: K.grey200, lineHeight: 1.35,
          }}>{subhead}</p>
        </div>

        <PrimaryBtn icon={primaryBtn.icon}>
          {primaryBtn.iconImg && (
            <img src={primaryBtn.iconImg} style={{ width: 18, height: 18, marginRight: -4 }} />
          )}
          {primaryBtn.label}
        </PrimaryBtn>

        <div style={{
          display: 'flex', alignItems: 'center', gap: 10,
          margin: '10px 0', color: K.grey300, fontSize: 10.5, fontWeight: 500,
          letterSpacing: '0.08em', textTransform: 'uppercase',
        }}>
          <div style={{ flex: 1, height: 1, background: K.grey400 }} />
          <span>or</span>
          <div style={{ flex: 1, height: 1, background: K.grey400 }} />
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
          {secondaryKeys.map(k => (
            <SecondaryBtn key={k}
              icon={allSecondary[k].icon}
              iconImg={allSecondary[k].iconImg}>
              {allSecondary[k].label}
            </SecondaryBtn>
          ))}
        </div>

        <div style={{
          display: 'flex', justifyContent: 'space-between', alignItems: 'center',
          marginTop: 10,
        }}>
          <CheckRow checked={true} label="Remember me" />
          <span style={{
            fontSize: 11.5, color: K.blue400, fontWeight: 500, cursor: 'pointer',
          }}>Forgot password?</span>
        </div>

        <div style={{
          textAlign: 'center', marginTop: 10, fontSize: 12.5, color: K.grey200,
        }}>
          New here?{' '}
          <span style={{
            color: K.blue300, fontWeight: 600, cursor: 'pointer',
            textDecoration: 'underline', textUnderlineOffset: 3,
          }}>Create an account</span>
        </div>

        <div style={{
          textAlign: 'center', marginTop: 4, fontSize: 11.5,
          color: K.grey300, cursor: 'pointer',
        }}>
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
            Continue as guest
            <i data-lucide="arrow-right" style={{ width: 11, height: 11 }}></i>
          </span>
        </div>

        <div style={{ flex: 1, minHeight: 2 }} />

        <div style={{
          textAlign: 'center', fontSize: 10, color: K.grey300,
          lineHeight: 1.45, marginTop: 6,
        }}>
          By continuing you agree to our{' '}
          <span style={{ color: K.blue400, fontWeight: 500 }}>Terms</span>
          {' '}and{' '}
          <span style={{ color: K.blue400, fontWeight: 500 }}>Privacy Policy</span>.
        </div>
        <div style={{
          textAlign: 'center', fontSize: 9.5, color: K.grey300,
          marginTop: 2, fontFamily: "'Geist Mono', monospace",
          opacity: 0.7,
        }}>v1.0.0 · build 204</div>
      </div>
    </div>
  );
}

Object.assign(window, { LoginScreen });

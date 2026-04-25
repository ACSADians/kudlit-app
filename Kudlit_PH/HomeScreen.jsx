// Kudlit — Home / Dashboard screen
// A clean tool-focused home: Scanner, Transliterator, Lessons guide.
// No gamification. Non-technical audience — warm, simple, clear.

const HK = {
  paper:   'hsl(226, 91%, 91%)',
  ink:     'hsl(224, 45%, 10%)',
  blue900: 'hsl(227, 92%, 95%)',
  blue800: 'hsl(224, 100%, 85%)',
  blue500: 'hsl(225, 39%, 53%)',
  blue400: 'hsl(225, 36%, 39%)',
  blue300: 'hsl(226, 65%, 25%)',
  grey500: 'hsl(225, 25%, 94%)',
  grey400: 'hsl(233, 21%, 85%)',
  grey300: 'hsla(230, 18%, 50%, 1)',
  grey200: 'hsl(231, 15%, 45%)',
  tan200:  'hsl(27, 100%, 86%)',
  tan300:  'hsl(27, 88%, 78%)',
  font:    "'Geist', ui-sans-serif, system-ui, sans-serif",
  bayb:    "'Baybayin Simple TAWBID', serif",
  r: { sm: 4, md: 8, lg: 10, xl: 14, xxl: 16, full: 9999 },
  shadowCard: '0 4px 4px 0 rgba(0,0,0,0.25)',
  shadowSm:   '0 1px 2px 0 rgba(14,20,37,0.06)',
  shadowMd:   '0 4px 8px -2px rgba(14,20,37,0.10)',
};

// ── Top bar ────────────────────────────────────────────────────────────
function Topbar({ isGuest }) {
  return (
    <div style={{
      height: 56, background: HK.blue500,
      borderBottom: `1.25px solid ${HK.blue400}`,
      boxShadow: HK.shadowMd,
      display: 'flex', alignItems: 'center', padding: '0 14px',
      flexShrink: 0, fontFamily: HK.font, position: 'relative',
    }}>
      <div style={{
        width: 32, height: 32, borderRadius: 8,
        background: HK.paper, color: HK.blue300,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        border: `1.25px solid ${HK.blue400}`, cursor: 'pointer',
      }}>
        <i data-lucide="menu" style={{ width: 18, height: 18 }}></i>
      </div>

      {/* Center app icon */}
      <div style={{
        position: 'absolute', left: '50%', transform: 'translateX(-50%)',
        width: 36, height: 36, borderRadius: 10, overflow: 'hidden',
        boxShadow: HK.shadowCard,
      }}>
        <img src="assets/AppIcon.webp"
          style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
      </div>

      <div style={{ flex: 1 }} />

      {/* Right: sign in or avatar */}
      {isGuest ? (
        <div style={{
          background: HK.paper, color: HK.blue300,
          padding: '5px 11px', borderRadius: HK.r.full,
          fontSize: 11.5, fontWeight: 600, cursor: 'pointer',
          border: `1.25px solid ${HK.blue400}`,
          display: 'flex', alignItems: 'center', gap: 5,
        }}>
          <i data-lucide="log-in" style={{ width: 13, height: 13 }}></i>
          Sign In
        </div>
      ) : (
        <div style={{
          width: 34, height: 34, borderRadius: '50%', overflow: 'hidden',
          border: `2px solid ${HK.blue800}`, cursor: 'pointer', flexShrink: 0,
        }}>
          <img src="assets/profpic.placeholder.webp"
            style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
        </div>
      )}
    </div>
  );
}

// ── Welcome hero card ──────────────────────────────────────────────────
function WelcomeBanner({ isGuest, userName }) {
  return (
    <div style={{
      margin: '14px 14px 0',
      background: `linear-gradient(130deg, ${HK.blue300} 0%, ${HK.blue400} 100%)`,
      borderRadius: 16, boxShadow: HK.shadowCard,
      padding: '16px 16px 14px',
      position: 'relative', overflow: 'hidden',
      color: HK.blue900, fontFamily: HK.font,
    }}>
      {/* Baybayin watermark */}
      <span style={{
        position: 'absolute', right: -8, bottom: -22,
        fontFamily: HK.bayb, fontSize: 110,
        color: 'rgba(255,255,255,0.07)', lineHeight: 1,
        userSelect: 'none', pointerEvents: 'none',
      }}>ka</span>

      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
        <div style={{ flex: 1 }}>
          <div style={{
            fontSize: 10.5, fontWeight: 600, opacity: 0.8,
            letterSpacing: '0.06em', textTransform: 'uppercase', marginBottom: 3,
          }}>
            {isGuest ? 'Browsing as Guest' : 'Mabuhay 👋'}
          </div>
          <div style={{
            fontSize: 19, fontWeight: 700, lineHeight: 1.2,
            letterSpacing: '-0.015em',
          }}>
            {isGuest ? 'Kumusta, Bisita!' : `Kumusta, ${userName}!`}
          </div>
          <div style={{
            fontSize: 12.5, opacity: 0.88, lineHeight: 1.4, marginTop: 5,
          }}>
            {isGuest
              ? 'Explore the app. Sign in to unlock saving your work.'
              : 'What would you like to do today?'}
          </div>

          {isGuest && (
            <div style={{
              display: 'inline-flex', alignItems: 'center', gap: 6,
              background: 'rgba(255,255,255,0.2)',
              borderRadius: HK.r.full, padding: '6px 14px', marginTop: 10,
              fontSize: 12, fontWeight: 600, cursor: 'pointer',
            }}>
              Create Free Account
              <i data-lucide="arrow-right" style={{ width: 13, height: 13 }}></i>
            </div>
          )}
        </div>

        <img src={isGuest ? 'assets/ButtyWave.webp' : 'assets/butty.thumbsup.webp'}
          style={{ width: 78, height: 78, objectFit: 'contain', flexShrink: 0 }} />
      </div>
    </div>
  );
}

// ── Section header ─────────────────────────────────────────────────────
function SectionHeader({ title, action }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'baseline', justifyContent: 'space-between',
      padding: '18px 14px 8px', fontFamily: HK.font,
    }}>
      <h2 style={{
        margin: 0, fontSize: 15, fontWeight: 700,
        color: HK.blue300, letterSpacing: '-0.01em',
      }}>{title}</h2>
      {action && (
        <span style={{ fontSize: 12, color: HK.blue400, fontWeight: 500, cursor: 'pointer' }}>
          {action} ›
        </span>
      )}
    </div>
  );
}

// ── Tool cards (Scanner + Transliterator) — large, prominent ──────────
function ToolCard({ icon, title, description, accent, onClick }) {
  return (
    <div onClick={onClick} style={{
      flex: 1, background: HK.paper,
      borderRadius: 14, padding: '16px 14px',
      border: `1.25px solid ${HK.grey400}`,
      boxShadow: HK.shadowMd, cursor: 'pointer',
      display: 'flex', flexDirection: 'column', gap: 10,
      fontFamily: HK.font,
      transition: 'box-shadow 200ms',
    }}>
      <div style={{
        width: 46, height: 46, borderRadius: 13,
        background: accent, color: HK.blue900,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        boxShadow: HK.shadowSm, flexShrink: 0,
      }}>
        <i data-lucide={icon} style={{ width: 24, height: 24, strokeWidth: 1.75 }}></i>
      </div>
      <div>
        <div style={{ fontSize: 14, fontWeight: 700, color: HK.blue300, marginBottom: 3 }}>{title}</div>
        <div style={{ fontSize: 11.5, color: HK.grey300, lineHeight: 1.4 }}>{description}</div>
      </div>
      <div style={{
        display: 'inline-flex', alignItems: 'center', gap: 5,
        fontSize: 12, fontWeight: 600, color: HK.blue400,
        marginTop: 'auto',
      }}>
        Open <i data-lucide="arrow-right" style={{ width: 13, height: 13 }}></i>
      </div>
    </div>
  );
}

// ── Lesson card ────────────────────────────────────────────────────────
function LessonCard({ title, description, image, tag, onClick }) {
  return (
    <div onClick={onClick} style={{
      background: HK.paper, borderRadius: HK.r.lg,
      border: `1px solid ${HK.grey400}`, boxShadow: HK.shadowSm,
      overflow: 'hidden', display: 'flex', flexDirection: 'column',
      fontFamily: HK.font, cursor: 'pointer',
    }}>
      <div style={{
        height: 88, background: HK.blue900,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        position: 'relative',
      }}>
        <img src={image} alt="" style={{ maxHeight: 68, maxWidth: '78%', objectFit: 'contain' }} />
        {tag && (
          <div style={{
            position: 'absolute', top: 6, left: 6,
            background: HK.blue500, color: 'white',
            fontSize: 9.5, fontWeight: 700, padding: '2px 7px',
            borderRadius: HK.r.full, letterSpacing: '0.04em',
          }}>{tag}</div>
        )}
      </div>
      <div style={{ padding: '10px 11px 12px' }}>
        <div style={{ fontSize: 13, fontWeight: 700, color: HK.blue300, marginBottom: 3 }}>{title}</div>
        <div style={{ fontSize: 11, color: HK.grey300, lineHeight: 1.35 }}>{description}</div>
      </div>
    </div>
  );
}

// ── Bottom nav ─────────────────────────────────────────────────────────
function BottomNav({ active, onTab }) {
  const tabs = [
    { id: 'home',  icon: 'home',           label: 'Home'    },
    { id: 'scan',  icon: 'scan-text',      label: 'Scan'    },
    { id: 'learn', icon: 'book-open-text', label: 'Learn'   },
    { id: 'me',    icon: 'user',           label: 'Profile' },
  ];
  return (
    <div style={{
      height: 62, background: HK.paper,
      borderTop: `1px solid ${HK.grey400}`,
      display: 'flex', alignItems: 'center',
      fontFamily: HK.font, flexShrink: 0,
    }}>
      {tabs.map(t => {
        const on = active === t.id;
        return (
          <div key={t.id} onClick={() => onTab && onTab(t.id)} style={{
            flex: 1, display: 'flex', flexDirection: 'column',
            alignItems: 'center', gap: 2, cursor: 'pointer',
            color: on ? HK.blue300 : HK.grey300, paddingTop: 6,
          }}>
            <i data-lucide={t.icon} style={{ width: 22, height: 22, strokeWidth: on ? 2.25 : 1.5 }}></i>
            <span style={{ fontSize: 10.5, fontWeight: on ? 700 : 400 }}>{t.label}</span>
            <div style={{
              width: 18, height: 3, borderRadius: 99,
              background: on ? HK.blue300 : 'transparent',
              marginTop: 1,
            }} />
          </div>
        );
      })}
    </div>
  );
}

// ── Main ───────────────────────────────────────────────────────────────
function HomeScreen({ t = {} }) {
  const isGuest  = t.isGuest  ?? false;
  const userName = t.userName || 'Juan';
  const activeTab = t.activeTab || 'home';

  const lessons = [
    { id: 'vowels',     title: 'Vowels',      tag: 'Start Here', description: 'The three foundational Baybayin vowels: A, E/I, O/U.', image: 'assets/baybayin.vowels.webp' },
    { id: 'consonants', title: 'Consonants',  tag: null,          description: '14 base consonants with a default "a" vowel sound.',   image: 'assets/baybayin.consonant.webp' },
    { id: 'kudlit',     title: 'Kudlit Marks', tag: null,         description: 'Small diacritical marks that change vowel sounds.',     image: 'assets/baybayin.kudlit.webp' },
    { id: 'soon',       title: 'Coming Soon', tag: 'Soon',        description: 'More lessons on Baybayin writing are on the way.',     image: 'assets/baybayin.comingsoon.webp' },
  ];

  return (
    <div style={{
      height: '100%', display: 'flex', flexDirection: 'column',
      fontFamily: HK.font,
      background: HK.blue900,
      backgroundImage: `url('assets/BaybayInscribe-BackgroundImage.webp')`,
      backgroundSize: 'cover', backgroundPosition: 'center',
      backgroundBlendMode: 'luminosity',
    }} data-screen-label="02 Home">

      <Topbar isGuest={isGuest} />

      <div style={{ flex: 1, overflowY: 'auto', overflowX: 'hidden' }}>

        {/* Welcome */}
        <WelcomeBanner isGuest={isGuest} userName={userName} />

        {/* Tools — Scanner + Transliterator */}
        <SectionHeader title="Tools" />
        <div style={{ display: 'flex', gap: 10, padding: '0 14px' }}>
          <ToolCard
            icon="scan-text"
            title="Baybayin Scanner"
            description="Point your camera at Baybayin script and get an instant reading."
            accent={HK.blue300}
          />
          <ToolCard
            icon="languages"
            title="Transliterator"
            description="Type in Latin script and see it converted to Baybayin — and back."
            accent={HK.blue500}
          />
        </div>

        {/* Lessons */}
        <SectionHeader title="Guide to Baybayin" action="See all" />
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, padding: '0 14px' }}>
          {lessons.map(l => (
            <LessonCard key={l.id} {...l} />
          ))}
        </div>

        <div style={{ height: 20 }} />
      </div>

      <BottomNav active={activeTab} />
    </div>
  );
}

Object.assign(window, { HomeScreen });

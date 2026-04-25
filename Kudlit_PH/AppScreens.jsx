// Kudlit — All screens
// Nav: Scan (landing) → Translate → Learn
// Shared by both iOS and Android renders.

const C = {
  paper:   'hsl(226, 91%, 91%)',
  blue900: 'hsl(227, 92%, 95%)',
  blue800: 'hsl(224, 100%, 85%)',
  blue500: 'hsl(225, 39%, 53%)',
  blue400: 'hsl(225, 36%, 39%)',
  blue300: 'hsl(226, 65%, 25%)',
  blue200: 'hsl(225, 65%, 20%)',
  grey500: 'hsl(225, 25%, 94%)',
  grey400: 'hsl(233, 21%, 85%)',
  grey300: 'hsla(230, 18%, 50%, 1)',
  grey200: 'hsl(231, 15%, 45%)',
  ink:     'hsl(224, 45%, 10%)',
  tan:     'hsl(27, 88%, 90%)',
  font:    "'Geist', ui-sans-serif, system-ui, sans-serif",
  bayb:    "'Baybayin Simple TAWBID', serif",
};

// ── YOLO real-time detection overlay ──────────────────────────────────
// Simulates bounding boxes drawn around detected Baybayin characters.
// In production these come from YOLOv12s running on-device.
const YOLO_DETECTIONS = [
  { label: 'baybayin', conf: 0.96, top: '22%', left: '8%',  w: 180, h: 58 },
  { label: 'baybayin', conf: 0.89, top: '42%', left: '20%', w: 220, h: 62 },
  { label: 'baybayin', conf: 0.83, top: '62%', left: '12%', w: 150, h: 54 },
];

function YOLOOverlay() {
  return (
    <div style={{ position: 'absolute', inset: 0, pointerEvents: 'none', zIndex: 3 }}>
      {YOLO_DETECTIONS.map((d, i) => (
        <div key={i} style={{
          position: 'absolute',
          top: d.top, left: d.left,
          width: d.w, height: d.h,
        }}>
          {/* bounding box */}
          <div style={{
            position: 'absolute', inset: 0,
            border: '1.5px solid rgba(100,210,255,0.85)',
            borderRadius: 3,
            boxShadow: '0 0 6px rgba(100,210,255,0.3)',
          }} />
          {/* label chip */}
          <div style={{
            position: 'absolute', top: -20, left: 0,
            background: 'rgba(100,210,255,0.9)',
            color: '#050a14',
            fontSize: 10, fontWeight: 700,
            padding: '1px 6px', borderRadius: 3,
            letterSpacing: '0.03em',
            whiteSpace: 'nowrap',
            fontFamily: C.font,
          }}>{d.label} {Math.round(d.conf * 100)}%</div>
        </div>
      ))}
    </div>
  );
}

// ── SCAN RESULT PANEL ─────────────────────────────────────────────────
function ScanResultPanel({ onDismiss }) {
  return (
    <div style={{
      position: 'absolute', bottom: 110, left: 14, right: 14, zIndex: 10,
      background: 'rgba(12, 15, 28, 0.82)',
      backdropFilter: 'blur(20px)',
      WebkitBackdropFilter: 'blur(20px)',
      border: '1px solid rgba(255,255,255,0.08)',
      borderRadius: 16,
      padding: '12px 14px',
      boxShadow: '0 4px 24px rgba(0,0,0,0.35)',
      animation: 'result-slide-up 0.3s cubic-bezier(.16,1,.3,1) both',
      display: 'flex', flexDirection: 'column', gap: 6,
      fontFamily: C.font,
    }}>
      {/* swipe-down hint */}
      <div style={{ display: 'flex', justifyContent: 'center', marginBottom: 2 }}>
        <div style={{
          width: 28, height: 3, borderRadius: 99,
          background: 'rgba(255,255,255,0.2)',
        }} />
      </div>

      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
      {/* Text block */}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{
          fontFamily: C.bayb, fontSize: 28,
          color: 'white', letterSpacing: 6, lineHeight: 1.1,
          marginBottom: 2,
        }}>mhal kita</div>
        <div style={{
          fontSize: 15, fontWeight: 600,
          color: 'rgba(255,255,255,0.85)', letterSpacing: '-0.01em',
        }}>Mahal kita</div>
      </div>

      {/* Actions */}
      <div style={{ display: 'flex', gap: 6, flexShrink: 0 }}>
        {[
          { icon: 'copy',     title: 'Copy'      },
          { icon: 'share-2',  title: 'Share'     },
        ].map(b => (
          <div key={b.icon} title={b.title} style={{
            width: 34, height: 34, borderRadius: 10, cursor: 'pointer',
            background: 'rgba(255,255,255,0.08)',
            border: '1px solid rgba(255,255,255,0.1)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <i data-lucide={b.icon} style={{ width: 15, height: 15, color: 'rgba(255,255,255,0.7)' }}></i>
          </div>
        ))}
        <div onClick={onDismiss} style={{
          width: 34, height: 34, borderRadius: 10, cursor: 'pointer',
          background: 'rgba(255,255,255,0.06)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <i data-lucide="x" style={{ width: 15, height: 15, color: 'rgba(255,255,255,0.45)' }}></i>
        </div>
      </div>
      </div>
    </div>
  );
}

// ── SCAN SCREEN ────────────────────────────────────────────────────────
function ScanScreen({ platform }) {
  const isIOS = platform === 'ios';
  const [scanned, setScanned] = React.useState(false);

  // Re-run lucide after state change
  React.useEffect(() => {
    if (window.lucide) setTimeout(() => window.lucide.createIcons(), 30);
  }, [scanned]);

  return (
    <div style={{
      flex: 1, display: 'flex', flexDirection: 'column',
      background: '#0a0c14', position: 'relative', overflow: 'hidden',
      fontFamily: C.font,
    }} data-screen-label="01 Scanner">

      {/* Simulated camera feed */}
      <div style={{
        position: 'absolute', inset: 0,
        background: 'linear-gradient(160deg, #0f1520 0%, #080c18 60%, #0c1020 100%)',
      }} />

      {/* Subtle grain */}
      <svg style={{ position: 'absolute', inset: 0, opacity: 0.04, pointerEvents: 'none' }} width="100%" height="100%">
        <filter id="noise2">
          <feTurbulence type="fractalNoise" baseFrequency="0.9" numOctaves="4" stitchTiles="stitch"/>
          <feColorMatrix type="saturate" values="0"/>
        </filter>
        <rect width="100%" height="100%" filter="url(#noise2)" />
      </svg>

      {/* Top — subtle scanning indicator only */}
      <div style={{
        position: 'relative', zIndex: 2,
        paddingTop: isIOS ? 6 : 8,
        display: 'flex', justifyContent: 'center',
      }}>
        <div style={{
          display: 'inline-flex', alignItems: 'center', gap: 6,
          background: 'rgba(255,255,255,0.08)',
          border: '1px solid rgba(255,255,255,0.1)',
          borderRadius: 999, padding: '4px 12px',
        }}>
          {/* pulsing dot */}
          <div style={{
            width: 6, height: 6, borderRadius: '50%',
            background: 'rgba(100,210,255,0.9)',
            boxShadow: '0 0 6px rgba(100,210,255,0.7)',
            animation: 'pulse-dot 1.8s ease-in-out infinite',
          }} />
          <span style={{
            fontSize: 11, color: 'rgba(255,255,255,0.55)',
            fontFamily: C.font, letterSpacing: '0.04em',
          }}>Scanning…</span>
        </div>
      </div>

      {/* Viewfinder */}
      {/* Viewfinder — YOLO boxes live here */}
      <div style={{
        flex: 1, position: 'relative', zIndex: 2,
      }}>
        {<YOLOOverlay />}
      </div>

      {/* Bottom controls — no background, fully transparent */}
      <div style={{
        position: 'relative', zIndex: 2,
        padding: isIOS ? '16px 36px 20px' : '14px 36px 18px',
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      }}>
        {/* Gallery + Flash grouped on the left */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 18 }}>
          <div style={{ cursor: 'pointer', opacity: 0.7 }}>
            <i data-lucide="image" style={{ width: 26, height: 26, color: 'white', strokeWidth: 1.5 }}></i>
          </div>
          <div style={{ cursor: 'pointer', opacity: 0.7 }}>
            <i data-lucide="zap-off" style={{ width: 26, height: 26, color: 'white', strokeWidth: 1.5 }}></i>
          </div>
        </div>

        {/* Shutter — center */}
        <div onClick={() => setScanned(s => !s)} style={{ cursor: 'pointer' }}>
          <div style={{
            width: 68, height: 68, borderRadius: '50%',
            border: `2px solid ${scanned ? 'rgba(100,220,150,0.7)' : 'rgba(255,255,255,0.55)'}`,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            transition: 'border-color 300ms',
          }}>
            <div style={{
              width: 54, height: 54, borderRadius: '50%',
              background: scanned ? 'hsl(150, 55%, 55%)' : 'white',
              boxShadow: scanned
                ? '0 0 18px rgba(80,200,120,0.45)'
                : '0 0 18px rgba(120,170,255,0.3)',
              transition: 'background 300ms, box-shadow 300ms',
            }} />
          </div>
        </div>

        {/* Right spacer — keeps shutter centered */}
        <div style={{ width: 70 }} />
      </div>

      {/* Result panel — slides up when scanned */}
      {scanned && (
        <ScanResultPanel onDismiss={() => setScanned(false)} />
      )}
    </div>
  );
}

// ── TRANSLATE SCREEN — redesigned ────────────────────────────────────
// Layout: Baybayin as hero (top stage), minimal input strip at bottom.
// Voice input prominent. Direction toggle as subtle pill.
function TranslateScreen({ platform }) {
  const isIOS = platform === 'ios';
  const [listening, setListening] = React.useState(false);
  const [hasInput, setHasInput] = React.useState(true);
  const [direction, setDirection] = React.useState('lat-bay'); // 'lat-bay' | 'bay-lat'

  const sampleLatin = 'Mahal kita';
  const sampleBayb  = 'mhal kita';
  const syllables   = 'ma · hal · ki · ta';

  // Pulse animation for mic
  React.useEffect(() => {
    if (window.lucide) setTimeout(() => window.lucide.createIcons(), 30);
  }, [listening, hasInput]);

  return (
    <div style={{
      flex: 1, display: 'flex', flexDirection: 'column',
      fontFamily: C.font, background: '#0e1220', overflow: 'hidden',
    }} data-screen-label="02 Translate">

      {/* Direction toggle — subtle pill at very top */}
      <div style={{
        display: 'flex', justifyContent: 'center',
        paddingTop: isIOS ? 10 : 12, paddingBottom: 6,
        flexShrink: 0,
      }}>
        <div style={{
          display: 'inline-flex', alignItems: 'center',
          background: 'rgba(255,255,255,0.07)',
          border: '1px solid rgba(255,255,255,0.1)',
          borderRadius: 999, padding: 3, gap: 2,
        }}>
          {[
            { id: 'lat-bay', label: 'Latin → Baybayin' },
            { id: 'bay-lat', label: 'Baybayin → Latin' },
          ].map(d => (
            <div key={d.id} onClick={() => setDirection(d.id)} style={{
              padding: '5px 14px', borderRadius: 999,
              background: direction === d.id ? 'rgba(255,255,255,0.14)' : 'transparent',
              color: direction === d.id ? 'white' : 'rgba(255,255,255,0.38)',
              fontSize: 11.5, fontWeight: direction === d.id ? 600 : 400,
              cursor: 'pointer', transition: 'all 250ms',
              whiteSpace: 'nowrap',
            }}>{d.label}</div>
          ))}
        </div>
      </div>

      {/* STAGE — Baybayin hero display */}
      <div style={{
        flex: 1, display: 'flex', flexDirection: 'column',
        alignItems: 'center', justifyContent: 'center',
        padding: '20px 28px', position: 'relative', overflow: 'hidden',
      }}>
        {/* Background glyph watermark */}
        <div style={{
          position: 'absolute', inset: 0,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          pointerEvents: 'none', userSelect: 'none',
        }}>
          <span style={{
            fontFamily: C.bayb, fontSize: 220,
            color: 'rgba(255,255,255,0.03)', lineHeight: 1,
          }}>mhal</span>
        </div>

        {hasInput ? (
          <React.Fragment>
            {/* Baybayin output — the hero */}
            <div style={{
              fontFamily: C.bayb,
              fontSize: 54,
              color: 'white',
              letterSpacing: 10,
              lineHeight: 1.2,
              textAlign: 'center',
              marginBottom: 16,
              textShadow: '0 0 40px rgba(150,180,255,0.25)',
            }}>{sampleBayb}</div>

            {/* Divider */}
            <div style={{
              width: 40, height: 1.5,
              background: 'rgba(255,255,255,0.15)',
              marginBottom: 14,
            }} />

            {/* Latin + syllables */}
            <div style={{
              fontSize: 20, fontWeight: 600,
              color: 'rgba(255,255,255,0.75)',
              letterSpacing: '-0.01em',
              textAlign: 'center', marginBottom: 6,
            }}>{sampleLatin}</div>
            <div style={{
              fontSize: 12, color: 'rgba(255,255,255,0.28)',
              letterSpacing: '0.12em', textAlign: 'center',
            }}>{syllables}</div>

            {/* Action pills */}
            <div style={{
              display: 'flex', gap: 8, marginTop: 24,
            }}>
              {[
                { icon: 'copy',    label: 'Copy'  },
                { icon: 'share-2', label: 'Share' },
              ].map(b => (
                <div key={b.icon} style={{
                  display: 'inline-flex', alignItems: 'center', gap: 6,
                  background: 'rgba(255,255,255,0.08)',
                  border: '1px solid rgba(255,255,255,0.12)',
                  borderRadius: 999, padding: '7px 16px', cursor: 'pointer',
                  fontSize: 12, fontWeight: 500,
                  color: 'rgba(255,255,255,0.65)',
                }}>
                  <i data-lucide={b.icon} style={{ width: 13, height: 13 }}></i>
                  {b.label}
                </div>
              ))}
            </div>
          </React.Fragment>
        ) : (
          /* Empty state */
          <div style={{
            display: 'flex', flexDirection: 'column',
            alignItems: 'center', gap: 10, opacity: 0.35,
          }}>
            <i data-lucide="type" style={{ width: 36, height: 36, color: 'white', strokeWidth: 1 }}></i>
            <div style={{ fontSize: 14, color: 'white', textAlign: 'center', lineHeight: 1.4 }}>
              Type or speak below<br/>to see Baybayin
            </div>
          </div>
        )}
      </div>

      {/* INPUT STRIP — bottom */}
      <div style={{
        flexShrink: 0,
        background: 'rgba(255,255,255,0.05)',
        backdropFilter: 'blur(20px)',
        borderTop: '1px solid rgba(255,255,255,0.08)',
        padding: isIOS ? '12px 16px 28px' : '12px 16px 14px',
      }}>
        <div style={{
          display: 'flex', alignItems: 'center', gap: 10,
        }}>
          {/* Mic button */}
          <div
            onClick={() => setListening(l => !l)}
            style={{
              width: 46, height: 46, borderRadius: '50%', flexShrink: 0,
              background: listening
                ? 'hsl(5, 75%, 55%)'
                : 'rgba(255,255,255,0.1)',
              border: listening
                ? '2px solid rgba(255,100,80,0.5)'
                : '1px solid rgba(255,255,255,0.15)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              cursor: 'pointer',
              boxShadow: listening ? '0 0 16px rgba(255,80,60,0.4)' : 'none',
              transition: 'all 300ms',
            }}>
            <i data-lucide="mic" style={{
              width: 20, height: 20, color: 'white', strokeWidth: 2,
            }}></i>
          </div>

          {/* Text input mock */}
          <div style={{
            flex: 1, background: 'rgba(255,255,255,0.08)',
            border: '1px solid rgba(255,255,255,0.12)',
            borderRadius: 14, padding: '11px 14px',
            display: 'flex', alignItems: 'center', justifyContent: 'space-between',
            minHeight: 46,
          }}>
            {listening ? (
              /* Waveform while recording */
              <div style={{ display: 'flex', alignItems: 'center', gap: 3, height: 20 }}>
                {[14, 22, 10, 18, 26, 12, 20].map((h, i) => (
                  <div key={i} style={{
                    width: 3, height: h,
                    background: 'hsl(5, 75%, 65%)',
                    borderRadius: 99,
                    animation: `wave-bar ${0.6 + i * 0.1}s ease-in-out infinite alternate`,
                  }} />
                ))}
                <span style={{
                  fontSize: 12, color: 'rgba(255,100,80,0.8)',
                  marginLeft: 8, fontWeight: 500,
                }}>Listening…</span>
              </div>
            ) : hasInput ? (
              <span style={{
                fontSize: 15, color: 'rgba(255,255,255,0.75)',
                fontWeight: 400, lineHeight: 1.3,
              }}>{sampleLatin}</span>
            ) : (
              <span style={{
                fontSize: 15, color: 'rgba(255,255,255,0.25)',
              }}>Type in Latin…</span>
            )}

            {/* Clear */}
            {hasInput && !listening && (
              <div onClick={() => setHasInput(false)} style={{ cursor: 'pointer', flexShrink: 0, marginLeft: 8 }}>
                <i data-lucide="x" style={{ width: 16, height: 16, color: 'rgba(255,255,255,0.3)' }}></i>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}


// ── LEARN SCREEN ───────────────────────────────────────────────────────
const LESSONS = [
  {
    id: 'vowels',
    title: 'Vowels',
    subtitle: 'A · E/I · O/U',
    description: 'The three foundational Baybayin vowels — the starting point for every learner.',
    image: 'assets/baybayin.vowels.webp',
    glyph: 'a',
    tag: 'Start here',
  },
  {
    id: 'consonants',
    title: 'Consonants',
    subtitle: '14 base characters',
    description: 'Each consonant carries a default "a" sound. Learn to recognize all 14.',
    image: 'assets/baybayin.consonant.webp',
    glyph: 'ka',
    tag: null,
  },
  {
    id: 'kudlit',
    title: 'Kudlit Marks',
    subtitle: 'Vowel diacritics',
    description: 'Small marks above or below a consonant shift its vowel to "e/i" or "o/u".',
    image: 'assets/baybayin.kudlit.webp',
    glyph: 'ki',
    tag: null,
  },
];

function LearnScreen({ platform }) {
  const isIOS = platform === 'ios';
  return (
    <div style={{
      flex: 1, display: 'flex', flexDirection: 'column',
      background: C.paper, fontFamily: C.font, overflow: 'hidden',
    }} data-screen-label="03 Learn">

      {/* Header */}
      <div style={{
        padding: isIOS ? '8px 18px 14px' : '14px 18px',
        background: C.blue300,
      }}>
        <div style={{
          fontSize: 17, fontWeight: 700, color: C.blue900,
          letterSpacing: '-0.01em',
        }}>Guide to Baybayin</div>
        <div style={{
          fontSize: 12, color: 'rgba(255,255,255,0.65)', marginTop: 2,
        }}>Three lessons. That's all you need.</div>
      </div>

      {/* Lesson list */}
      <div style={{ flex: 1, overflowY: 'auto', padding: '14px 14px 10px' }}>
        {LESSONS.map((l, i) => (
          <div key={l.id} style={{
            background: 'white',
            borderRadius: 16,
            border: `1.25px solid ${C.grey400}`,
            boxShadow: '0 2px 8px -2px rgba(14,20,37,0.08)',
            marginBottom: 12,
            overflow: 'hidden',
            display: 'flex', flexDirection: 'column',
            cursor: 'pointer',
          }}>
            {/* image strip */}
            <div style={{
              height: 110, background: C.blue900,
              display: 'flex', alignItems: 'center', justifyContent: 'space-between',
              padding: '0 20px', position: 'relative', overflow: 'hidden',
            }}>
              {/* lesson number watermark */}
              <span style={{
                position: 'absolute', right: 12, bottom: -16,
                fontFamily: C.bayb, fontSize: 90,
                color: 'rgba(255,255,255,0.06)', lineHeight: 1,
                userSelect: 'none',
              }}>{l.glyph}</span>

              <div>
                {l.tag && (
                  <div style={{
                    background: C.blue500, color: 'white',
                    fontSize: 9.5, fontWeight: 700,
                    padding: '3px 9px', borderRadius: 99,
                    letterSpacing: '0.04em', marginBottom: 6,
                    display: 'inline-block',
                  }}>{l.tag}</div>
                )}
                <div style={{
                  fontSize: 20, fontWeight: 700, color: 'white',
                  letterSpacing: '-0.01em', lineHeight: 1.1,
                }}>{l.title}</div>
                <div style={{
                  fontSize: 11.5, color: 'rgba(255,255,255,0.55)',
                  marginTop: 3,
                }}>{l.subtitle}</div>
              </div>

              <img src={l.image} alt=""
                style={{ height: 80, objectFit: 'contain', flexShrink: 0 }} />
            </div>

            {/* body */}
            <div style={{
              padding: '12px 16px 14px',
              display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12,
            }}>
              <div style={{
                fontSize: 12.5, color: C.grey200, lineHeight: 1.45, flex: 1,
              }}>{l.description}</div>
              <div style={{
                width: 34, height: 34, borderRadius: '50%',
                background: C.blue300, color: C.blue900, flexShrink: 0,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                <i data-lucide="chevron-right" style={{ width: 18, height: 18, strokeWidth: 2.5 }}></i>
              </div>
            </div>
          </div>
        ))}

        {/* Coming soon card */}
        <div style={{
          borderRadius: 16, border: `1.5px dashed ${C.grey400}`,
          padding: '16px', textAlign: 'center',
          display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6,
        }}>
          <div style={{ fontSize: 13, fontWeight: 600, color: C.grey300 }}>More lessons coming soon</div>
          <div style={{ fontSize: 11.5, color: C.grey300, opacity: 0.7 }}>We're working on advanced Baybayin topics.</div>
        </div>
      </div>
    </div>
  );
}

// ── BOTTOM NAV — collapsible floating pill ────────────────────────────
function BottomNav({ active, onTab, platform, darkBg }) {
  const [open, setOpen] = React.useState(false);
  const isIOS = platform === 'ios';

  const tabs = [
    { id: 'scan',      icon: 'scan-text', label: 'Scan'      },
    { id: 'translate', icon: 'languages', label: 'Translate' },
    { id: 'learn',     icon: 'book-open', label: 'Learn'     },
  ];

  const activeTab = tabs.find(t => t.id === active) || tabs[0];

  const pillBg = darkBg
    ? 'rgba(20, 24, 40, 0.85)'
    : isIOS
      ? 'rgba(248,248,250,0.90)'
      : 'rgba(226,232,250,0.92)';
  const pillBorder = darkBg
    ? '1px solid rgba(255,255,255,0.12)'
    : '1px solid rgba(100,120,200,0.18)';
  const iconColor = (id) => {
    if (darkBg) return id === active ? 'white' : 'rgba(255,255,255,0.4)';
    return id === active ? C.blue300 : C.grey300;
  };
  const labelColor = (id) => {
    if (darkBg) return id === active ? 'rgba(255,255,255,0.95)' : 'rgba(255,255,255,0.4)';
    return id === active ? C.blue300 : C.grey300;
  };

  // Re-render lucide after open/close
  React.useEffect(() => {
    if (window.lucide) setTimeout(() => window.lucide.createIcons(), 30);
  }, [open]);

  return (
    <div style={{
      position: 'absolute', bottom: isIOS ? 28 : 20,
      right: 16, zIndex: 20,
      display: 'flex', justifyContent: 'flex-end',
      pointerEvents: 'none', fontFamily: C.font,
    }}>
      {/* tap-outside overlay */}
      {open && (
        <div onClick={() => setOpen(false)} style={{
          position: 'fixed', inset: 0, zIndex: -1, pointerEvents: 'all',
        }} />
      )}

      <div style={{
        pointerEvents: 'all',
        background: pillBg,
        backdropFilter: 'blur(24px)',
        WebkitBackdropFilter: 'blur(24px)',
        border: pillBorder,
        borderRadius: 999,
        boxShadow: darkBg
          ? '0 8px 32px rgba(0,0,0,0.5)'
          : '0 8px 28px rgba(14,20,80,0.16)',
        width: open ? 250 : 52,
        height: 52,
        display: 'flex', alignItems: 'center',
        justifyContent: open ? 'space-around' : 'center',
        padding: open ? '0 16px' : '0',
        cursor: 'pointer',
        transition: 'width 0.35s cubic-bezier(.16,1,.3,1)',
        overflow: 'hidden',
      }}>
        {open ? (
          tabs.map(t => (
            <div key={t.id}
              onClick={() => { onTab && onTab(t.id); setOpen(false); }}
              style={{
                display: 'flex', flexDirection: 'column',
                alignItems: 'center', gap: 3, flex: 1, padding: '6px 0',
              }}>
              <i data-lucide={t.icon} style={{
                width: 20, height: 20, color: iconColor(t.id),
                strokeWidth: t.id === active ? 2.25 : 1.5,
              }}></i>
              <span style={{
                fontSize: 9.5, fontWeight: t.id === active ? 700 : 400,
                color: labelColor(t.id), whiteSpace: 'nowrap',
              }}>{t.label}</span>
            </div>
          ))
        ) : (
          <div onClick={() => setOpen(true)} style={{
            width: '100%', height: '100%',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <i data-lucide={activeTab.icon} style={{
              width: 22, height: 22,
              color: darkBg ? 'white' : C.blue300,
              strokeWidth: 2,
            }}></i>
          </div>
        )}
      </div>
    </div>
  );
}

// ── TOP NAV (shows app icon + profile on non-scanner screens) ──────────
function TopNav({ tab, platform, isGuest }) {
  if (tab === 'scan') return null; // scanner is full-bleed, handles own header
  const isIOS = platform === 'ios';
  return (
    <div style={{
      height: isIOS ? 50 : 54,
      background: isIOS ? 'rgba(248,248,250,0.92)' : C.blue500,
      backdropFilter: isIOS ? 'blur(20px)' : undefined,
      borderBottom: isIOS ? '0.5px solid rgba(0,0,0,0.1)' : `1px solid ${C.blue400}`,
      boxShadow: isIOS ? 'none' : '0 2px 6px rgba(14,20,37,0.1)',
      display: 'flex', alignItems: 'center',
      justifyContent: 'space-between',
      padding: '0 16px', flexShrink: 0,
      fontFamily: C.font,
    }}>
      <img src="assets/AppIcon.webp" style={{
        width: 32, height: 32, borderRadius: 9,
        boxShadow: '0 2px 4px rgba(0,0,0,0.2)',
      }} />
      <div style={{
        position: 'absolute', left: '50%', transform: 'translateX(-50%)',
        fontFamily: C.bayb, fontSize: 22,
        color: isIOS ? C.blue300 : C.blue900,
        letterSpacing: 2,
      }}>kudlit</div>
      <div style={{
        width: 32, height: 32, borderRadius: '50%', overflow: 'hidden',
        border: `2px solid ${isIOS ? C.blue800 : C.blue400}`,
        cursor: 'pointer', flexShrink: 0,
      }}>
        <img src="assets/profpic.placeholder.webp"
          style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
      </div>
    </div>
  );
}

// ── STATUS BAR overlay for scanner (dark) ─────────────────────────────
// The frame components render their own status bars, but scanner
// needs dark-mode icons → we pass dark={true} via the frame.

// ── ROOT APP ───────────────────────────────────────────────────────────
function KudlitApp({ platform = 'android', t = {} }) {
  const [tab, setTab] = React.useState(t.startTab || 'scan');
  React.useEffect(() => { setTab(t.startTab || 'scan'); }, [t.startTab]);
  React.useEffect(() => {
    if (window.lucide) setTimeout(() => window.lucide.createIcons(), 30);
  }, [tab]);

  const screen = (() => {
    if (tab === 'scan')      return <ScanScreen platform={platform} />;
    if (tab === 'translate') return <TranslateScreen platform={platform} />;
    if (tab === 'learn')     return <LearnScreen platform={platform} />;
  })();

  return (
    <div style={{
      height: '100%', display: 'flex', flexDirection: 'column',
      background: tab === 'scan' ? '#0a0c14' : C.paper,
      position: 'relative',
    }}>
      <TopNav tab={tab} platform={platform} isGuest={t.isGuest} />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', minHeight: 0 }}>
        {screen}
      </div>
      <BottomNav active={tab} onTab={setTab} platform={platform} darkBg={tab === 'scan'} />
    </div>
  );
}

// CSS for scanning animation (injected once)
if (!document.getElementById('kudlit-scan-style')) {
  const style = document.createElement('style');
  style.id = 'kudlit-scan-style';
  style.textContent = `
    @keyframes scan-sweep {
      0%   { transform: translateX(-50%) translateY(-80px); opacity: 0; }
      15%  { opacity: 1; }
      85%  { opacity: 1; }
      100% { transform: translateX(-50%) translateY(80px); opacity: 0; }
    }
    @keyframes result-slide-up {
      from { transform: translateY(100%); opacity: 0; }
      to   { transform: translateY(0);    opacity: 1; }
    }
    @keyframes pulse-dot {
      0%, 100% { opacity: 1; transform: scale(1); }
      50%       { opacity: 0.4; transform: scale(0.75); }
    }
  `;
  document.head.appendChild(style);
}

Object.assign(window, { KudlitApp });

// Tooran — main app screens (Home, History, Help, Desktop two-pane)
const { useState: useS, useEffect: useE, useMemo: useM, useRef: useR } = React;

// initial seed
const seedCategories = () => {
  const now = Date.now();
  const t = (name, desc, done, ago) => ({
    id: 'task_' + Math.random().toString(36).slice(2,9),
    name, desc: desc || '',
    done: !!done,
    created: now - ago * 86400000,
    completedAt: done ? now - (ago - 0.3) * 86400000 : null,
  });
  return [
    {
      id: 'c_today', name: 'Today', color: 'var(--primary)',
      tasks: [
        t('Walk the dog before sunrise', '• Bring water\n• 30 min loop through the park', true, 0.5),
        t('Reply to Mira about the contract', 'Confirm the timeline and the deposit amount.\n\n1. Confirm milestones\n2. Send draft\n3. Schedule call', false, 0.4),
        t('Pick up sourdough starter', 'From the bakery on 14th — they close at 4pm.', false, 0.3),
        t('Pay the electric bill', '', true, 0.2),
      ],
    },
    {
      id: 'c_writing', name: 'Writing', color: '#9C7B5C',
      tasks: [
        t('Outline chapter 3', 'Three scenes:\n1. Returning home\n2. The letter\n3. Departure', false, 1),
        t('Edit yesterday\'s pages', 'Tighten the dialogue.', false, 1),
        t('Submit essay to The Atlantic', '', true, 4),
      ],
    },
    {
      id: 'c_house', name: 'House', color: '#6A8C57',
      tasks: [
        t('Water the fiddle leaf', '', true, 0.1),
        t('Replace the kitchen bulb', '', true, 1),
        t('Order new bath towels', 'Linen, oat color, 4 bath + 2 hand.', false, 2),
        t('Schedule chimney sweep', 'Before October.', false, 3),
      ],
    },
    {
      id: 'c_someday', name: 'Someday', color: '#7E8FAE',
      tasks: [
        t('Learn to make miso from scratch', '', false, 14),
        t('Plan the Lisbon trip', '• Flights\n• Find a quiet apartment\n• Make a list of bookshops', false, 21),
      ],
    },
  ];
};

function useToorState() {
  const [cats, setCats] = useS(seedCategories);
  const [history, setHistory] = useS([]);
  const [expanded, setExpanded] = useS({ c_today: true });

  const toggleTask = (catId, taskId) => {
    setCats(cs => cs.map(c => c.id !== catId ? c : ({
      ...c,
      tasks: c.tasks.map(t => t.id !== taskId ? t : ({
        ...t,
        done: !t.done,
        completedAt: !t.done ? Date.now() : null,
      })),
    })));
  };
  const addTask = (catId, payload) => {
    const t = {
      id: 'task_' + Math.random().toString(36).slice(2,9),
      name: payload.name, desc: payload.desc || '',
      done: false, created: Date.now(), completedAt: null,
    };
    setCats(cs => cs.map(c => c.id !== catId ? c : ({ ...c, tasks: [t, ...c.tasks] })));
  };
  const editTask = (catId, taskId, payload) => {
    setCats(cs => cs.map(c => c.id !== catId ? c : ({
      ...c, tasks: c.tasks.map(t => t.id !== taskId ? t : ({ ...t, ...payload })),
    })));
  };
  const deleteTask = (catId, taskId) => {
    setCats(cs => cs.map(c => c.id !== catId ? c : ({
      ...c, tasks: c.tasks.filter(t => t.id !== taskId),
    })));
  };
  const addCategory = (name) => {
    const c = {
      id: 'c_' + Math.random().toString(36).slice(2,9),
      name, color: 'var(--primary)', tasks: [],
    };
    setCats(cs => [...cs, c]);
    setExpanded(e => ({ ...e, [c.id]: true }));
  };
  const editCategory = (id, name) => {
    setCats(cs => cs.map(c => c.id !== id ? c : ({ ...c, name })));
  };
  const softDeleteCategory = (id) => {
    const c = cats.find(x => x.id === id);
    if (!c) return;
    setHistory(h => [{ ...c, deletedAt: Date.now() }, ...h]);
    setCats(cs => cs.filter(x => x.id !== id));
  };
  const restoreCategory = (id) => {
    const c = history.find(x => x.id === id);
    if (!c) return;
    setHistory(h => h.filter(x => x.id !== id));
    setCats(cs => [...cs, { ...c, deletedAt: undefined }]);
  };
  const purgeCategory = (id) => setHistory(h => h.filter(x => x.id !== id));
  const restoreLast = () => {
    setHistory(h => {
      if (!h.length) return h;
      const [first, ...rest] = h;
      setCats(cs => [...cs, { ...first, deletedAt: undefined }]);
      return rest;
    });
  };

  return {
    cats, setCats, history, expanded, setExpanded,
    toggleTask, addTask, editTask, deleteTask,
    addCategory, editCategory, softDeleteCategory, restoreCategory, purgeCategory, restoreLast,
  };
}

// ============================================================
// Mobile Home
// ============================================================
function MobileHome({ initialDark = false, view = 'home' }) {
  const S = useToorState();
  const [dark, setDark] = useS(initialDark);
  const [page, setPage] = useS(view); // home | history | help
  const [menuOpen, setMenu] = useS(false);

  const [catSheet, setCatSheet] = useS({ open: false, mode: 'add', target: null });
  const [taskSheet, setTaskSheet] = useS({ open: false, mode: 'add', catId: null, target: null });
  const [details, setDetails] = useS({ open: false, task: null, catId: null });
  const [confirm, setConfirm] = useS({ open: false, title: '', body: '', onConfirm: null });
  const [snack, setSnack] = useS({ open: false, msg: '', undo: null });

  const showSnack = (msg, undo) => {
    setSnack({ open: true, msg, undo });
    setTimeout(() => setSnack(s => s.msg === msg ? { ...s, open: false } : s), 4000);
  };

  const dateStr = useM(() => {
    const d = new Date();
    return d.toLocaleDateString(undefined, { weekday: 'long', month: 'long', day: 'numeric' });
  }, []);
  const todayCat = S.cats.find(c => c.id === 'c_today') || S.cats[0];
  const todayDone = todayCat ? todayCat.tasks.filter(t => t.done).length : 0;
  const todayTotal = todayCat ? todayCat.tasks.length : 0;
  const totalOpen = S.cats.reduce((n, c) => n + c.tasks.filter(t => !t.done).length, 0);

  return (
    <div className={`tooran ${dark ? 'dark' : ''}`} style={{ position: 'relative', height: '100%', overflow: 'hidden' }}>
      {/* status bar handled by IOSDevice */}

      {page === 'home' && (
        <div style={{ height: '100%', overflow: 'auto', paddingBottom: 110, paddingTop: 50 }}>
          <div className="appbar">
            <div className="brand">tooran<span className="dot-mark">.</span></div>
            <div className="appbar-actions">
              <button className="icon-btn" onClick={() => setDark(d => !d)} title="Theme">
                {dark ? Icon.sun() : Icon.moon()}
              </button>
              <button className="icon-btn" onClick={() => setMenu(o => !o)}>
                {Icon.more()}
              </button>
            </div>
          </div>

          <div className={`menu ${menuOpen ? 'open' : ''}`}>
            <div className="menu-item" onClick={() => { setMenu(false); setPage('history'); }}>History <span className="key">{S.history.length}</span></div>
            <div className="menu-item" onClick={() => { setMenu(false); setPage('help'); }}>Help</div>
            <div className="menu-divider"/>
            <div className="menu-item" onClick={() => setMenu(false)}>Contact</div>
            <div className="menu-item" onClick={() => setMenu(false)}>About</div>
            <div className="menu-item" onClick={() => setMenu(false)}>Check for updates</div>
          </div>

          <div className="meta-strip">
            <div>
              <div className="t-eyebrow" style={{ marginBottom: 6 }}>{dateStr}</div>
              <div className="greeting">A <em>quiet</em><br/>list of things.</div>
            </div>
          </div>

          {todayCat && todayTotal > 0 && (
            <div className="today">
              <div>
                <div className="label">Today</div>
                <div className="stat"><em>{todayDone}</em> of {todayTotal} done · {totalOpen} open across all</div>
              </div>
              <div style={{ width: 44, height: 44, position: 'relative', display: 'grid', placeItems: 'center' }}>
                <CatRing pct={todayTotal ? todayDone / todayTotal : 0} size={44} stroke={3}/>
                <span style={{ position: 'absolute', fontFamily: 'var(--font-mono)', fontSize: 11, color: 'var(--ink-2)' }}>
                  {Math.round((todayTotal ? todayDone / todayTotal : 0) * 100)}
                </span>
              </div>
            </div>
          )}

          <div style={{ padding: '0 22px', display: 'flex', flexDirection: 'column', gap: 12 }}>
            {S.cats.length === 0 ? (
              <div className="empty">
                <div className="glyph">
                  <svg width="28" height="28" viewBox="0 0 28 28" fill="none">
                    <path d="M3 9a2 2 0 012-2h6l3 3h8a2 2 0 012 2v8a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" stroke="currentColor" strokeWidth="1.5" strokeLinejoin="round"/>
                  </svg>
                </div>
                <h3>No categories yet</h3>
                <p>Tap the button below to create your first category. A folder for the things you want to keep close.</p>
              </div>
            ) : S.cats.map(cat => (
              <CategoryCard
                key={cat.id}
                cat={cat}
                expanded={!!S.expanded[cat.id]}
                onToggle={() => S.setExpanded(e => ({ ...e, [cat.id]: !e[cat.id] }))}
                onToggleTask={S.toggleTask}
                onOpenTask={(t) => setDetails({ open: true, task: t, catId: cat.id })}
                onAddTask={() => setTaskSheet({ open: true, mode: 'add', catId: cat.id, target: null })}
              />
            ))}
          </div>

          <button className="fab" onClick={() => setCatSheet({ open: true, mode: 'add', target: null })}>
            <span className="plus">+</span> Category
          </button>
        </div>
      )}

      {page === 'history' && (
        <HistoryView dark={dark} history={S.history} onBack={() => setPage('home')} onRestore={S.restoreCategory} onPurge={(id) => setConfirm({
          open: true, title: 'Permanently delete?', body: 'This cannot be undone. The category and its tasks will be erased.',
          onConfirm: () => { S.purgeCategory(id); setConfirm({ open: false }); },
        })}/>
      )}
      {page === 'help' && <HelpView onBack={() => setPage('home')}/>}

      {/* sheets */}
      <CategorySheet
        open={catSheet.open}
        mode={catSheet.mode}
        initial={catSheet.target?.name}
        onCancel={() => setCatSheet(s => ({ ...s, open: false }))}
        onSave={(name) => {
          if (catSheet.mode === 'edit' && catSheet.target) S.editCategory(catSheet.target.id, name);
          else S.addCategory(name);
          setCatSheet(s => ({ ...s, open: false }));
        }}
      />
      <TaskSheet
        open={taskSheet.open}
        mode={taskSheet.mode}
        initial={taskSheet.target}
        onCancel={() => setTaskSheet(s => ({ ...s, open: false }))}
        onSave={(payload) => {
          if (taskSheet.mode === 'edit' && taskSheet.target) S.editTask(taskSheet.catId, taskSheet.target.id, payload);
          else S.addTask(taskSheet.catId, payload);
          setTaskSheet(s => ({ ...s, open: false }));
        }}
      />
      <TaskDetailsSheet
        open={details.open}
        task={details.task && S.cats.find(c => c.id === details.catId)?.tasks.find(t => t.id === details.task.id)}
        onClose={() => setDetails({ open: false, task: null, catId: null })}
        onEdit={() => {
          setTaskSheet({ open: true, mode: 'edit', catId: details.catId, target: details.task });
          setDetails({ open: false, task: null, catId: null });
        }}
        onToggle={(id) => S.toggleTask(details.catId, id)}
      />
      <Dialog
        open={confirm.open}
        title={confirm.title}
        body={confirm.body}
        onCancel={() => setConfirm({ open: false })}
        onConfirm={confirm.onConfirm || (() => setConfirm({ open: false }))}
      />

      <div className={`snackbar ${snack.open ? 'open' : ''}`}>
        <span>{snack.msg}</span>
        {snack.undo && <button className="undo" onClick={() => { snack.undo(); setSnack({ open: false }); }}>Undo</button>}
      </div>
    </div>
  );
}

// ============================================================
// History
// ============================================================
function HistoryView({ history, onBack, onRestore, onPurge }) {
  return (
    <div style={{ height: '100%', overflow: 'auto', paddingTop: 50, paddingBottom: 40 }}>
      <div className="appbar">
        <button className="icon-btn" onClick={onBack} title="Back">
          <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
            <path d="M10 3l-5 5 5 5" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </button>
        <div className="t-eyebrow">History</div>
        <div style={{ width: 36 }}/>
      </div>
      <div className="meta-strip" style={{ paddingTop: 18 }}>
        <div>
          <div className="t-eyebrow" style={{ marginBottom: 6 }}>{history.length} archived</div>
          <div className="greeting"><em>Things</em> you<br/>once kept.</div>
        </div>
      </div>
      <div style={{ padding: '0 22px', display: 'flex', flexDirection: 'column', gap: 10 }}>
        {history.length === 0 ? (
          <div className="empty">
            <div className="glyph">
              <svg width="26" height="26" viewBox="0 0 26 26" fill="none">
                <path d="M3 8h20M5 8v13a2 2 0 002 2h12a2 2 0 002-2V8M9 8V5a2 2 0 012-2h4a2 2 0 012 2v3" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
              </svg>
            </div>
            <h3>Nothing here</h3>
            <p>Deleted categories will land here. You can restore them, or let them go.</p>
          </div>
        ) : history.map(h => (
          <div key={h.id} style={{ background: 'var(--surface)', border: '1px solid var(--hairline)', borderRadius: 14, padding: '14px 16px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 4 }}>
              <div style={{ fontFamily: 'var(--font-display)', fontSize: 22 }}>{h.name}</div>
              <div className="t-meta">{fmtDate(h.deletedAt)}</div>
            </div>
            <div style={{ fontSize: 13, color: 'var(--ink-3)' }}>{h.tasks.length} tasks · {h.tasks.filter(t => t.done).length} done</div>
            <div style={{ display: 'flex', gap: 8, marginTop: 14 }}>
              <button className="btn" style={{ height: 38, fontSize: 13 }} onClick={() => onRestore(h.id)}>Restore</button>
              <button className="btn" style={{ height: 38, fontSize: 13, color: 'var(--error)', borderColor: 'var(--hairline-strong)' }} onClick={() => onPurge(h.id)}>Delete forever</button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ============================================================
// Help
// ============================================================
function HelpView({ onBack }) {
  const items = [
    { k: 'Tap a category', v: 'Expands the list of tasks beneath it.' },
    { k: 'Tap the circle', v: 'Marks a task complete. The line strikes through.' },
    { k: 'Tap a task', v: 'Opens the full description and details.' },
    { k: 'Long press', v: 'Picks up the row to reorder.' },
    { k: 'Swipe right', v: 'Edit. Swipe left to delete.' },
  ];
  return (
    <div style={{ height: '100%', overflow: 'auto', paddingTop: 50, paddingBottom: 40 }}>
      <div className="appbar">
        <button className="icon-btn" onClick={onBack}>
          <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
            <path d="M10 3l-5 5 5 5" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </button>
        <div className="t-eyebrow">Help</div>
        <div style={{ width: 36 }}/>
      </div>
      <div className="meta-strip" style={{ paddingTop: 18 }}>
        <div>
          <div className="t-eyebrow" style={{ marginBottom: 6 }}>How it works</div>
          <div className="greeting">Small <em>gestures</em>,<br/>quiet results.</div>
        </div>
      </div>
      <div style={{ padding: '0 22px', display: 'flex', flexDirection: 'column', gap: 0 }}>
        {items.map((x, i) => (
          <div key={i} style={{ display: 'grid', gridTemplateColumns: '110px 1fr', gap: 16, padding: '14px 0', borderBottom: '1px solid var(--hairline)' }}>
            <div className="t-eyebrow">{x.k}</div>
            <div style={{ fontSize: 14.5, lineHeight: 1.45, color: 'var(--ink)' }}>{x.v}</div>
          </div>
        ))}
        <div style={{ marginTop: 26, padding: '20px 0 0', borderTop: '1px solid var(--hairline)', color: 'var(--ink-3)', fontSize: 13, lineHeight: 1.6 }}>
          Tooran is local-first. Your lists never leave your device unless you say so.
        </div>
      </div>
    </div>
  );
}

// ============================================================
// Desktop · two/three-pane with modals
// ============================================================
//
// Props matrix (combinable):
//   initialDark : boolean   — light or dark theme
//   view        : 'home' | 'history' | 'help' | 'empty'
//   detail      : boolean   — show right-hand task detail panel (three-pane)
//   modal       : null | 'cat' | 'task' | 'confirm'   — overlay
//
// All variants share the same chrome (sidebar + main) so the artboards read as
// the same app in different states, not separate apps.
// ============================================================

const seedHistory = () => {
  const day = 86400000;
  const now = Date.now();
  return [
    { id: 'h1', name: 'Garden — winter', deletedAt: now - 3*day,  tasks: Array.from({length: 5}, (_, i) => ({ id: 'h1t'+i, done: i < 3 })) },
    { id: 'h2', name: 'Apartment hunt', deletedAt: now - 9*day,  tasks: Array.from({length: 8}, (_, i) => ({ id: 'h2t'+i, done: i < 8 })) },
    { id: 'h3', name: 'Reading list — Q1', deletedAt: now - 24*day, tasks: Array.from({length: 12}, (_, i) => ({ id: 'h3t'+i, done: i < 7 })) },
  ];
};

function DesktopApp({ initialDark = false, view = 'home', detail = false, modal = null }) {
  const S = useToorState();
  const [dark, setDark] = useS(initialDark);
  const isEmpty = view === 'empty';
  const cats = isEmpty ? [] : S.cats;
  const [activeId, setActive] = useS(cats[0]?.id);
  const active = cats.find(c => c.id === activeId) || cats[0];
  const total = active ? active.tasks.length : 0;
  const done = active ? active.tasks.filter(t => t.done).length : 0;
  const pct = total ? done / total : 0;

  // For the detail-panel artboard, pick the second open task as a
  // representative selection — it has a description worth rendering.
  const detailTask = useM(() => {
    if (!detail || !active) return null;
    return active.tasks.find(t => !t.done && t.desc) || active.tasks[1] || active.tasks[0];
  }, [detail, active]);

  const dateStr = useM(() => new Date().toLocaleDateString(undefined, { weekday: 'long', month: 'long', day: 'numeric' }), []);
  const historyList = view === 'history' ? (S.history.length ? S.history : seedHistory()) : [];

  return (
    <div className={`tooran ${dark ? 'dark' : ''}`} style={{ height: '100%', position: 'relative', overflow: 'hidden' }}>
      <div className={`desk ${detail ? 'three' : ''}`}>
        {/* ── Sidebar ─────────────────────────────────────────── */}
        <aside className="desk-side">
          <div className="desk-head">
            <div className="brand">tooran<span className="dot-mark">.</span></div>
            <div style={{ display: 'flex', gap: 6 }}>
              <button className="icon-btn" onClick={() => setDark(d => !d)}>{dark ? Icon.sun() : Icon.moon()}</button>
              <button className="icon-btn">{Icon.more()}</button>
            </div>
          </div>
          <div className="desk-search">
            {Icon.search()} Search
            <span className="kbd">⌘K</span>
          </div>
          <div style={{ padding: '6px 12px 4px', fontFamily: 'var(--font-mono)', fontSize: 10.5, letterSpacing: '0.14em', textTransform: 'uppercase', color: 'var(--ink-3)' }}>
            Categories
          </div>
          {isEmpty ? (
            <div className="empty-side">No categories yet. Create one to begin.</div>
          ) : (
            <div style={{ overflow: 'auto', paddingBottom: 8, flex: 1 }}>
              {cats.map(c => {
                const t = c.tasks.length, d = c.tasks.filter(x => x.done).length;
                const p = t ? d / t : 0;
                return (
                  <div key={c.id} className={`desk-cat ${c.id === activeId && view === 'home' ? 'active' : ''}`} onClick={() => setActive(c.id)}>
                    <div style={{ position: 'relative', width: 28, height: 28, display: 'grid', placeItems: 'center' }}>
                      <CatRing pct={p} size={28} stroke={2.2} color={c.color}/>
                      <span style={{ position: 'absolute', fontFamily: 'var(--font-mono)', fontSize: 9, color: 'var(--ink-2)' }}>{Math.round(p*100)}</span>
                    </div>
                    <div className="nm">{c.name}</div>
                    <div className="ct">{d}/{t}</div>
                  </div>
                );
              })}
            </div>
          )}

          {/* secondary nav (history / help) */}
          <div className="desk-side-nav">
            <div className={`item ${view === 'history' ? 'active' : ''}`}>
              <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
                <path d="M2 7a5 5 0 1 0 1.5-3.5L2 5M2 2v3h3" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round"/>
              </svg>
              History <span className="count">{view === 'history' ? historyList.length : (S.history.length || 3)}</span>
            </div>
            <div className={`item ${view === 'help' ? 'active' : ''}`}>
              <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
                <circle cx="7" cy="7" r="5.2" stroke="currentColor" strokeWidth="1.4"/>
                <path d="M5.5 5.5a1.5 1.5 0 1 1 2.2 1.3c-.5.3-.7.6-.7 1.2M7 10v.01" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round"/>
              </svg>
              Help
              <span className="count">⌘?</span>
            </div>
          </div>

          <div style={{ padding: '10px 14px 14px', borderTop: '1px solid var(--hairline)' }}>
            <button className="btn" style={{ width: '100%', height: 40, fontSize: 13 }}>
              + New category
            </button>
          </div>
        </aside>

        {/* ── Main ────────────────────────────────────────────── */}
        <main className="desk-main">
          {view === 'home' && active && (
            <>
              <div className="desk-main-head">
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <div className="eyebrow">{`${done} of ${total} complete`}</div>
                  <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
                    <span className="t-meta">{Math.round(pct*100)}%</span>
                    <div className="dseg" style={{ marginLeft: 6 }}>
                      {active.tasks.map((t) => <span key={t.id} className={t.done ? 'on' : ''}/>)}
                    </div>
                  </div>
                </div>
                <h1>{active.name}</h1>
                <div style={{ display: 'flex', gap: 6 }}>
                  <button className="btn" style={{ flex: 0, padding: '0 16px', height: 36, fontSize: 13 }}>+ Add task</button>
                  <button className="btn" style={{ flex: 0, padding: '0 16px', height: 36, fontSize: 13 }}>Rename</button>
                  <button className="btn" style={{ flex: 0, padding: '0 16px', height: 36, fontSize: 13, color: 'var(--ink-3)' }}>Archive</button>
                </div>
              </div>
              <div className="desk-main-body">
                {active.tasks.map(t => (
                  <div key={t.id} className={`desk-task ${t.done ? 'completed' : ''} ${detailTask && t.id === detailTask.id ? 'selected' : ''}`} onClick={() => S.toggleTask(active.id, t.id)}>
                    <div className={`checkbox ${t.done ? 'checked' : ''}`} style={{ marginLeft: 0, marginTop: 4 }}>
                      {Icon.check()}
                    </div>
                    <div style={{ minWidth: 0 }}>
                      <div className="nm">{t.name}</div>
                      {t.desc && <div className="desc">{t.desc.split('\n')[0]}</div>}
                    </div>
                    <div className="when">{t.done && t.completedAt ? `done · ${fmtDate(t.completedAt)}` : fmtDate(t.created)}</div>
                  </div>
                ))}
              </div>
            </>
          )}

          {view === 'history' && (
            <>
              <div className="desk-main-head">
                <div className="eyebrow">{historyList.length} archived</div>
                <h1><em style={{ color: 'var(--primary)', fontStyle: 'italic' }}>Things</em> you once kept.</h1>
                <div style={{ fontSize: 13.5, color: 'var(--ink-3)', maxWidth: 620, marginTop: 4 }}>
                  Soft-deleted categories live here for thirty days. Restore them, or let them go.
                </div>
              </div>
              <div className="desk-main-body">
                <div className="desk-history-grid">
                  {historyList.map(h => {
                    const t = h.tasks.length, d = h.tasks.filter(x => x.done).length;
                    return (
                      <div key={h.id} className="desk-history-card">
                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', gap: 12 }}>
                          <div className="nm">{h.name}</div>
                          <div className="meta">{fmtDate(h.deletedAt)}</div>
                        </div>
                        <div className="meta" style={{ color: 'var(--ink-3)' }}>{t} tasks · {d} done</div>
                        <div className="actions">
                          <button className="btn">Restore</button>
                          <button className="btn" style={{ color: 'var(--error)', borderColor: 'var(--hairline-strong)' }}>Delete forever</button>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>
            </>
          )}

          {view === 'help' && (
            <>
              <div className="desk-main-head">
                <div className="eyebrow">How it works</div>
                <h1>Small <em style={{ color: 'var(--primary)', fontStyle: 'italic' }}>gestures</em>,<br/>quiet results.</h1>
              </div>
              <div className="desk-main-body">
                <div className="desk-help">
                  {[
                    { k: 'Click a category', v: 'Selects it in the right pane. Use ↑ ↓ to walk the list.' },
                    { k: 'Click a circle', v: 'Marks a task complete. Strike-through lands at 350ms.' },
                    { k: 'Click a row', v: <>Opens the detail panel. <span className="kbd">Space</span> toggles done; <span className="kbd">E</span> to edit.</> },
                    { k: 'Search', v: <>Press <span className="kbd">⌘</span><span className="kbd">K</span> to jump anywhere by typing.</> },
                    { k: 'New', v: <><span className="kbd">⌘</span><span className="kbd">N</span> for a category, <span className="kbd">⌘</span><span className="kbd">⇧</span><span className="kbd">N</span> for a task in the active category.</> },
                    { k: 'Theme', v: <>Toggle with the moon icon, or press <span className="kbd">⌘</span><span className="kbd">⇧</span><span className="kbd">D</span>.</> },
                  ].map((x, i) => (
                    <div key={i} className="row">
                      <div className="k">{x.k}</div>
                      <div className="v">{x.v}</div>
                    </div>
                  ))}
                  <div className="footnote">
                    Tooran is local-first. Your lists never leave your device unless you say so. The desktop build keeps the same data model as the mobile build — open the app on either, and the lists agree.
                  </div>
                </div>
              </div>
            </>
          )}

          {view === 'empty' && (
            <div className="desk-empty-hero">
              <div className="glyph">
                <svg width="34" height="34" viewBox="0 0 28 28" fill="none">
                  <path d="M3 9a2 2 0 012-2h6l3 3h8a2 2 0 012 2v8a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" stroke="currentColor" strokeWidth="1.5" strokeLinejoin="round"/>
                </svg>
              </div>
              <h2>A <em>blank</em> page, yours.</h2>
              <p>Categories hold tasks. Tasks hold what they hold. Nothing more — start with a folder for the things you want to keep close.</p>
              <button className="btn primary">+ Create your first category</button>
              <div className="t-meta" style={{ marginTop: 16 }}>or press <span style={{ fontFamily: 'var(--font-mono)', background: 'var(--surface-2)', border: '1px solid var(--hairline)', borderRadius: 4, padding: '1px 6px', margin: '0 2px' }}>⌘N</span></div>
            </div>
          )}
        </main>

        {/* ── Detail panel (three-pane) ───────────────────────── */}
        {detail && detailTask && active && (
          <aside className="desk-detail">
            <div className="desk-detail-head">
              <div>
                <div className="eyebrow">{detailTask.done ? 'Completed' : 'Open'}</div>
                <div className="t-meta" style={{ marginTop: 4 }}>{active.name}</div>
              </div>
              <div style={{ display: 'flex', gap: 4 }}>
                <button className="icon-btn" title="Edit">
                  <svg width="14" height="14" viewBox="0 0 16 16" fill="none">
                    <path d="M11 2.5l2.5 2.5L5 13.5l-3 .5.5-3L11 2.5z" stroke="currentColor" strokeWidth="1.5" strokeLinejoin="round"/>
                  </svg>
                </button>
                <button className="icon-btn" title="Close">
                  <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
                    <path d="M3 3l8 8M11 3l-8 8" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
                  </svg>
                </button>
              </div>
            </div>
            <div className="desk-detail-body">
              <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12 }}>
                <div className={`checkbox ${detailTask.done ? 'checked' : ''}`} style={{ marginLeft: 0, marginTop: 8, width: 24, height: 24 }}>
                  {Icon.check()}
                </div>
                <h2 style={{ flex: 1 }}>{detailTask.name}</h2>
              </div>
              <div className="desk-detail-card">
                {(detailTask.desc || '').trim()
                  ? detailTask.desc
                  : <span style={{ color: 'var(--ink-3)', fontStyle: 'italic', fontFamily: 'var(--font-display)', fontSize: 17 }}>No description.</span>}
              </div>
              <div className="desk-detail-meta">
                <div>
                  <div className="lbl">Status</div>
                  <div className="val" style={{ color: detailTask.done ? 'var(--success)' : 'var(--ink)' }}>
                    {detailTask.done ? 'Done' : 'In progress'}
                  </div>
                </div>
                <div>
                  <div className="lbl">Created</div>
                  <div className="val">{fmtDate(detailTask.created)}</div>
                  <div className="t-meta" style={{ marginTop: 2 }}>{fmtTime(detailTask.created)}</div>
                </div>
                <div>
                  <div className="lbl">Category</div>
                  <div className="val">{active.name}</div>
                </div>
                {detailTask.completedAt && (
                  <div>
                    <div className="lbl">Completed</div>
                    <div className="val">{fmtDate(detailTask.completedAt)}</div>
                    <div className="t-meta" style={{ marginTop: 2 }}>{fmtTime(detailTask.completedAt)}</div>
                  </div>
                )}
              </div>
            </div>
          </aside>
        )}
      </div>

      {/* ── Modal overlays ───────────────────────────────────── */}
      {modal === 'cat' && (
        <>
          <div className="desk-modal-scrim"/>
          <div className="desk-modal">
            <div className="eyebrow">New category</div>
            <h3>What are we keeping close?</h3>
            <div className="field">
              <label>Name</label>
              <div className="input" style={{ display: 'block' }}>Reading List</div>
            </div>
            <div className="desk-modal-footer">
              <span className="hint"><span className="kbd">Esc</span> to cancel · <span className="kbd">↵</span> to create</span>
              <button className="btn">Cancel</button>
              <button className="btn primary">Create</button>
            </div>
          </div>
        </>
      )}

      {modal === 'task' && (
        <>
          <div className="desk-modal-scrim"/>
          <div className="desk-modal wide">
            <div className="eyebrow">New task · in “{active?.name || 'Today'}”</div>
            <h3>Something to do.</h3>
            <div className="field">
              <label>Name</label>
              <div className="input" style={{ display: 'block' }}>Plan the Lisbon trip</div>
            </div>
            <div className="field">
              <label>Description</label>
              <div className="textarea" style={{ display: 'block', whiteSpace: 'pre-wrap' }}>{`• Flights from JFK\n• A quiet apartment in Alfama\n• Make a list of bookshops`}</div>
            </div>
            <div className="format-toolbar" style={{ padding: 0, marginTop: 6 }}>
              <button className="tool">{Icon.bullet()} Bullet</button>
              <button className="tool">{Icon.numlist()} Numbered</button>
            </div>
            <div className="desk-modal-footer">
              <span className="hint"><span className="kbd">⌘</span><span className="kbd">↵</span> to add</span>
              <button className="btn">Cancel</button>
              <button className="btn primary">Add task</button>
            </div>
          </div>
        </>
      )}

      {modal === 'confirm' && (
        <>
          <div className="desk-modal-scrim"/>
          <div className="desk-modal" style={{ width: 460 }}>
            <div className="eyebrow" style={{ color: 'var(--error)' }}>Delete category</div>
            <h3>Delete “{active?.name || 'Today'}”?</h3>
            <p style={{ color: 'var(--ink-2)', fontSize: 14, lineHeight: 1.55, margin: '0 0 4px' }}>
              It has {total} task{total === 1 ? '' : 's'}. The category and its tasks will move to History — you can restore them within thirty days.
            </p>
            <div className="desk-modal-footer">
              <button className="btn">Cancel</button>
              <button className="btn danger">Delete</button>
            </div>
          </div>
        </>
      )}
    </div>
  );
}

Object.assign(window, { MobileHome, DesktopApp, HistoryView, HelpView, useToorState, seedCategories });

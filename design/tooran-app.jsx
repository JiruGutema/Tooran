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
// Desktop two-pane
// ============================================================
function DesktopApp({ initialDark = false }) {
  const S = useToorState();
  const [dark, setDark] = useS(initialDark);
  const [activeId, setActive] = useS(S.cats[0]?.id);
  const active = S.cats.find(c => c.id === activeId) || S.cats[0];
  const total = active ? active.tasks.length : 0;
  const done = active ? active.tasks.filter(t => t.done).length : 0;
  const pct = total ? done / total : 0;

  return (
    <div className={`tooran ${dark ? 'dark' : ''}`} style={{ height: '100%' }}>
      <div className="desk">
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
          <div style={{ overflow: 'auto', paddingBottom: 14 }}>
            {S.cats.map(c => {
              const t = c.tasks.length, d = c.tasks.filter(x => x.done).length;
              const p = t ? d / t : 0;
              return (
                <div key={c.id} className={`desk-cat ${c.id === activeId ? 'active' : ''}`} onClick={() => setActive(c.id)}>
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
          <div style={{ marginTop: 'auto', padding: '12px 18px 18px', borderTop: '1px solid var(--hairline)' }}>
            <button className="btn" style={{ width: '100%', height: 40, fontSize: 13 }}>+ New category</button>
          </div>
        </aside>

        <main className="desk-main">
          <div className="desk-main-head">
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div className="eyebrow">{active ? `${done} of ${total} complete` : '—'}</div>
              <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
                <span className="t-meta">{Math.round(pct*100)}%</span>
                <div className="dseg" style={{ marginLeft: 6 }}>
                  {active && active.tasks.map((t, i) => <span key={t.id} className={t.done ? 'on' : ''}/>)}
                </div>
              </div>
            </div>
            <h1>{active?.name || 'No category'}</h1>
            <div style={{ display: 'flex', gap: 6 }}>
              <button className="btn" style={{ flex: 0, padding: '0 16px', height: 36, fontSize: 13 }}>+ Add task</button>
              <button className="btn" style={{ flex: 0, padding: '0 16px', height: 36, fontSize: 13 }}>Edit</button>
              <button className="btn" style={{ flex: 0, padding: '0 16px', height: 36, fontSize: 13, color: 'var(--ink-3)' }}>Today</button>
            </div>
          </div>
          <div className="desk-main-body">
            {active && active.tasks.map(t => (
              <div key={t.id} className={`desk-task ${t.done ? 'completed' : ''}`} onClick={() => S.toggleTask(active.id, t.id)}>
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
        </main>
      </div>
    </div>
  );
}

Object.assign(window, { MobileHome, DesktopApp, HistoryView, HelpView, useToorState, seedCategories });

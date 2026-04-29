// Tooran prototype — main app component
// Uses CSS variables from styles.css and is themed via .tooran / .tooran.dark on root.

const { useState, useEffect, useRef, useMemo } = React;

// ---------- Icons ----------
const Icon = {
  check: (p) => (
    <svg width="14" height="14" viewBox="0 0 14 14" fill="none" {...p}>
      <path d="M2.5 7.5L6 11l5.5-7" stroke="#FBF7EE" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
  chev: (p) => (
    <svg width="12" height="12" viewBox="0 0 12 12" fill="none" {...p}>
      <path d="M4.5 2L8.5 6l-4 4" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
  more: (p) => (
    <svg width="18" height="18" viewBox="0 0 18 18" fill="none" {...p}>
      <circle cx="4" cy="9" r="1.5" fill="currentColor"/>
      <circle cx="9" cy="9" r="1.5" fill="currentColor"/>
      <circle cx="14" cy="9" r="1.5" fill="currentColor"/>
    </svg>
  ),
  sun: (p) => (
    <svg width="18" height="18" viewBox="0 0 18 18" fill="none" {...p}>
      <circle cx="9" cy="9" r="3.2" stroke="currentColor" strokeWidth="1.5"/>
      {[0,45,90,135,180,225,270,315].map(d=>(
        <line key={d} x1="9" y1="1.5" x2="9" y2="3.2" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" transform={`rotate(${d} 9 9)`}/>
      ))}
    </svg>
  ),
  moon: (p) => (
    <svg width="18" height="18" viewBox="0 0 18 18" fill="none" {...p}>
      <path d="M14 11A6 6 0 0 1 7 4a4 4 0 1 0 7 7Z" stroke="currentColor" strokeWidth="1.5" strokeLinejoin="round"/>
    </svg>
  ),
  grip: (p) => (
    <svg width="14" height="14" viewBox="0 0 14 14" fill="currentColor" {...p}>
      <circle cx="5" cy="3" r="1"/><circle cx="9" cy="3" r="1"/>
      <circle cx="5" cy="7" r="1"/><circle cx="9" cy="7" r="1"/>
      <circle cx="5" cy="11" r="1"/><circle cx="9" cy="11" r="1"/>
    </svg>
  ),
  plus: (p) => (
    <svg width="14" height="14" viewBox="0 0 14 14" fill="none" {...p}>
      <path d="M7 2v10M2 7h10" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round"/>
    </svg>
  ),
  bullet: (p) => (
    <svg width="12" height="12" viewBox="0 0 12 12" fill="currentColor" {...p}>
      <circle cx="2.5" cy="3.5" r="1.2"/><rect x="5" y="3" width="6" height="1.4" rx="0.7"/>
      <circle cx="2.5" cy="8.5" r="1.2"/><rect x="5" y="8" width="6" height="1.4" rx="0.7"/>
    </svg>
  ),
  numlist: (p) => (
    <svg width="14" height="12" viewBox="0 0 14 12" fill="currentColor" {...p}>
      <text x="0" y="5" fontFamily="ui-monospace,monospace" fontSize="5" fill="currentColor">1.</text>
      <rect x="5.5" y="2" width="8" height="1.4" rx="0.7"/>
      <text x="0" y="11" fontFamily="ui-monospace,monospace" fontSize="5" fill="currentColor">2.</text>
      <rect x="5.5" y="8" width="8" height="1.4" rx="0.7"/>
    </svg>
  ),
  search: (p) => (
    <svg width="14" height="14" viewBox="0 0 14 14" fill="none" {...p}>
      <circle cx="6" cy="6" r="4" stroke="currentColor" strokeWidth="1.5"/>
      <path d="M9.2 9.2L12 12" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
    </svg>
  ),
};

// ---------- Helpers ----------
const fmtDate = (d) => {
  const date = new Date(d);
  return date.toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
};
const fmtTime = (d) => {
  const date = new Date(d);
  return date.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' });
};

// ---------- Category glyph ring ----------
function CatRing({ pct, size = 36, stroke = 2.5, color }) {
  const r = (size - stroke) / 2;
  const c = 2 * Math.PI * r;
  return (
    <svg width={size} height={size}>
      <circle cx={size/2} cy={size/2} r={r} fill="none" stroke="var(--ink-4)" strokeWidth={stroke} strokeOpacity="0.4"/>
      <circle cx={size/2} cy={size/2} r={r} fill="none"
        stroke={color || "var(--primary)"} strokeWidth={stroke} strokeLinecap="round"
        strokeDasharray={c} strokeDashoffset={c * (1 - pct)}
        style={{ transition: 'stroke-dashoffset .5s cubic-bezier(.2,.7,.3,1)' }}/>
    </svg>
  );
}

// ---------- Confetti burst ----------
function Confetti({ active }) {
  if (!active) return null;
  const pieces = Array.from({ length: 14 }, (_, i) => i);
  return (
    <div style={{ position: 'absolute', left: '50%', top: '50%', pointerEvents: 'none', zIndex: 5 }}>
      {pieces.map(i => {
        const angle = (i / pieces.length) * Math.PI * 2;
        const dist = 30 + Math.random() * 18;
        const cx = Math.cos(angle) * dist;
        const cy = Math.sin(angle) * dist;
        const cr = (Math.random() - 0.5) * 720;
        const colors = ['var(--primary)', 'var(--success)', 'var(--secondary)', 'var(--warning)'];
        const bg = colors[i % colors.length];
        return (
          <span key={i} style={{
            position: 'absolute', width: 6, height: 6, borderRadius: 1,
            background: bg, left: 0, top: 0,
            ['--cx']: cx + 'px', ['--cy']: cy + 'px', ['--cr']: cr + 'deg',
            animation: 'confetti .9s cubic-bezier(.2,.7,.3,1) forwards',
          }}/>
        );
      })}
    </div>
  );
}

// ---------- Task row ----------
function TaskRow({ task, onToggle, onOpen }) {
  const [pulsing, setPulsing] = useState(false);
  const handleToggle = (e) => {
    e.stopPropagation();
    if (!task.done) {
      setPulsing(true);
      setTimeout(() => setPulsing(false), 600);
    }
    onToggle(task.id);
  };
  return (
    <div className={`task ${task.done ? 'completed' : ''}`} onClick={() => onOpen(task)}>
      <div onClick={handleToggle} style={{ position: 'relative', display: 'grid', placeItems: 'center', height: 44 }}>
        <div className={`checkbox ${task.done ? 'checked' : ''}`}>
          {Icon.check()}
        </div>
        <Confetti active={pulsing}/>
      </div>
      <div style={{ minWidth: 0 }}>
        <div className="task-name">{task.name}</div>
        {task.desc && <div className="task-desc">{task.desc.split('\n')[0]}</div>}
      </div>
      <div className="task-handle">{Icon.grip()}</div>
    </div>
  );
}

// ---------- Category card ----------
function CategoryCard({ cat, expanded, onToggle, onToggleTask, onOpenTask, onAddTask }) {
  const total = cat.tasks.length;
  const done = cat.tasks.filter(t => t.done).length;
  const pct = total ? done / total : 0;

  return (
    <div className={`cat-card ${expanded ? 'expanded' : ''}`}>
      <div className="cat-row" onClick={onToggle}>
        <div className="cat-glyph">
          <CatRing pct={pct} color={cat.color}/>
          <span className="pct">{Math.round(pct * 100)}</span>
        </div>
        <div>
          <div className="cat-title">{cat.name}</div>
          <div className="cat-sub">
            {total === 0 ? 'No tasks yet' : `${done} of ${total} · ${total - done} left`}
          </div>
        </div>
        <div className="cat-chev">{Icon.chev()}</div>
      </div>

      {total > 0 && !expanded && (
        <div className="dots">
          {cat.tasks.map((t, i) => (
            <span key={t.id} className={`dot ${t.done ? 'done' : ''}`} style={{ background: t.done ? (cat.color || 'var(--primary)') : undefined }}/>
          ))}
        </div>
      )}

      <div className="cat-body">
        <div className="cat-body-inner">
          {total === 0 ? (
            <div style={{ padding: '20px 22px 18px 56px', color: 'var(--ink-3)', fontSize: 13 }}>
              No tasks yet · tap below to add your first
            </div>
          ) : cat.tasks.map(t => (
            <TaskRow key={t.id} task={t} onToggle={(id) => onToggleTask(cat.id, id)} onOpen={onOpenTask}/>
          ))}
          <div className="add-task" onClick={onAddTask}>
            {Icon.plus()} Add task
          </div>
        </div>
      </div>
    </div>
  );
}

// ---------- Sheets ----------
function Sheet({ open, onClose, children, height = 'auto' }) {
  return (
    <>
      <div className={`scrim ${open ? 'open' : ''}`} onClick={onClose}/>
      <div className={`sheet ${open ? 'open' : ''}`} style={{ height }}>
        <div className="grabber"/>
        {children}
      </div>
    </>
  );
}

function CategorySheet({ open, mode, initial, onCancel, onSave }) {
  const [name, setName] = useState('');
  useEffect(() => { if (open) setName(initial || ''); }, [open, initial]);
  return (
    <Sheet open={open} onClose={onCancel}>
      <div className="sheet-header">
        <span className="eyebrow">{mode === 'edit' ? 'Edit category' : 'New category'}</span>
      </div>
      <div className="field">
        <label>Name</label>
        <input className="input" autoFocus value={name} onChange={e => setName(e.target.value)} placeholder="A new beginning…"/>
      </div>
      <div className="sheet-footer">
        <button className="btn" onClick={onCancel}>Cancel</button>
        <button className="btn primary" onClick={() => name.trim() && onSave(name.trim())}>{mode === 'edit' ? 'Save' : 'Create'}</button>
      </div>
    </Sheet>
  );
}

function TaskSheet({ open, mode, initial, onCancel, onSave }) {
  const [name, setName] = useState('');
  const [desc, setDesc] = useState('');
  const descRef = useRef(null);
  useEffect(() => { if (open) { setName(initial?.name || ''); setDesc(initial?.desc || ''); } }, [open, initial]);

  const insert = (text) => {
    const el = descRef.current;
    if (!el) return;
    const start = el.selectionStart, end = el.selectionEnd;
    const v = desc;
    const before = v.slice(0, start);
    const needsNl = before.length > 0 && !before.endsWith('\n');
    const ins = (needsNl ? '\n' : '') + text;
    setDesc(before + ins + v.slice(end));
    setTimeout(() => { el.focus(); el.selectionStart = el.selectionEnd = start + ins.length; }, 0);
  };

  return (
    <Sheet open={open} onClose={onCancel}>
      <div className="sheet-header">
        <span className="eyebrow">{mode === 'edit' ? 'Edit task' : 'New task'}</span>
      </div>
      <div className="field">
        <label>Name</label>
        <input className="input" autoFocus value={name} onChange={e => setName(e.target.value)} placeholder="What needs doing?"/>
      </div>
      <div className="field" style={{ paddingTop: 18 }}>
        <label>Description</label>
        <textarea ref={descRef} className="textarea" value={desc} onChange={e => setDesc(e.target.value)} placeholder="Add notes, steps, links…"/>
      </div>
      <div className="format-toolbar">
        <button className="tool" onClick={() => insert('• ')}>{Icon.bullet()} Bullet</button>
        <button className="tool" onClick={() => insert('1. ')}>{Icon.numlist()} Numbered</button>
      </div>
      <div className="sheet-footer">
        <button className="btn" onClick={onCancel}>Cancel</button>
        <button className="btn primary" onClick={() => name.trim() && onSave({ name: name.trim(), desc })}>{mode === 'edit' ? 'Save' : 'Add task'}</button>
      </div>
    </Sheet>
  );
}

function TaskDetailsSheet({ open, task, onClose, onEdit, onToggle }) {
  if (!task) return null;
  // render rich-ish description: lines starting with •, numbered patterns, blanks
  const lines = (task.desc || '').split('\n');
  return (
    <Sheet open={open} onClose={onClose} height="78%">
      <div className="sheet-header" style={{ alignItems: 'center' }}>
        <span className="eyebrow">{task.done ? 'Completed' : 'Open'}</span>
        <button className="icon-btn" onClick={onEdit} style={{ color: 'var(--ink-2)' }}>
          <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
            <path d="M11 2.5l2.5 2.5L5 13.5l-3 .5.5-3L11 2.5z" stroke="currentColor" strokeWidth="1.5" strokeLinejoin="round"/>
          </svg>
        </button>
      </div>
      <div style={{ padding: '0 22px', flex: 1, overflow: 'auto' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '4px 0 18px' }}>
          <div onClick={() => onToggle(task.id)} className={`checkbox ${task.done ? 'checked' : ''}`} style={{ marginLeft: 0, width: 26, height: 26 }}>
            {Icon.check()}
          </div>
          <div className="t-display" style={{ fontSize: 30 }}>{task.name}</div>
        </div>
        <div style={{ background: 'var(--surface-2)', border: '1px solid var(--hairline)', borderRadius: 14, padding: '16px 18px', marginBottom: 18 }}>
          {(task.desc || '').trim().length === 0 ? (
            <div style={{ color: 'var(--ink-3)', fontStyle: 'italic', fontFamily: 'var(--font-display)', fontSize: 17 }}>No description.</div>
          ) : (
            <div style={{ color: 'var(--ink)', fontSize: 14.5, lineHeight: 1.55, whiteSpace: 'pre-wrap' }}>
              {lines.map((line, i) => <div key={i} style={{ minHeight: '1.55em' }}>{line || '\u00A0'}</div>)}
            </div>
          )}
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 18, paddingBottom: 12 }}>
          <div>
            <div className="t-eyebrow" style={{ marginBottom: 4 }}>Status</div>
            <div style={{ fontFamily: 'var(--font-display)', fontSize: 18, color: task.done ? 'var(--success)' : 'var(--ink)' }}>
              {task.done ? 'Done' : 'In progress'}
            </div>
          </div>
          <div>
            <div className="t-eyebrow" style={{ marginBottom: 4 }}>Created</div>
            <div style={{ fontFamily: 'var(--font-display)', fontSize: 18 }}>{fmtDate(task.created)}</div>
            <div className="t-meta" style={{ marginTop: 2 }}>{fmtTime(task.created)}</div>
          </div>
          {task.completedAt && (
            <div>
              <div className="t-eyebrow" style={{ marginBottom: 4 }}>Completed</div>
              <div style={{ fontFamily: 'var(--font-display)', fontSize: 18 }}>{fmtDate(task.completedAt)}</div>
              <div className="t-meta" style={{ marginTop: 2 }}>{fmtTime(task.completedAt)}</div>
            </div>
          )}
        </div>
      </div>
    </Sheet>
  );
}

// ---------- Confirmation dialog ----------
function Dialog({ open, title, body, onCancel, onConfirm, confirmLabel = 'Delete' }) {
  return (
    <>
      <div className={`scrim ${open ? 'open' : ''}`} onClick={onCancel} style={{ zIndex: 59 }}/>
      <div className={`dialog ${open ? 'open' : ''}`}>
        <h4>{title}</h4>
        <p>{body}</p>
        <div className="row">
          <button className="btn" onClick={onCancel}>Cancel</button>
          <button className="btn danger" onClick={onConfirm}>{confirmLabel}</button>
        </div>
      </div>
    </>
  );
}

// expose
Object.assign(window, { TaskRow, CategoryCard, CategorySheet, TaskSheet, TaskDetailsSheet, Dialog, Sheet, Icon, fmtDate, fmtTime, CatRing });

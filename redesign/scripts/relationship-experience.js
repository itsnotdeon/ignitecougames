/* IGNITE Relationship Experience Layer — 20260928
   Adds relationship pulse, streaks, On This Day, timeline, insights, smart surprise,
   After Dark experience copy, and lightweight couple achievements without changing
   the existing rendering architecture.
*/
(() => {
  "use strict";

  const STATE_KEY = "ignite-experience-v1";
  const getJSON = (key, fallback) => {
    try { const v = JSON.parse(localStorage.getItem(key)); return v ?? fallback; }
    catch { return fallback; }
  };
  const esc = (v) => String(v ?? "").replace(/[&<>"']/g, c => ({ "&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#039;" }[c]));
  const memories = () => {
    const m = getJSON("ignite-memories-v1", []);
    return Array.isArray(m) ? m : [];
  };
  const progress = () => getJSON("ignite-progression-v1", {});
  const prefs = () => getJSON("ignite-preferences-v1", { vibes:["Romantic"] });
  const names = () => {
    const s = getJSON("ignite-redesign-v4", {});
    return { p1:s.names?.p1 || "You", p2:s.names?.p2 || "your person" };
  };
  const exp = () => getJSON(STATE_KEY, { seenOnThisDay: {}, completedMoments: [] });
  const saveExp = (v) => localStorage.setItem(STATE_KEY, JSON.stringify(v));

  function currentMode() {
    return document.querySelector("#app")?.dataset?.igniteMode === "dark" ? "dark" : "normal";
  }
  function modeCopy() {
    return currentMode() === "dark"
      ? { kicker:"AFTER DARK", title:"Slow down. Stay close.", body:"A more intimate space for two — choose only what feels right." }
      : { kicker:"TONIGHT'S PULSE", title:"Make tonight yours.", body:"A little play, a little conversation, and one moment worth remembering." };
  }
  function todayKey() {
    const d = new Date();
    return d.getMonth()+"-"+d.getDate();
  }
  function onThisDay() {
    const now = new Date();
    return memories().filter(m => {
      const raw = m.memoryDate || m.date || m.createdAt;
      if (!raw) return false;
      const d = new Date(raw);
      return !Number.isNaN(d.getTime()) && d.getMonth() === now.getMonth() && d.getDate() === now.getDate() && d.getFullYear() !== now.getFullYear();
    }).sort((a,b)=>new Date(b.memoryDate||b.date)-new Date(a.memoryDate||a.date))[0] || null;
  }
  function streak() {
    return Math.max(0, Number(progress()?.stats?.currentStreak || 0));
  }
  function stats() {
    const m = memories();
    const p = progress();
    return {
      memories:m.length,
      games:Number(p?.stats?.minigamesPlayed || p?.stats?.gamesPlayed || 0),
      journeys:Number(p?.stats?.journeysCompleted || p?.stats?.journeys || 0),
      activities:Number(p?.stats?.activitiesCompleted || 0)
    };
  }
  function vibe() {
    const p = prefs();
    return Array.isArray(p.vibes) && p.vibes[0] ? p.vibes[0] : "Romantic";
  }

  function card(html, cls="rx-card") {
    return '<section class="'+cls+'">'+html+'</section>';
  }

  function homePulse() {
    const root = document.querySelector(".ignite-home-screen");
    if (!root || root.querySelector(".rx-home-pulse")) return;
    const s = streak(), m = onThisDay(), st = stats(), c = modeCopy();
    const pulse = document.createElement("section");
    pulse.className = "rx-home-pulse";
    pulse.innerHTML =
      '<div class="rx-pulse-head"><div><span class="rx-eyebrow">'+esc(c.kicker)+'</span><h2>'+esc(c.title)+'</h2><p>'+esc(c.body)+'</p></div><div class="rx-streak"><b>🔥 '+s+'</b><small>CONNECTED</small></div></div>'+
      '<div class="rx-pulse-actions">'+
        '<button data-rx-action="daily"><span>✦</span><b>Daily Moment</b><small>1–3 min together</small></button>'+
        '<button data-rx-action="journey"><span>♧</span><b>Dynamic Journey</b><small>Let IGNITE build it</small></button>'+
        '<button data-rx-action="surprise"><span>✧</span><b>Surprise Us</b><small>Pick our next vibe</small></button>'+
      '</div>'+
      (m ? '<button class="rx-on-this-day" data-rx-action="memory" data-memory-id="'+esc(m.id||"")+'"><div><span class="rx-eyebrow">ON THIS DAY</span><b>'+esc(m.moment||"A memory worth revisiting")+'</b><small>'+new Date(m.memoryDate||m.date).getFullYear()+' · '+esc(m.note||"A moment from your story.")+'</small></div><i>→</i></button>' : '')+
      '<div class="rx-mini-stats"><span><b>'+st.memories+'</b><small>MEMORIES</small></span><span><b>'+st.games+'</b><small>GAMES</small></span><span><b>'+st.journeys+'</b><small>JOURNEYS</small></span></div>';
    const anchor = root.querySelector(".ignite-section") || root.querySelector(".ignite-home-hero");
    anchor?.after(pulse);
  }

  function playEnhancement() {
    const root = document.querySelector(".play-mock");
    if (!root || root.querySelector(".rx-play-journey")) return;
    const s = streak(), v = vibe(), c = modeCopy();
    const section = document.createElement("section");
    section.className = "rx-play-journey";
    section.innerHTML =
      '<div class="rx-play-kicker">'+esc(c.kicker)+' · '+esc(v.toUpperCase())+'</div>'+
      '<h2>Tonight\'s Journey</h2>'+
      '<p>'+esc(s >= 3 ? "Your rhythm is building. Let IGNITE choose a balanced mix." : "A short sequence that moves from playful to meaningful.")+'</p>'+
      '<div class="rx-steps"><span><b>01</b> Warm Up</span><i>→</i><span><b>02</b> Play</span><i>→</i><span><b>03</b> Connect</span></div>'+
      '<button class="btn primary" data-rx-action="journey">Build Dynamic Journey →</button>';
    root.querySelector(".play-tabs")?.after(section);
    const pref = root.querySelector(".play-preferences-link");
    if (pref) pref.insertAdjacentHTML("beforebegin", '<div class="rx-after-dark-note">🌙 '+esc(currentMode()==="dark" ? "Private, intimate, consent-first moments." : "Switch to After Dark when you want a different pace.")+'</div>');
  }

  function memoriesEnhancement() {
    const root = document.querySelector(".memories-mock");
    if (!root || root.querySelector(".rx-memory-switcher")) return;
    const list = memories().slice().sort((a,b)=>new Date(b.memoryDate||b.date)-new Date(a.memoryDate||a.date));
    const switcher = document.createElement("div");
    switcher.className = "rx-memory-switcher";
    switcher.innerHTML =
      '<button class="active" data-rx-memory-view="archive">Archive</button>'+
      '<button data-rx-memory-view="timeline">Timeline</button>'+
      '<button data-rx-memory-view="today">On This Day</button>';
    const host = root.querySelector(".ignite-memory-list") || root.querySelector(".ignite-category-grid");
    host?.before(switcher);

    const renderTimeline = (mode) => {
      let target = root.querySelector(".rx-memory-view");
      if (!target) { target=document.createElement("div"); target.className="rx-memory-view"; switcher.after(target); }
      if (mode==="archive") { target.remove(); return; }
      let data = mode==="today" ? (onThisDay() ? [onThisDay()] : []) : list;
      if (!data.length) {
        target.innerHTML='<div class="rx-empty">No moments here yet.<br><small>Your story will fill this space.</small></div>';
        return;
      }
      if (mode==="today") {
        const m=data[0];
        target.innerHTML='<article class="rx-today-card"><span class="rx-eyebrow">ON THIS DAY</span><h3>'+esc(m.moment||"A moment worth remembering")+'</h3><p>'+esc(m.note||"Revisit a piece of your story.")+'</p><button data-memory-id="'+esc(m.id||"")+'" class="btn primary">Open Memory →</button></article>';
        return;
      }
      const groups = {};
      data.forEach(m => {
        const d = new Date(m.memoryDate||m.date||m.createdAt);
        const key = Number.isNaN(d.getTime()) ? "Moments" : d.toLocaleString("en-US",{month:"long",year:"numeric"});
        (groups[key] ||= []).push(m);
      });
      target.innerHTML=Object.entries(groups).map(([month,items]) =>
        '<div class="rx-timeline-group"><h3>'+esc(month)+'</h3>'+items.map(m=>{
          const d=new Date(m.memoryDate||m.date||m.createdAt);
          return '<button class="rx-timeline-item" data-memory-id="'+esc(m.id||"")+'"><span class="rx-timeline-dot">♥</span><div><b>'+esc(m.moment||"Untitled memory")+'</b><small>'+(!Number.isNaN(d.getTime())?d.toLocaleDateString("en-GB",{day:"numeric",month:"short"}):"")+' · '+esc(m.category||"moment")+'</small></div><i>→</i></button>';
        }).join("")+'</div>'
      ).join("");
    };
    switcher.addEventListener("click", e => {
      const b=e.target.closest("[data-rx-memory-view]"); if(!b)return;
      switcher.querySelectorAll("button").forEach(x=>x.classList.toggle("active",x===b));
      renderTimeline(b.dataset.rxMemoryView);
    });
  }

  function profileEnhancement() {
    const root = document.querySelector(".profile-mock");
    if (!root || root.querySelector(".rx-profile-insights")) return;
    const s=stats(), st=streak(), v=vibe(), c=modeCopy();
    const box=document.createElement("section");
    box.className="rx-profile-insights";
    box.innerHTML =
      '<div class="rx-eyebrow">YOUR RELATIONSHIP</div><h2>In your own rhythm.</h2><p>These insights come only from what you do together in IGNITE.</p>'+
      '<div class="rx-insight-grid"><div><b>'+s.memories+'</b><small>MEMORIES</small></div><div><b>'+s.games+'</b><small>GAMES</small></div><div><b>'+s.journeys+'</b><small>JOURNEYS</small></div><div><b>'+st+'</b><small>DAY STREAK</small></div></div>'+
      '<div class="rx-vibe"><span>Current vibe</span><b>'+esc(v)+'</b><small>'+esc(c.kicker)+' · '+esc(c.title)+'</small></div>'+
      '<button class="btn ghost full" data-rx-action="achievements">View Couple Achievements →</button>';
    const anchor=root.querySelector(".ignite-profile-stats") || root.querySelector(".ignite-profile-pair");
    anchor?.after(box);
  }

  function routeAction(action, el) {
    if (action==="journey") {
      const dynamic=document.querySelector('[data-action="dynamic"]');
      if(dynamic){ dynamic.click(); return; }
      const start=document.querySelector('[data-action="start"]');
      if(start){ start.click(); return; }
      const journey=document.querySelector('[data-rx-action="journey"]');
      if(journey && journey!==el){ journey.click(); }
      return;
    }
    if (action==="surprise") {
      const surprise=document.querySelector('[data-action="surprise"]');
      if(surprise){ surprise.click(); return; }
      const modal=document.querySelector('[data-home-modal="surprise"]');
      if(modal){ modal.click(); }
      return;
    }
    if (action==="daily") {
      const daily=document.querySelector('[data-home-modal="daily"]');
      if(daily){ daily.click(); return; }
      const start=document.querySelector('[data-action="start"]');
      if(start){ start.click(); }
      return;
    }
    if (action==="memory") {
      const id=el?.dataset?.memoryId;
      const card=document.querySelector('[data-memory-id="'+CSS.escape(id||"")+'"]');
      card?.click();
      if(!card && id){ localStorage.setItem("ignite-rx-pending-memory",id); document.querySelector('[data-action="memories"]')?.click(); }
      return;
    }
    if (action==="achievements") {
      document.querySelector('[data-profile-action="achievements"]')?.click();
      return;
    }
  }

  function observe() {
    const app=document.querySelector("#app");
    if(!app)return;
    let scheduled=false;
    const enhance=()=>{
      scheduled=false;
      const view=app.querySelector(".ignite-home-screen,.play-mock,.memories-mock,.profile-mock");
      if(!view)return;
      if(app.querySelector(".ignite-home-screen")) homePulse();
      if(app.querySelector(".play-mock")) playEnhancement();
      if(app.querySelector(".memories-mock")) memoriesEnhancement();
      if(app.querySelector(".profile-mock")) profileEnhancement();
    };
    new MutationObserver(()=>{
      if(scheduled)return;
      scheduled=true;
      requestAnimationFrame(enhance);
    }).observe(app,{childList:true,subtree:true});
    document.addEventListener("click", e=>{
      const a=e.target.closest("[data-rx-action]");
      if(a){ e.preventDefault(); routeAction(a.dataset.rxAction,a); return; }
    }, true);
    enhance();
  }

  if(document.readyState==="loading") document.addEventListener("DOMContentLoaded",observe,{once:true});
  else observe();
})();
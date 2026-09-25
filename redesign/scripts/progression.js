const PROGRESS_KEY = "ignite-progression-v1";

const LEVELS = [
  { level: 1, title: "Spark", xp: 0 },
  { level: 2, title: "Closer", xp: 100 },
  { level: 3, title: "Connected", xp: 250 },
  { level: 4, title: "In Sync", xp: 500 },
  { level: 5, title: "Ignited", xp: 850 },
  { level: 6, title: "Deeply Connected", xp: 1300 },
  { level: 7, title: "Unstoppable Duo", xp: 1900 },
  { level: 8, title: "IGNITE", xp: 2700 }
];

const ACHIEVEMENTS = [
  { id: "first-spark", title: "First Spark", text: "Mulai perjalanan pertama.", test: p => p.stats.journeysStarted >= 1 },
  { id: "first-journey", title: "First Journey", text: "Selesaikan satu Journey.", test: p => p.stats.journeysCompleted >= 1 },
  { id: "after-dark", title: "After Dark", text: "Selesaikan Journey After Dark.", test: p => p.stats.afterDarkCompleted >= 1 },
  { id: "game-night", title: "Game Night", text: "Mainkan minigame secara langsung.", test: p => p.stats.minigamesPlayed >= 1 },
  { id: "first-memory", title: "Keep the Moment", text: "Simpan memory pertama kalian.", test: p => p.stats.memoriesSaved >= 1 },
  { id: "explorer", title: "Explorer", text: "Mainkan tiga minigame.", test: p => p.stats.minigamesPlayed >= 3 },
  { id: "three-day-streak", title: "Keep the Rhythm", text: "Kembali ke IGNITE selama tiga hari.", test: p => p.stats.currentStreak >= 3 },
  { id: "five-journeys", title: "Five Moments", text: "Selesaikan lima Journey.", test: p => p.stats.journeysCompleted >= 5 }
];

const DEFAULT = () => ({
  xp: 0,
  level: 1,
  title: "Spark",
  stats: {
    journeysStarted: 0,
    journeysCompleted: 0,
    afterDarkCompleted: 0,
    activitiesCompleted: 0,
    ritualsCompleted: 0,
    minigamesPlayed: 0,
    memoriesSaved: 0,
    oneMoreCards: 0,
    currentStreak: 0,
    longestStreak: 0,
    lastActiveDate: null
  },
  achievements: [],
  history: [],
  journeyHistory: [],
  awarded: {}
});

function read() {
  try {
    const saved = JSON.parse(localStorage.getItem(PROGRESS_KEY));
    if (!saved) return DEFAULT();
    const base = DEFAULT();
    return {
      ...base,
      ...saved,
      stats: { ...base.stats, ...(saved.stats || {}) },
      achievements: Array.isArray(saved.achievements) ? saved.achievements : [],
      history: Array.isArray(saved.history) ? saved.history : [],
      journeyHistory: Array.isArray(saved.journeyHistory) ? saved.journeyHistory : [],
      awarded: saved.awarded || {}
    };
  } catch {
    return DEFAULT();
  }
}

function write(progress) {
  localStorage.setItem(PROGRESS_KEY, JSON.stringify(progress));
  return progress;
}

function localDateKey(date = new Date()) {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, "0");
  const d = String(date.getDate()).padStart(2, "0");
  return y + "-" + m + "-" + d;
}

function dayDistance(fromKey, toKey) {
  if (!fromKey) return Infinity;
  const from = new Date(fromKey + "T00:00:00");
  const to = new Date(toKey + "T00:00:00");
  return Math.round((to - from) / 86400000);
}

function touchStreak(progress) {
  const today = localDateKey();
  const last = progress.stats.lastActiveDate;
  if (last === today) return;
  const distance = dayDistance(last, today);
  progress.stats.currentStreak = distance === 1 ? Math.max(1, Number(progress.stats.currentStreak) || 0) + 1 : 1;
  progress.stats.longestStreak = Math.max(
    Number(progress.stats.longestStreak) || 0,
    progress.stats.currentStreak
  );
  progress.stats.lastActiveDate = today;
}

function resolveLevel(xp) {
  let current = LEVELS[0];
  for (const item of LEVELS) if (xp >= item.xp) current = item;
  return current;
}

function checkAchievements(progress) {
  const newlyUnlocked = [];
  for (const achievement of ACHIEVEMENTS) {
    if (!progress.achievements.includes(achievement.id) && achievement.test(progress)) {
      progress.achievements.push(achievement.id);
      newlyUnlocked.push(achievement);
    }
  }
  return newlyUnlocked;
}

export function getProgress() {
  const progress = read();
  const current = resolveLevel(progress.xp);
  progress.level = current.level;
  progress.title = current.title;
  return progress;
}

export function getLevelInfo(xp = getProgress().xp) {
  const current = resolveLevel(xp);
  const next = LEVELS.find(item => item.xp > current.xp) || null;
  const span = next ? next.xp - current.xp : 1;
  const into = next ? xp - current.xp : 1;
  return {
    ...current,
    next,
    progress: next ? Math.max(0, Math.min(100, Math.round((into / span) * 100))) : 100
  };
}

export function awardXP(amount, reason, eventId) {
  const progress = read();
  touchStreak(progress);
  if (eventId && progress.awarded[eventId]) return { progress: getProgress(), added: 0, newlyUnlocked: [] };
  if (eventId) progress.awarded[eventId] = true;
  progress.xp += Math.max(0, Number(amount) || 0);
  if (reason) {
    progress.history.unshift({ amount: Number(amount) || 0, reason, at: new Date().toISOString() });
    progress.history = progress.history.slice(0, 30);
  }
  const previousLevel = progress.level;
  const current = resolveLevel(progress.xp);
  progress.level = current.level;
  progress.title = current.title;
  const newlyUnlocked = checkAchievements(progress);
  write(progress);
  return {
    progress,
    added: Number(amount) || 0,
    levelUp: current.level > previousLevel,
    newlyUnlocked
  };
}

export function startJourney(journeyId) {
  const progress = read();
  touchStreak(progress);
  progress.stats.journeysStarted += 1;
  const unlocked = checkAchievements(progress);
  write(progress);
  return awardXP(10, journeyId === "dark" ? "Started After Dark" : "Started a Journey", "journey-start:" + Date.now());
}

export function completeJourney(journeyId, details = {}) {
  const progress = read();
  touchStreak(progress);
  progress.stats.journeysCompleted += 1;
  if (journeyId === "dark") progress.stats.afterDarkCompleted += 1;

  const completedAt = new Date().toISOString();
  progress.journeyHistory.unshift({
    id: "journey-" + Date.now(),
    journeyId: String(journeyId || "normal"),
    title: String(details.title || (journeyId === "dark" ? "After Dark" : "Journey")),
    subtitle: String(details.subtitle || ""),
    completedAt,
    xp: journeyId === "dark" ? 75 : 60,
    steps: Array.isArray(details.steps) ? details.steps.map((step, index) => ({
      index,
      title: String(step.title || "Moment"),
      kind: String(step.kind || "activity"),
      icon: String(step.icon || "♡")
    })) : []
  });
  progress.journeyHistory = progress.journeyHistory.slice(0, 30);
  write(progress);
  return awardXP(journeyId === "dark" ? 75 : 60, journeyId === "dark" ? "After Dark completed" : "Journey completed", "journey-complete:" + journeyId + ":" + Date.now());
}

export function completeActivity(journeyId, step) {
  const progress = read();
  touchStreak(progress);
  progress.stats.activitiesCompleted += 1;
  write(progress);
  return awardXP(15, "Activity completed", "activity:" + journeyId + ":" + step + ":" + Date.now());
}

export function completeRitual(journeyId, step) {
  const progress = read();
  touchStreak(progress);
  progress.stats.ritualsCompleted += 1;
  write(progress);
  return awardXP(10, "Ritual completed", "ritual:" + journeyId + ":" + step + ":" + Date.now());
}

export function recordMinigamePlayed(gameId) {
  const progress = read();
  touchStreak(progress);
  progress.stats.minigamesPlayed += 1;
  write(progress);
  return awardXP(10, "Played " + gameId, "minigame:" + gameId + ":" + Date.now());
}

export function recordMemorySaved() {
  const progress = read();
  touchStreak(progress);
  progress.stats.memoriesSaved += 1;
  write(progress);
  return progress;
}

export function recordOneMore() {
  const progress = read();
  touchStreak(progress);
  progress.stats.oneMoreCards += 1;
  write(progress);
  return progress;
}

export function resetProgress() {
  localStorage.removeItem(PROGRESS_KEY);
  return DEFAULT();
}

export function achievementList() {
  return ACHIEVEMENTS.map(item => ({ ...item, unlocked: getProgress().achievements.includes(item.id) }));
}

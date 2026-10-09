export type IgniteMode = "normal" | "dark";

export interface CoupleNames {
  p1: string;
  p2: string;
}

export interface IgnitePreferences {
  vibes: string[];
  steps: number;
}

export interface Memory {
  id: string;
  date: string;
  journey: IgniteMode;
  xp: number;
  moment: string;
  note: string;
  photo: string;
  favorite?: boolean;
  [key: string]: unknown;
}

export interface ProgressStats {
  journeysStarted: number;
  journeysCompleted: number;
  activitiesCompleted: number;
  ritualsCompleted: number;
  minigamesPlayed: number;
  memoriesSaved: number;
  oneMoreCards: number;
  afterDarkCompleted: number;
  currentStreak: number;
  longestStreak: number;
  lastActiveDate: string;
}

export interface IgniteProgress {
  xp: number;
  level: number;
  title: string;
  stats: ProgressStats;
  history: Array<{ amount: number; reason: string; at: string }>;
  awarded: Record<string, boolean>;
  achievements: string[];
  journeyHistory: Array<Record<string, unknown>>;
}

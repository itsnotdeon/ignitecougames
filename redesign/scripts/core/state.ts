import type { IgniteMode } from "../../types/ignite";

export interface IgniteProfileDetails {
  pronouns: string;
  birthDate: string;
  bio: string;
}

export interface IgniteAppState {
  names: { p1: string; p2: string; couple: string };
  relationship: string;
  relationshipSince: string | null;
  profileDetails: { p1: IgniteProfileDetails; p2: IgniteProfileDetails };
  coupleBio: string;
  loveLanguage: string;
  anniversaryReminder: boolean;
  preferredContent: IgniteMode;
  currentJourney: { title?: string; steps?: unknown[]; [key: string]: unknown } | null;
  step: number;
  view: string;
  mode: IgniteMode;
  profilePhotos: { p1: string; p2: string; couple: string };
  [key: string]: any;
}

const STORAGE_KEY = "ignite-redesign-v4";
export const TOPIC_CLEAR_VERSION = "20260926-clear-all-topics";

export const state: IgniteAppState = {
  names: { p1: "", p2: "", couple: "" },
  relationship: "Couple",
  relationshipSince: null,
  profileDetails: {
    p1: { pronouns: "", birthDate: "", bio: "" },
    p2: { pronouns: "", birthDate: "", bio: "" }
  },
  coupleBio: "",
  loveLanguage: "",
  anniversaryReminder: true,
  preferredContent: "normal",
  currentJourney: null,
  step: 0,
  view: "home",
  mode: "normal",
  profilePhotos: { p1: "", p2: "", couple: "" }
};

export function clearAllTopicStorageOnce(): void {
  if (localStorage.getItem(TOPIC_CLEAR_VERSION) === "done") return;
  ["ignite-active-content-v1", "ignite-active-topics-v1", "ignite-custom-topics-v1", "ignite-content-v1"]
    .forEach((key) => localStorage.removeItem(key));
  localStorage.setItem(TOPIC_CLEAR_VERSION, "done");
}

export function load(): void {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    const saved: Record<string, any> | null = raw ? JSON.parse(raw) : null;
    if (!saved) return;

    state.names = saved.names || state.names;
    state.relationship = saved.relationship || "Couple";
    state.relationshipSince = saved.relationshipSince || null;
    state.coupleBio = typeof saved.coupleBio === "string" ? saved.coupleBio : "";
    state.loveLanguage = typeof saved.loveLanguage === "string" ? saved.loveLanguage : "";
    state.anniversaryReminder = saved.anniversaryReminder !== false;
    state.preferredContent = saved.preferredContent === "dark" ? "dark" : "normal";
    state.currentJourney = saved.currentJourney || null;
    state.step = Number(saved.step) || 0;
    state.view = saved.view || "home";
    state.mode = saved.mode === "dark" ? "dark" : "normal";
    state.profilePhotos = { ...state.profilePhotos, ...(saved.profilePhotos || {}) };
    state.profileDetails = {
      ...state.profileDetails,
      p1: { ...state.profileDetails.p1, ...(saved.profileDetails?.p1 || {}) },
      p2: { ...state.profileDetails.p2, ...(saved.profileDetails?.p2 || {}) }
    };
    state.__journeyComplete = Boolean(saved.__journeyComplete);
    state.__selectedJourney = Number.isInteger(saved.__selectedJourney) ? saved.__selectedJourney : null;

    if (state.view === "generating") {
      state.view = "home";
      delete state.__journeyTargetSteps;
      delete state.__journeyRoleplayOpen;
      delete state.__journeyRoleplayDone;
    }
  } catch {
    state.view = "home";
  }
}

export function save(): void {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  } catch (error) {
    console.warn("[IGNITE] state save failed", error);
  }
}

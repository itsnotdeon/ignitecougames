import type { IgnitePreferences } from "../../types/ignite";

const KEY = "ignite-preferences-v1";
const DEFAULT: IgnitePreferences = { vibes: ["Romantic"], steps: 5 };
export const VIBES = ["Romantic", "Playful", "Deep", "Competitive", "Spontaneous", "Intimate"] as const;
export type IgniteVibe = typeof VIBES[number];

function read(): IgnitePreferences {
  try {
    const raw: Record<string, unknown> = JSON.parse(localStorage.getItem(KEY) || "{}");
    const candidate = Array.isArray(raw.vibes) && raw.vibes.length ? raw.vibes[0] : DEFAULT.vibes[0];
    const vibe: IgniteVibe = VIBES.includes(candidate as IgniteVibe) ? candidate as IgniteVibe : "Romantic";
    const legacy = raw.steps ?? (raw.duration === "short" ? 4 : raw.duration === "long" ? 6 : 5);
    const steps = Math.max(3, Math.min(12, Number(legacy) || DEFAULT.steps));
    return { vibes: [vibe], steps };
  } catch {
    return { ...DEFAULT, vibes: [...DEFAULT.vibes] };
  }
}

export function getPreferences(): IgnitePreferences {
  const preferences = read();
  return {
    vibes: [preferences.vibes[0] || DEFAULT.vibes[0]],
    steps: Math.max(3, Math.min(12, Number(preferences.steps) || DEFAULT.steps))
  };
}

export function savePreferences(next: Partial<IgnitePreferences> | null | undefined): IgnitePreferences {
  const requested = Array.isArray(next?.vibes) && next.vibes.length ? next.vibes[0] : DEFAULT.vibes[0];
  const vibe: IgniteVibe = VIBES.includes(requested as IgniteVibe) ? requested as IgniteVibe : "Romantic";
  const steps = Math.max(3, Math.min(12, Number(next?.steps) || DEFAULT.steps));
  const preferences: IgnitePreferences = { vibes: [vibe], steps };
  localStorage.setItem(KEY, JSON.stringify(preferences));
  return preferences;
}

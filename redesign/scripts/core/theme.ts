import { app } from "./dom";

export function syncModeTheme(mode: string): void {
  const normalized = mode === "dark" ? "dark" : "normal";
  if (app) app.dataset.igniteMode = normalized;
  document.body.dataset.igniteMode = normalized;
  const meta = document.querySelector<HTMLMetaElement>('meta[name="theme-color"]');
  if (meta) meta.setAttribute("content", normalized === "dark" ? "#030203" : "#170a11");
}

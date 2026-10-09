import { defineConfig } from "vite";

export default defineConfig({
  root: ".",
  publicDir: "public",
  build: {
    outDir: "dist",
    emptyOutDir: true,
    target: "es2022",
    rollupOptions: {
      input: ["index.html", "redesign/index.html"]
    }
  },
  server: { host: "0.0.0.0" }
});

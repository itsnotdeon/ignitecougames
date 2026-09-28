const GITHUB_PAGES_ORIGIN = "https://itsnotdeon.github.io";
const GITHUB_PAGES_PREFIX = "/ignitecougames";

const ALLOWED_METHODS = new Set(["GET", "HEAD", "OPTIONS"]);

function getPath(req) {
  const value = req?.query?.path;
  if (Array.isArray(value)) return value.join("/");
  return typeof value === "string" ? value : "";
}

function isSafePath(pathname) {
  if (!pathname || pathname === "/") return true;
  if (pathname.includes("\\") || pathname.includes("\0")) return false;
  const segments = pathname.split("/");
  return !segments.some((segment) => segment === "..");
}

export default async function handler(req, res) {
  if (!ALLOWED_METHODS.has(req.method || "GET")) {
    res.setHeader("Allow", "GET, HEAD, OPTIONS");
    return res.status(405).json({ error: "Method not allowed" });
  }

  res.setHeader("X-Content-Type-Options", "nosniff");
  res.setHeader("Referrer-Policy", "no-referrer");

  if (req.method === "OPTIONS") {
    res.setHeader("Access-Control-Allow-Origin", "*");
    res.setHeader("Access-Control-Allow-Methods", "GET, HEAD, OPTIONS");
    return res.status(204).end();
  }

  const requestedPath = getPath(req);
  if (!isSafePath(requestedPath)) {
    return res.status(400).json({ error: "Invalid proxy path" });
  }

  const normalizedPath = requestedPath
    .split("/")
    .filter(Boolean)
    .map((segment) => encodeURIComponent(decodeURIComponent(segment)))
    .join("/");

  const target = new URL(
    normalizedPath
      ? GITHUB_PAGES_PREFIX + "/" + normalizedPath
      : GITHUB_PAGES_PREFIX + "/",
    GITHUB_PAGES_ORIGIN,
  );

  const incomingUrl = new URL(req.url || "/", "https://ignite-proxy.invalid");
  target.search = incomingUrl.search;

  try {
    const upstream = await fetch(target, {
      method: req.method === "HEAD" ? "HEAD" : "GET",
      redirect: "manual",
      headers: {
        Accept: req.headers.accept || "*/*",
        "User-Agent": "IGNITE-GitHub-Pages-Proxy/1.0",
      },
    });

    const passthroughHeaders = [
      "content-type",
      "cache-control",
      "etag",
      "last-modified",
      "expires",
      "content-language",
    ];

    for (const header of passthroughHeaders) {
      const value = upstream.headers.get(header);
      if (value) res.setHeader(header, value);
    }

    res.setHeader("X-IGNITE-Proxy", "github-pages");
    res.setHeader("X-IGNITE-Upstream", target.origin);

    if (upstream.status >= 300 && upstream.status < 400) {
      // Keep redirects inside the proxy so browser QA does not jump back to
      // the direct GitHub Pages origin.
      const location = upstream.headers.get("location");
      if (location) {
        const redirectUrl = new URL(location, target);
        if (redirectUrl.origin === GITHUB_PAGES_ORIGIN &&
            redirectUrl.pathname.startsWith(GITHUB_PAGES_PREFIX)) {
          const proxyPath = redirectUrl.pathname.slice(GITHUB_PAGES_PREFIX.length) || "/";
          res.setHeader(
            "Location",
            "/ignite" + proxyPath + redirectUrl.search,
          );
        } else {
          res.setHeader("Location", location);
        }
      }
    }

    if (req.method === "HEAD") {
      return res.status(upstream.status).end();
    }

    const body = Buffer.from(await upstream.arrayBuffer());
    return res.status(upstream.status).send(body);
  } catch (error) {
    console.error("[IGNITE PROXY]", error);
    return res.status(502).json({
      error: "Unable to reach GitHub Pages upstream",
    });
  }
}

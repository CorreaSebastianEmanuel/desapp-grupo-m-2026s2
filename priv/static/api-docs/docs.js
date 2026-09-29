(() => {
  "use strict";
  const error = document.getElementById("docs-error");
  const mode = document.getElementById("credential-mode");
  const value = document.getElementById("credential-value");
  mode.addEventListener("change", () => { value.value = ""; });

  const catalogPath = (path) => path === "/api/players" || /^\/api\/players\/[^/]+$/.test(path);
  const requestInterceptor = (request) => {
    const headers = request.headers || {};
    for (const name of Object.keys(headers)) {
      if (name.toLowerCase() === "authorization" || name.toLowerCase() === "x-api-key") delete headers[name];
    }
    const url = new URL(request.url, window.location.origin);
    if (url.origin === window.location.origin && request.method.toUpperCase() === "GET" && catalogPath(url.pathname) && value.value) {
      if (mode.value === "jwt") headers.Authorization = `Bearer ${value.value}`;
      if (mode.value === "api_key") headers["X-API-Key"] = value.value;
    }
    request.headers = headers;
    request.credentials = "omit";
    return request;
  };

  async function start() {
    try {
      if (typeof SwaggerUIBundle !== "function") throw new Error("UI asset unavailable");
      const response = await fetch("/openapi.json", { credentials: "omit", cache: "no-store" });
      if (!response.ok) throw new Error("contract unavailable");
      const spec = await response.json();
      if (!spec.openapi || !spec.paths) throw new Error("contract invalid");
      SwaggerUIBundle({
        dom_id: "#swagger-ui",
        spec,
        presets: [SwaggerUIBundle.presets.apis],
        deepLinking: false,
        validatorUrl: null,
        supportedSubmitMethods: ["get"],
        persistAuthorization: false,
        showMutatedRequest: false,
        requestInterceptor,
        onComplete: () => { document.documentElement.dataset.docsReady = "true"; },
        onFailure: () => { error.hidden = false; }
      });
    } catch (_) {
      error.hidden = false;
    }
  }
  start();
})();

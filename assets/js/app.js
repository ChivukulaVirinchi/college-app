// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
// If you have dependencies that try to import CSS, esbuild will generate a separate `app.css` file.
// To load it, simply add a second `<link>` to your `root.html.heex` file.

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

import { default as hooks_default } from "./live-table.js";
import {
  FavoritesHook,
  FavoriteButton,
  ShareHook,
  ChartsHook,
} from "./hooks.js";
import { RankBadgeHook } from "./rank_badge_hook.js";
import { RankInputHook } from "./rank_input_hook.js";
import { RankDisplayHook } from "./rank_display_hook.js";
import { CompareButtonHook } from "./compare_button_hook.js";
import { CompareNavHook } from "./compare_nav_hook.js";
import { CompareStorageHook } from "./compare_storage_hook.js";
import {
  CategorySelectHook,
  CategoryFilterHook,
  ProgramCategorySyncHook,
} from "./category_hook.js";
import { CompareCategoryHook } from "./compare_category_hook.js";
import { CmdKHook } from "./cmd_k_hook.js";
import { CutoffChartHook } from "./cutoff_chart_hook.js";
import { HelpPillHook } from "./help_pill_hook.js";

// import { hooks_default } from "../../../../live_table/priv/static/live-table.js";

const csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: {
    ...hooks_default,
    FavoritesHook,
    FavoriteButton,
    ShareHook,
    ChartsHook,
    CompareButtonHook,
    CompareNavHook,
    CompareStorageHook,
    RankBadge: RankBadgeHook,
    RankInput: RankInputHook,
    RankDisplay: RankDisplayHook,
    CategorySelect: CategorySelectHook,
    CategoryFilterHook,
    ProgramCategorySyncHook,
    CompareCategoryHook,
    CmdKHook,
    CutoffChartHook,
    HelpPill: HelpPillHook,
  },
});

const exclusiveLiveTableBooleanGroups = [
  ["filters-gender_filter", "filters-female_filter"],
  ["filters-hs", "filters-all_india", "filters-os"],
];

function liveTableCheckboxFromEvent(event) {
  const target = event.target;

  if (target instanceof HTMLInputElement && target.type === "checkbox") {
    return target;
  }

  if (!(target instanceof Element)) {
    return null;
  }

  const label = target.closest("label");
  if (!label) {
    return null;
  }

  const input = label.htmlFor
    ? document.getElementById(label.htmlFor)
    : label.querySelector('input[type="checkbox"]');

  return input instanceof HTMLInputElement && input.type === "checkbox"
    ? input
    : null;
}

function normalizeExclusiveLiveTableBoolean(event) {
  const target = liveTableCheckboxFromEvent(event);
  if (!target) return;

  const group = exclusiveLiveTableBooleanGroups.find((ids) =>
    ids.includes(target.id),
  );
  if (!group) return;

  const shouldClearPeers =
    ["pointerdown", "mousedown", "click"].includes(event.type)
      ? !target.checked
      : target.checked;

  if (!shouldClearPeers) return;

  group
    .filter((id) => id !== target.id)
    .forEach((id) => {
      const input = document.getElementById(id);
      if (input instanceof HTMLInputElement) {
        input.checked = false;
        input.removeAttribute("checked");
      }
    });
}

document.addEventListener(
  "pointerdown",
  normalizeExclusiveLiveTableBoolean,
  true,
);
document.addEventListener("mousedown", normalizeExclusiveLiveTableBoolean, true);
document.addEventListener("click", normalizeExclusiveLiveTableBoolean, true);
document.addEventListener("input", normalizeExclusiveLiveTableBoolean, true);
document.addEventListener("change", normalizeExclusiveLiveTableBoolean, true);

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

// The lines below enable quality of life phoenix_live_reload
// development features:
//
//     1. stream server logs to the browser console
//     2. click on elements to jump to their definitions in your code editor
//
if (process.env.NODE_ENV === "development") {
  window.addEventListener(
    "phx:live_reload:attached",
    ({ detail: reloader }) => {
      // Enable server log streaming to client.
      // Disable with reloader.disableServerLogs()
      reloader.enableServerLogs();

      // Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
      //
      //   * click with "c" key pressed to open at caller location
      //   * click with "d" key pressed to open at function component definition location
      let keyDown;
      window.addEventListener("keydown", (e) => (keyDown = e.key));
      window.addEventListener("keyup", (e) => (keyDown = null));
      window.addEventListener(
        "click",
        (e) => {
          if (keyDown === "c") {
            e.preventDefault();
            e.stopImmediatePropagation();
            reloader.openEditorAtCaller(e.target);
          } else if (keyDown === "d") {
            e.preventDefault();
            e.stopImmediatePropagation();
            reloader.openEditorAtDef(e.target);
          }
        },
        true,
      );

      window.liveReloader = reloader;
    },
  );
}

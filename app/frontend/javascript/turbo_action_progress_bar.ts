import { Turbo } from "@hotwired/turbo-rails";

/**
 * data-turbo-action can be used to set the url when navigating with Turbo frames. It doesn't
 * actually show the progress bar when this happen. This class takes care of that by binding
 * events to form submissions and checking if the event was from a data-turbo-action element.
 * https://github.com/hotwired/turbo/issues/540#issuecomment-1783752175
 */
export default class turbo_action_progress_bar {
  static frame: HTMLElement;

  bind(): void {
    const adapter = Turbo.navigator.delegate.adapter;

    document.addEventListener("turbo:before-fetch-request", (event) => {
      if (!(event.target instanceof HTMLElement)) return;
      if (event.target.dataset.turboAction === undefined) return;

      turbo_action_progress_bar.frame = event.target;

      adapter.progressBar.setValue(0);
      adapter.progressBar.show();

      if (turbo_action_progress_bar.frame.dataset.turboFade !== "true") return;

      turbo_action_progress_bar.frame.style.transition = "opacity 200ms";
      turbo_action_progress_bar.frame.style.opacity = "0.35";
    }, true);

    document.addEventListener("turbo:before-fetch-response", () => {
      adapter.progressBar.hide();

      turbo_action_progress_bar.frame?.style.removeProperty("pointer-events");

      if (turbo_action_progress_bar.frame?.dataset.turboFade !== "true") return;

      this.remove_loading_state();
    }, true);

    document.addEventListener("turbo:before-cache", () => {
      this.remove_loading_state();
    });
  }

  private remove_loading_state(): void {
    if (!turbo_action_progress_bar.frame) return;

    turbo_action_progress_bar.frame.style.removeProperty("opacity");
    turbo_action_progress_bar.frame.style.removeProperty("transition");
  }
}

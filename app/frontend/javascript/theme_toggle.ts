import switch_toggle from "./switch_toggle";
import { fallback_view_transition } from "./utilities/fallback_view_transition";
import { prefers_reduced_motions } from "./utilities/prefers_reduced_motion";

type Theme = "light" | "dark";

export default class theme_toggle {
  static theme: Theme;
  static html_element: HTMLHtmlElement;

  bind(): void {
    const toggle_button: HTMLButtonElement | null = document.querySelector("[data-action~='toggle_theme']");

    if (!toggle_button) return;

    theme_toggle.html_element = document.querySelector("html") as HTMLHtmlElement;
    theme_toggle.theme = this.get_initial_theme();

    theme_toggle.html_element.style.setProperty("color-scheme", theme_toggle.theme);
    theme_toggle.html_element.style.viewTransitionName = "changing-theme";

    this.set_cookie();

    if (theme_toggle.theme === "dark") new switch_toggle().toggle(toggle_button, true);

    toggle_button.maybe_add_event_listener("click", () => {
      setTimeout(() => {
        fallback_view_transition(() => {
          const current_theme = theme_toggle.html_element.style.getPropertyValue("color-scheme") as Theme;

          theme_toggle.theme = current_theme === "light" ? "dark" : "light";
          theme_toggle.html_element.style.setProperty("color-scheme", theme_toggle.theme);

          this.set_cookie();
          this.toggle_theme_images();
        }, !prefers_reduced_motions());
      }, window.ViewTransition ? 200 : 0);
    });
  }

  private get_initial_theme(): Theme {
    const html_theme = theme_toggle.html_element.style.getPropertyValue("color-scheme");
    const window_theme = window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";

    return (html_theme || window_theme) as Theme;
  }

  private set_cookie(): void {
    document.cookie = `theme=${theme_toggle.theme}; path=/; max-age=31536000`;
  }

  private toggle_theme_images(): void {
    const pictures = document.querySelectorAll<HTMLPictureElement>("picture[data-theme]");

    pictures.forEach(picture => {
      const sources = picture.querySelectorAll<HTMLSourceElement>("source");

      sources.forEach(source => {
        if (!source.srcset) return;

        source.dataset.srcset = source.srcset;
        source.srcset = "";
      });

      const expected_source = picture.querySelector<HTMLSourceElement>(`[media*=${theme_toggle.theme}`)!.dataset.srcset!;
      const image = picture.querySelector("img");

      image!.src = expected_source;

      // Re-insert the picture tag into the dom to force it to re-render right away.
      // Otherwise the image of the previous theme would show while the new one is loaded. Empty space is prefered.
      const cloned_picture = picture.cloneNode(true) as Element;
      picture.insertAdjacentElement("afterend", cloned_picture);

      // The element needs to be cloned, otherwise we'd end up removing both here.
      picture.remove();
    });
  }
}

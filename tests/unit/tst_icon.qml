import QtQuick
import QtTest

import qs.Components as Components
import qs.Models as Models

TestCase {
  name: "Icon"

  Components.Icon {
    id: icon
  }

  /**
   * Verifies the icon displays its name as the rendered text.
   *
   * @returns {void}
   */
  function test_displays_name() {
    icon.name = "notifications";
    compare(icon.text, "notifications");
  }

  /**
   * Verifies the variant maps to the font's FILL variable axis.
   *
   * @returns {void}
   */
  function test_variant_maps_to_fill_axis() {
    icon.variant = Components.Icon.Variant.Filled;
    compare(icon.font.variableAxes.FILL, 1);

    icon.variant = Components.Icon.Variant.Outlined;
    compare(icon.font.variableAxes.FILL, 0);
  }

  /**
   * Verifies a color override replaces the Theme default.
   *
   * @returns {void}
   */
  function test_color_override_replaces_theme_default() {
    verify(icon.color === Models.Theme.accent);

    icon.color = "#ff0000";
    compare(icon.color, "#ff0000");
  }
}

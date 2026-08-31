/**
 * Dropdown placement geometry.
 *
 * The Surface Manager computes the dropdown panel position from the
 * bar-local trigger rectangle. Pure so the clamping rules are unit
 * tested: center on the trigger, never closer to the screen edge than the
 * margin, and never exceed the bar width.
 */

/**
 * Computes the panel x position for a dropdown.
 *
 * @param {{x: number, width: number}} triggerRect - bar-local trigger
 *   rectangle
 * @param {number} panelWidth - panel width in pixels
 * @param {number} barWidth - bar strip width in pixels
 * @param {number} margin - minimum distance from the bar edges
 * @returns {number} clamped panel x in bar coordinates
 */
function panelX(triggerRect, panelWidth, barWidth, margin) {
  const limit = barWidth - panelWidth - margin;
  if (limit < margin) {
    return margin;
  }
  const centered = triggerRect.x + triggerRect.width / 2 - panelWidth / 2;
  return Math.min(limit, Math.max(margin, centered));
}

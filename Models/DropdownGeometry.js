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

/**
 * Interpolates the dropdown shell from its bar trigger to the final panel.
 *
 * @param {{x: number, width: number}} triggerRect - bar-local trigger
 * @param {{x: number, y: number, width: number, height: number, radius: number}} panelRect - final panel geometry
 * @param {number} barHeight - height of the bar origin shape
 * @param {number} progress - reveal progress, clamped to [0, 1]
 * @returns {{x: number, y: number, width: number, height: number, radius: number}} interpolated frame
 */
function morphFrame(triggerRect, panelRect, barHeight, progress) {
  const amount = Math.min(1, Math.max(0, progress));
  const startWidth = Math.max(1, triggerRect.width);
  return {
    x: interpolate(triggerRect.x, panelRect.x, amount),
    y: interpolate(0, panelRect.y, amount),
    width: interpolate(startWidth, panelRect.width, amount),
    height: interpolate(barHeight, panelRect.height, amount),
    radius: interpolate(barHeight / 2, panelRect.radius, amount)
  };
}

/**
 * Interpolates one scalar value.
 *
 * @param {number} start - value at zero progress
 * @param {number} end - value at full progress
 * @param {number} amount - clamped interpolation amount
 * @returns {number} interpolated value
 */
function interpolate(start, end, amount) {
  return start + (end - start) * amount;
}

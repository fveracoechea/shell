/**
 * Dropdown state machine for the reusable bar dropdown surface.
 *
 * The state is a plain normalized object owned by the Surface Manager.
 * Every function returns a fresh state object instead of mutating, so QML
 * bindings react to reassignment and unit tests can pin exact transitions.
 */

/**
 * One normalized dropdown state: the name of the open dropdown (null when
 * closed) and the last trigger rectangle in bar-local coordinates.
 *
 * @typedef {{current: string | null, x: number, width: number}} DropdownState
 */

/**
 * Creates the closed initial state.
 *
 * @returns {DropdownState} state with no open dropdown
 */
function initial() {
  return {
    current: null,
    x: 0,
    width: 0
  };
}

/**
 * Opens a dropdown, replacing any open one. The trigger rect is stored
 * bar-locally so placement can be recomputed on the next open.
 *
 * @param {DropdownState} state - current state
 * @param {string} name - dropdown identity, for example "dashboard"
 * @param {{x: number, width: number}} triggerRect - trigger geometry in
 *   bar-local coordinates
 * @returns {DropdownState} new state
 */
function open(state, name, triggerRect) {
  return {
    current: name,
    x: triggerRect.x,
    width: triggerRect.width
  };
}

/**
 * Closes the open dropdown, keeping the last trigger geometry.
 *
 * @param {DropdownState} state - current state
 * @returns {DropdownState} closed state
 */
function close(state) {
  return {
    current: null,
    x: state.x,
    width: state.width
  };
}

/**
 * Toggles a dropdown by name: closes it when already the current one,
 * otherwise opens (or switches to) it.
 *
 * @param {DropdownState} state - current state
 * @param {string} name - dropdown name
 * @param {{x: number, width: number}} triggerRect - trigger geometry in
 *   bar-local coordinates
 * @returns {DropdownState} new state
 */
function toggle(state, name, triggerRect) {
  return state.current === name ? close(state) : open(state, name, triggerRect);
}

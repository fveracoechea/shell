import QtQuick
import QtTest

// Pins the QQuickItem.mapToItem overload contract the Surface Manager
// trigger mapping depends on: the single-argument form is ambiguous in the
// QML engine and throws, so bar-local trigger geometry must use the typed
// origin overload. Pure QtQuick; no Quickshell dependency.
Item {
  id: root

  // Stands in for the bar surface content item.
  Item {
    id: bar

    x: 10
    width: 200
    height: 40
  }

  // Stands in for a bar widget trigger item; not a child of the bar.
  Item {
    id: trigger

    parent: root
    x: 25
    width: 60
    height: 20
  }

  TestCase {
    name: "TriggerMap"

    function test_single_argument_map_to_item_is_ambiguous() {
      let threw = false;
      try {
        trigger.mapToItem(bar);
      } catch (error) {
        verify(String(error).indexOf("Unable to determine callable overload") !== -1);
        threw = true;
      }
      verify(threw);
    }

    function test_explicit_origin_overload_maps_trigger_origin() {
      const origin = trigger.mapToItem(bar, 0, 0);
      compare(origin.x, 15);
      compare(origin.y, 0);
      compare(trigger.width, 60);
    }
  }
}

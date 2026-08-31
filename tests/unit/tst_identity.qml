import QtQuick
import QtTest

import "../../Models/Identity.js" as Identity

TestCase {
  name: "Identity"

  function test_prefers_user() {
    compare(Identity.displayName("alice", "alice"), "alice");
    compare(Identity.displayName("alice", "bob"), "alice");
  }

  function test_falls_back_to_logname() {
    compare(Identity.displayName(null, "bob"), "bob");
    compare(Identity.displayName("", "bob"), "bob");
  }

  function test_trims_whitespace() {
    compare(Identity.displayName("  alice  ", "bob"), "alice");
  }

  function test_empty_when_both_missing() {
    compare(Identity.displayName(null, null), "");
    compare(Identity.displayName("", ""), "");
  }
}

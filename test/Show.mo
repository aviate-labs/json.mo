import JSON "../src/JSON";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";

import Debug "mo:base/Debug";

assert(JSON.show(#String("hello")) == "\"hello\"");
assert(JSON.show(#Number(1)) == "1");
assert(JSON.show(#Number(-1)) == "-1");

let h = HashMap.HashMap<Text, JSON.JSON>(3, Text.equal, Text.hash);
h.put("givenName", #String("John"));
h.put("familyName", #String("Doe"));
h.put("favNumber", #Number(5));
assert(JSON.show(#Object(h)) == "{\"givenName\": \"John\", \"favNumber\": 5, \"familyName\": \"Doe\"}");

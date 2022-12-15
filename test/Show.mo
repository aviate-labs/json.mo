import JSON "../src/JSON";
import Text "mo:base-0.7.3/Text";

assert(JSON.show(#String("hello")) == "\"hello\"");
assert(JSON.show(#Number(1)) == "1");
assert(JSON.show(#Number(-1)) == "-1");

assert(JSON.show(#Object([
    ("givenName", #String("John")),
    ("familyName", #String("Doe")),
    ("favNumber", #Number(5))
])) == "{\"givenName\": \"John\", \"familyName\": \"Doe\", \"favNumber\": 5}");

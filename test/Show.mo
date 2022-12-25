import JSON "../src/JSON";
import Text "mo:base-0.7.3/Text";
import Debug "mo:base-0.7.3/Debug";

assert (JSON.show(#String("hello")) == "\"hello\"");
assert (JSON.show(#Number(1)) == "1");
assert (JSON.show(#Number(-1)) == "-1");
assert (JSON.show(#Number(-1)) == "-1");

assert (JSON.show(#Float(-3.14)) == "-3.1400000000000001");
assert (JSON.show(#Float(1.234e-4)) == "0.00012339999999999999");
assert (JSON.show(#Float(43e-02)) == "0.42999999999999999");

assert (
    JSON.show(
        #Object([
            ("givenName", #String("John")),
            ("familyName", #String("Doe")),
            ("favNumber", #Number(5)),
        ]),
    ) == "{\"givenName\": \"John\", \"familyName\": \"Doe\", \"favNumber\": 5}",
);

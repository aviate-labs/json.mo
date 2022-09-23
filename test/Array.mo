import JSON "../src/JSON";

let v = switch (JSON.parse("[ 5, 1, 2, 4, 5, 6 ]")) {
    case (null) {
        assert(false);
        #Null;
    };
    case (? v) switch (v) {
        case (#Array(v)) {
            assert(v.size() == 6);
            for (v in v.vals()) switch (v) {
                case (#Number(v)) {};
                case (_) assert(false);
            };
            #Array(v);
        };
        case (_) {
            assert(false);
            #Null;
        };
    };
};

assert(JSON.show(v) == "[5, 1, 2, 4, 5, 6]");

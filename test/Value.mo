import JSON "../src/JSON";

switch (JSON.parse("{ }")) {
    case (null) { assert(false); };
    case (?v) {
        switch (v) {
            case (#Object(v)) {
                assert(v.size() == 0);
            };
            case (_) { assert(false); };
        }
    };
};

switch (JSON.parse("{ \"v\": 1 }")) {
    case (null) { assert(false); };
    case (?v) {
        switch (v) {
            case (#Object(v)) {
                assert(v.size() == 1);
                switch (v[0]) {
                    case (("v", #Number(v))) {
                        assert(v == 1);
                    };
                    case (_) { assert(false); };
                };
            };
            case (_) { assert(false); };
        }
    };
};

switch (JSON.parse("[  ]")) {
    case (null) { assert(false); };
    case (?v) {
        switch (v) {
            case (#Array(v)) {
                assert(v.size() == 0);
            };
            case (_) { assert(false); };
        }
    };
};

switch (JSON.parse("[1, \"txt\"]")) {
    case (null) { assert(false); };
    case (?v) {
        switch (v) {
            case (#Array(v)) {
                assert(v.size() == 2);
                switch (v[0]) {
                    case (#Number(v)) { assert(v == 1); };
                    case (_) { assert(false); };
                };
                switch (v[1]) {
                    case (#String(v)) { assert(v == "txt"); };
                    case (_) { assert(false); };
                };
            };
            case (_) { assert(false); };
        }
    };
};

switch (JSON.parse("\"\\\"quoted\\\"\"")) {
    case (null) { assert(false); };
    case (?v) {
        switch (v) {
            case (#String(v)) {
                assert(v == "\"quoted\"");
            };
            case (_) { assert(false); };
        }
    };
};

switch (JSON.parse("-100")) {
    case (null) { assert(false); };
    case (?v) {
        switch (v) {
            case (#Number(v)) {
                assert(v == -100);
            };
            case (_) { assert(false); };
        }
    };
};

switch (JSON.parse("true")) {
    case (null) { assert(false); };
    case (?v) {
        switch (v) {
            case (#Boolean(v)) {
                assert(v == true);
            };
            case (_) { assert(false); };
        }
    };
};

switch (JSON.parse("   null")) { // Test with spaces.
    case (null) { assert(false); };
    case (?v) {
        switch (v) {
            case (#Null) {};
            case (_) { assert(false); };
        }
    };
};

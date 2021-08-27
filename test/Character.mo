import L "mo:parser-combinators/List";

import JSON "../src/JSON";

switch (JSON.character()(L.fromText("\\n"))) {
    case (null) { assert(false); };
    case (? (x, xs)) {
        assert (x == '\n');
        assert(xs == null);
    };
};

switch (JSON.character()(L.fromText("a"))) {
    case (null) { assert(false); };
    case (? (x, xs)) {
        assert (x == 'a');
        assert(xs == null);
    };
};

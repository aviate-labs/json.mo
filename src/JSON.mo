import Char "mo:base/Char";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Text "mo:base/Text";
import Int "mo:base/Int";

import C "mo:parser-combinators/Combinators";
import L "mo:parser-combinators/List";
import P "mo:parser-combinators/Parser";

module JSON {
    public type JSON = {
        #Number : Int; // TODO: float
        #String : Text;
        #Array : [JSON];
        #Object : HashMap.HashMap<Text,JSON>;
        #Boolean : Bool;
        #Null;
    };

    public func show(json : JSON) : Text {
        switch (json) {
            case (#Number(v)) { Int.toText(v); }; // debug_show returns "+" symbol
            case (#String(v)) { "\"" # v # "\""; };
            case (#Array(v)) {
                var s = "[";
                for (i in v.vals()) {
                    if (s != "[") { s #= ", "; };
                    s #= show(i);
                };
                s # "]";
            };
            case (#Object(v)) {
                var s = "{";
                for ((k, v) in v.entries()) {
                    if (s != "{") { s #= ", "; }; // avoid the first element
                    s #= "\"" # k # "\"" # ": " # show(v);
                };
                s # "}";
            };
            case (#Boolean(v)) {
                if (v) { return "true"; };
                "false";
            };
            case (#Null) { "null"; };
        };
    };

    public func character() : P.Parser<Char, Char> {
        let DQ = Char.fromNat32(0x22);
        C.oneOf([
            C.sat<Char>(func (c : Char) : Bool {
                c != DQ and c != '\\';
            }),
            C.right(
                C.Character.char('\\'),
                C.map(
                    C.Character.oneOf([
                        DQ, '\\', '/', 'b', 'f', 'n', 'r', 't',
                        // TODO: u hex{4}
                    ]),
                    func (c : Char) : Char {
                        switch (c) {
                            case ('b') { Char.fromNat32(0x08); };
                            case ('f') { Char.fromNat32(0x0C); };
                            case ('n') { Char.fromNat32(0x0A); };
                            case ('r') { Char.fromNat32(0x0D); };
                            case ('t') { Char.fromNat32(0x09); };
                            case (_) { c; }
                        };
                    },
                ),
            ),
        ]);
    };

    public func ignoreSpace<A>(
        parserA : P.Parser<Char, A>,
    ) : P.Parser<Char, A> {
        C.right(
            C.many(C.Character.space()),
            parserA,
        );
    };

    public class Parser() {
        public func parse(t : Text) : ?JSON {
            switch (valueParser()(L.fromIter(t.chars()))) {
                case (null) { null; };
                case (? (x, xs)) {
                    switch (xs) {
                        case (null) { ?x; };
                        case (_) { null;  };
                    };
                };
            }
        };

        func valueParser() : P.Parser<Char, JSON> {
            C.bracket(
                C.many(C.Character.space()),
                C.oneOf([
                    objectParser(),
                    arrayParser(),
                    stringParser,
                    numberParser,
                    boolParser,
                    nullParser,
                ]),
                C.many(C.Character.space()),
            );
        };

        func objectParser() : P.Parser<Char, JSON> {
            C.map(
                C.bracket(
                    C.Character.char('{'),
                    ignoreSpace(
                        C.sepBy(
                            C.seq(
                                C.left(
                                    ignoreSpace(string),
                                    ignoreSpace(C.Character.char(':')),
                                ),
                                P.delay(valueParser),
                            ),
                            C.Character.char(','),
                        ),
                    ),
                    C.Character.char('}'),
                ),
                func (t : List.List<(Text, JSON)>) : JSON {
                    #Object(HashMap.fromIter(
                        L.toIter(t),
                        List.size(t),
                        Text.equal,
                        Text.hash,
                    ));
                },
            );
        };

        func arrayParser() : P.Parser<Char, JSON> {
            C.map(
                C.bracket(
                    C.Character.char('['),
                    ignoreSpace(
                        C.sepBy(
                            P.delay(valueParser),
                            C.Character.char(','),
                        ),
                    ),
                    C.Character.char(']'),
                ),
                func (t : List.List<JSON>) : JSON {
                    #Array(List.toArray(t));
                },
            );
        };

        let DQ = C.Character.char(Char.fromNat32(0x22));
        let string : P.Parser<Char, Text> = C.map(
            C.bracket(DQ, C.many(character()), DQ),
            func (t : List.List<Char>) : Text {
                Text.fromIter(L.toIter(t));
            },
        );
        let stringParser : P.Parser<Char, JSON> = C.map(
            string,
            func (t : Text) : JSON {
                #String(t);
            },
        );

        let numberParser : P.Parser<Char, JSON> = C.map(
            C.Int.int(),
            func (i : Int) : JSON {
                #Number(i);
            },
        );

        let boolParser : P.Parser<Char, JSON> = C.map(
            C.choose(
                C.String.string("true"),
                C.String.string("false"),
            ),
            func (t : Text) : JSON {
                if (t == "true") return #Boolean(true);
                #Boolean(false);
            },
        );

        let nullParser : P.Parser<Char, JSON> = C.map(
            C.String.string("null"),
            func (_ : Text) : JSON {
                #Null;
            },
        );
    };
};

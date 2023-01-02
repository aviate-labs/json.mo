import Char "mo:base-0.7.3/Char";
import Iter "mo:base-0.7.3/Iter";
import Int "mo:base-0.7.3/Int";
import Float "mo:base-0.7.3/Float";
import List "mo:base-0.7.3/List";
import Nat8 "mo:base-0.7.3/Nat8";
import Nat32 "mo:base-0.7.3/Nat32";
import Result "mo:base-0.7.3/Result";
import Text "mo:base-0.7.3/Text";

import C "mo:parser-combinators/Combinators";
import L "mo:parser-combinators/List";
import P "mo:parser-combinators/Parser";

module JSON {
    public type JSON = {
        #Number : Int;
        #Float : Float;
        #String : Text;
        #Array : [JSON];
        #Object : [(Text, JSON)];
        #Boolean : Bool;
        #Null;
    };

    public func show(json : JSON) : Text = switch (json) {
        case (#Number(v)) { Int.toText(v); };
        case (#Float(v)) { Float.format(#fix(2), v); };
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
            for ((k, v) in v.vals()) {
                if (s != "{") { s #= ", "; };
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

    private func character() : P.Parser<Char, Char> = C.oneOf([
        C.sat<Char>(func (c : Char) : Bool {
            c != Char.fromNat32(0x22) and c != '\\';
        }),
        C.right(
            C.Character.char('\\'),
            C.map(
                C.Character.oneOf([
                    Char.fromNat32(0x22), '\\', '/', 'b', 'f', 'n', 'r', 't',
                    // TODO: u hex{4}
                ]),
                func (c : Char) : Char {
                    switch (c) {
                        case ('b') { Char.fromNat32(0x08); };
                        case ('f') { Char.fromNat32(0x0C); };
                        case ('n') { Char.fromNat32(0x0A); };
                        case ('r') { Char.fromNat32(0x0D); };
                        case ('t') { Char.fromNat32(0x09); };
                        case (_) { c; };
                    };
                }
            )
        )
    ]);

    private func ignoreSpace<A>(parserA : P.Parser<Char, A>) : P.Parser<Char, A> = C.right(
        C.many(C.Character.space()), parserA
    );

    public func parse(t : Text) : ?JSON = parseValues(L.fromText(t));

    public func parseRaw(data : [Char]) : ?JSON = parseValues(L.fromIter(data.vals()));

    public func parseRawASCII(data : [Nat8]) : ?JSON = parseValues(nat8sToCharList(data.vals()));

    private func parseValues(l : List.List<Char>) : ?JSON = switch (valueParser()(l)) {
        case (null) { null; };
        case (? (x, xs)) {
            switch (xs) {
                case (null) { ?x; };
                case (_) { null;  };
            };
        };
    };

    private func nat8sToCharList(i : Iter.Iter<Nat8>) : List.List<Char> = switch (i.next()) {
        case (null) { null; };
        case (? v)  { ?(Char.fromNat32(Nat32.fromNat(Nat8.toNat(v))), nat8sToCharList(i)); };
    };

    private func valueParser() : P.Parser<Char, JSON> = C.bracket(
        C.many(C.Character.space()),
        C.oneOf([
            objectParser(),
            arrayParser(),
            stringParser(),
            floatParser(),
            numberParser(),
            boolParser(),
            nullParser()
        ]),
        C.many(C.Character.space())
    );

    private func objectParser() : P.Parser<Char, JSON> = C.map(
        C.bracket(
            C.Character.char('{'),
            ignoreSpace(
                C.sepBy(
                    C.seq(
                        C.left(
                            ignoreSpace(string()),
                            ignoreSpace(C.Character.char(':'))
                        ),
                        P.delay(valueParser)
                    ),
                    C.Character.char(',')
                )
            ),
            C.Character.char('}')
        ),
        func (t : List.List<(Text, JSON)>) : JSON {
            #Object(List.toArray(t));
        }
    );

    private func arrayParser() : P.Parser<Char, JSON> = C.map(
        C.bracket(
            C.Character.char('['),
            ignoreSpace(
                C.sepBy(
                    P.delay(valueParser),
                    C.Character.char(',')
                ),
            ),
            C.Character.char(']')
        ),
        func (t : List.List<JSON>) : JSON {
            #Array(List.toArray(t));
        }
    );

    private func string() : P.Parser<Char, Text> = C.map(
        C.bracket(
            C.Character.char(Char.fromNat32(0x22)),
            C.many(character()),
            C.Character.char(Char.fromNat32(0x22))
        ),
        func (t : List.List<Char>) : Text {
            Text.fromIter(L.toIter(t));
        }
    );

    private func stringParser() : P.Parser<Char, JSON> = C.map(
        C.map(
            C.bracket(
                C.Character.char(Char.fromNat32(0x22)), 
                C.many(character()), 
                C.Character.char(Char.fromNat32(0x22))
            ),
            func (t : List.List<Char>) : Text {
                Text.fromIter(L.toIter(t));
            },
        ),
        func (t : Text) : JSON {
            #String(t);
        }
    );

    private func floatParser() : P.Parser<Char, JSON> = C.map(
        C.oneOf([
            parseFloatWithExp(),
            parseFloat(),
        ]),
        func(n : Float) : JSON = #Float(n),
    );

    private func parseFloat() : P.Parser<Char, Float> {
        C.map(
            C.seq<Char, Int, List.List<Char>>(
                C.Int.int(),
                C.right(
                    C.Character.char('.'),
                    C.many1(C.Character.digit()),
                ),
            ),
            func((n, decimal_list) : (Int, List.List<Char>)) : Float {
                let isNegative = n < 0;
                var num = n;
                var n_of_decimals : Float = 0;

                for (char in Iter.fromList(decimal_list)) {
                    let digit = Nat32.toNat(
                        Char.toNat32(char) - Char.toNat32('0')
                    );

                    if (isNegative) {
                        num := num * 10 - digit;
                    } else {
                        num := num * 10 + digit;
                    };

                    n_of_decimals += 1;
                };

                let float = Float.fromInt(num) / (10 ** n_of_decimals);
            },
        );
    };

    private func parseFloatWithExp() : P.Parser<Char, Float> = C.map(
        C.seq(
            C.oneOf([
                parseFloat(),
                C.map(
                    C.Int.int(),
                    func(i : Int) : Float = Float.fromInt(i),
                ),
            ]),
            C.right(
                C.oneOf([C.String.string("e"), C.String.string("E")]),
                C.Int.int(),
            ),
        ),
        func((n, exponent) : (Float, Int)) : Float {
            let exp = Float.fromInt(exponent);
            let isNegative = exp < 0;

            if (isNegative) {
                return n / (10 ** -exp);
            };

            n * (10 ** exp);
        },
    );

    private func numberParser() : P.Parser<Char, JSON> = C.map(
        C.Int.int(),
        func (i : Int) : JSON {
            #Number(i);
        }
    );

    private func boolParser() : P.Parser<Char, JSON> = C.map(
        C.choose(
            C.String.string("true"),
            C.String.string("false")
        ),
        func (t : Text) : JSON {
            if (t == "true") return #Boolean(true);
            #Boolean(false);
        }
    );

    private func nullParser() : P.Parser<Char, JSON> = C.map(
        C.String.string("null"),
        func (_ : Text) : JSON {
            #Null;
        }
    );
};

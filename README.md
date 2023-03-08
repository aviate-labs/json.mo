# JSON

[JSON](https://www.json.org/)

## Example

```motoko
import JSON "mo:json/JSON";
import Debug "mo:base/Debug";

let obj : JSON.JSON = #Object([]);
Debug.print(JSON.show(obj));
// {}

Debug.print(JSON.show(#Object([("username", #String("di-wu"))])));
// {"username": "di-wu"}

Debug.print(JSON.show(#Object([
    ("name", #Object([
        ("firstName", #String("quint"))
    ])),
    ("username", #String("di-wu"))
])));
// {"name": {"firstName": "quint"}, "username": "di-wu"}
```

> Note: The `#Float` type only formats to 2 decimal places.

```motoko
import JSON "mo:json/JSON";
import Debug "mo:base/Debug";

Debug.print(JSON.show(#Object([("amount", #Float(32.4829))])));
// {"amount": "32.48"}
```
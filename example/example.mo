// import JSON "mo:json/JSON";
import JSON "../src/JSON";

import Debug "mo:base/Debug";

let objMap : JSON.ObjectMap = JSON.emptyObjectMap();
let obj    : JSON.JSON      = #Object(objMap);

Debug.print(JSON.show(obj));
// {}

objMap.put("username", #String("di-wu"));

Debug.print(JSON.show(obj));
// {"username": "di-wu"}

let name = JSON.emptyObjectMap();
name.put("firstName", #String("quint"));
objMap.put("name", #Object(name));

Debug.print(JSON.show(obj));
// {"name": {"firstName": "quint"}, "username": "di-wu"}

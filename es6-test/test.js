"use strict";

var _toConsumableArray = function (arr) { if (Array.isArray(arr)) { for (var i = 0, arr2 = Array(arr.length); i < arr.length; i++) arr2[i] = arr[i]; return arr2; } else { return Array.from(arr); } };

require("babel/polyfill");

console.log("[...5]:", [].concat(_toConsumableArray(5)));

console.log("[...'hello']:", [].concat(_toConsumableArray("hello")));

var first = 1;
var rest = [2, 3, 4, 5];

console.log("first:", first);
console.log("rest", rest);

console.log("[1,2,3].map(x => x * x): ", [1, 2, 3].map(function (x) {
  return x * x;
}));

var name = "Bob",
    time = "today";
console.log("模板字符串: " + name + ", how are you " + time + "?");

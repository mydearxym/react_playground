
require("babel/polyfill");

console.log("[...5]:", [...5])

console.log("[...'hello']:", [..."hello"])

const [first, ...rest] = [1, 2, 3, 4, 5];
console.log("first:", first)
console.log("rest", rest)


console.log("[1,2,3].map(x => x * x): ", [1,2,3].map(x => x * x))


var name = "Bob", time = "today";
console.log(`模板字符串: ${name}, how are you ${time}?`)


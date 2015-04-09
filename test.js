function* genFunc () {
    console.log('step 1')
    yield 1
    console.log('step 2')
    yield 2
    console.log('step 3')
    return 3
}



var ret = genFunc()// 输出: 'step 1'
console.log(ret.next())


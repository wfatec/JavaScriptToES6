# 使用Promise

在JS中需要大量使用异步函数，由于JS的事件轮询机制，我们需要大量使用回调函数，这是很容易导致回调地狱问题。此外过多的使用回调会降低代码的复用能力。

ES6中`promise`的出现取代了回调函数。一段返回`promise`的代码是非闭塞的，并且最终将会通过`promise`向调用者返回一个结果或是一个错误。

## 回调地狱

来看一个例子：

```js
const fs = require('fs');

const displayFileContent = function(pathToFile) {
    const handleFile = function(err, contents) {
        if(err) {
            console.log(err.message);
        } else {
            console.log(contents.toString());
        }
    };

    try {
        fs.readFile(pathToFile, handleFile);
    } catch(ex) {
        console.log(ex.message);
    }
};
```

在回调函数`handleFile`中我们将打印错误信息或是处理返回结果并打印。这里产生了一个问题，由于我们在这个处理器中立即打印返回结果，这个函数变得难以复用。如果我们想在打印之前进行其它操作，则很难通过扩展代码来实现它。回调将需要另一个回调来接收数据 -- 这导致了常说的回调地狱。也就是说，当出现一组回调时，回调之间无法很好的组合。

另一个问题是错误的处理方式。回调处理器会处理文件发生错误的情况。然而，`readFile()`(`fs`的一个异步方法)同样可能在调用端发生错误，例如第一个参数为`undefined`或者`null`。因此如何在回调中处理发生错误情况缺乏一致性。此外，如果我们想传递这个错误给调用方，而不是打印错误，我们不得不在多个地方进行处理，例如回调函数内部以及`catch`块中，这实在太糟糕了。

综上，回调地狱来自以下事实：

- 多层级的回调难以组合

- 回调导致代码难以扩展

- 回调参数的顺序没有一致性

- 回调没有一致的方法处理错误

## Promise的作用

promise有且仅有三种状态：pending，resolved或者rejected。

若异步函数未执行结束，promise将处于pending状态；若成功进行完毕，处于resolved状态，并产生执行的结果；若执行失败，则变为rejected状态，并产生错误信息。

promise状态的变化是不可逆的，只能有pengding变为resolved，或者pending变为rejected。

使用promise可以方便的将异步函数作为参数进行传递，从而更优雅的实现函数式编程。
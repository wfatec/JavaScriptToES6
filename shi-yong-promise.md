# 使用Promise

在JS中需要大量使用异步函数，由于JS的事件轮询机制，我们需要大量使用回调函数，这是很容易导致回调地狱问题。此外过多的使用回调会降低代码的复用能力。

ES6中`promise`的出现取代了回调函数。一段返回`promise`的代码是非阻塞的，并且最终将会通过`promise`向调用者返回一个结果或是一个错误。

## 回调地狱

来看一个例子：

```javascript
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

另一个问题是错误的处理方式。回调处理器会处理文件发生错误的情况。然而，`readFile()`\(`fs`的一个异步方法\)同样可能在调用端发生错误，例如第一个参数为`undefined`或者`null`。因此如何在回调中处理发生错误情况缺乏一致性。此外，如果我们想传递这个错误给调用方，而不是打印错误，我们不得不在多个地方进行处理，例如回调函数内部以及`catch`块中，这实在太糟糕了。

综上，回调地狱来自以下事实：

* 多层级的回调难以组合
* 回调导致代码难以扩展
* 回调参数的顺序没有一致性
* 回调没有一致的方法处理错误

## Promise的作用

promise有且仅有三种状态：pending，resolved或者rejected。

若异步函数未执行结束，promise将处于pending状态；若成功进行完毕，处于resolved状态，并产生执行的结果；若执行失败，则变为rejected状态，并产生错误信息。

promise状态的变化是不可逆的，只能有pengding变为resolved，或者pending变为rejected。

使用promise可以方便的将异步函数作为参数进行传递，从而更优雅的实现函数式编程。

Promise提供了两个独立通道来进行通信：

* 数据传递通道，使用`then()`进行传递
* 错误传递通道，使用`chtch()`进行传递

具体流程图如下：

![](.gitbook/assets/bu-huo%20%281%29.PNG)

当A返回数据后，执行`then()`函数B，若B执行reject，则C被跳过，直接执行`catch()`函数D，若D依旧抛出一个异常，则跳过E，直接执行F，若这时F返回一段数据，则被JS包装为promise，并传递到下一个`then()`函数G。简而言之，一个resolved的promise在链上寻找下一个`then()`函数，而一个rejected的promise则寻找下一个`catch()`函数。

## 创建Promise

当写一个异步函数时，可以创建一个promise，这个promise可以是三种状态之一：resolved， rejected，或者pending状态。通过下面的例子我们来使用者三种方法：

```javascript
const computeSqrtAsync = function(number) {
    if(number < 0) {
        return Promise.reject('no negative number, please.');
    }

    if(number === 0) {
        return Promise.resolve(0);
    }

    return new Promise(function(resolve, reject) {
        setTimeout(() => resolve(Math.sqrt(number)), 1000);
    });
};
```

`computeSqrtAsync()`函数返回一个promise实例，这个promise实例的状态根据入参来决定。测试一下效果：

```javascript
const forNegative1 = computeSqrtAsync(-1);
const forZero = computeSqrtAsync(0);
const forSixteen = computeSqrtAsync(16);

console.log(forNegative1);
console.log(forZero);
console.log(forSixteen);
```

结果将输出不同的状态：

```text
Promise { <rejected> 'no negative number, please.' }
Promise { 0 }
Promise { <pending> }
```

接下来实现一个函数入参为一个promise，若resolve则打印其结果，若reject则打印错误信息：

```javascript
const reportOnPromise = function(promise) {
    promise
        .then(result => console.log(`result is ${result}.`))
        .catch(error => console.log(`ERROR: ${error}`));
};

reportOnPromise(forNegative1);
reportOnPromise(forZero);
reportOnPromise(forSixteen);
```

结果为：

```text
result is 0.
ERROR: no negative number, please.
result is 4.
```

由于调用的是异步函数，因此执行的顺序没法保证。

## Promise链

`fs-extra`将`fs`包进行了promise化，首先安装`fs-extra`包：

```text
npm install fs-extra
```

使用`fs-extra`编写实例：

```javascript
const fs = require('fs-extra');

const countLinesWithText = function(pathToFile) {
    fs.readFile(pathToFile)
        .then(content => content.toString())
        .then(content => content.split('\n'))
        .then(lines => lines.filter(line => line.includes('THIS LINE')))
        .then(lines => lines.length)
        .then(count => checkLineExists(count))
        .then(count => console.log(`Number of lines with THIS LINE is ${count}`))
        .catch(error => console.log(`ERROR: ${pathToFile}, ${error.message}`));
};

const checkLineExists = function(count) {
    if(count === 0) {
        throw new Error('text does not exist in file');
    }

    return count;
};
```

## 执行多个Promise

JS提供了两种选项来处理多个异步任务：

* 让这些promise进行竞争，并选择最先resolve或reject的一个
* 等所有任务resolve或是有一个执行reject

### Promise竞争

`race()`是promise的静态方法，首先创建两个promise对象：

```javascript
const createPromise = function(timeInMillis) {
    return new Promise(function(resolve, reject) {
        setTimeout(() => resolve(timeInMillis), timeInMillis);
    });
};

const createTimeout = function(timeInMillis) {
    return new Promise(function(resolve, reject) {
        setTimeout(() => reject(`timeout after ${timeInMillis} MS`), timeInMillis);
    });
};
```

接下来使用`race()`进行测试：

```javascript
Promise.race([createPromise(1000), createPromise(2000), createTimeout(3000)])
    .then(result => console.log(`completed after ${result} MS`))
    .catch(error => console.log(`ERROR: ${error}`));

Promise.race([createPromise(3500), createPromise(4000), createTimeout(2000)])
    .then(result => console.log(`completed after ${result} MS`))
    .catch(error => console.log(`ERROR: ${error}`));
```

结果为：

```text
completed after 1000 MS
ERROR: timeout after 2000 MS
```

### 收集所有Promise

promise的静态方法`all()`获取一个promise数组，并传递一个resolved状态的返回结果数组到`then()`函数。举个例子：

```javascript
'use strict';

const cluster = require('cluster');
const http = require('http');
const url = require('url');
const querystring = require('querystring');
const port = 8084;
const number_of_processes = 8;

const isPrime = function(number) {
    for(let i = 2; i < number; i++) {
        if (number % i === 0) {
            return false;
        }
    }

    return number > 1;
};

const countNumberOfPrimes = function(number) {
    let count = 0;

    for(let i = 1; i <= number; i++) {
        if(isPrime(i)) {
            count++;
        }
    }

    return count;
};

const handler = function(request, response) {
    const params = querystring.parse(url.parse(request.url).query);
    const number = parseInt(params.number);
    const count = countNumberOfPrimes(number);

    response.writeHead(200, { 'Content-Type': 'text/plain' });

    return response.end(`${count}`);
};

if(cluster.isMaster) {
    for(let i = 0; i < number_of_processes; i++) {
        cluster.fork();
    }
} else {
    http.createServer(handler).listen(port);
}
```

要想使用这个服务首先安装`fs-extra`以及`request-promise`：

```text
npm install fs-extra request request-promise
```

具体实现如下：

```javascript
const fs = require('fs-extra');
const request = require('request-promise');

const countPrimes = function(number) {
    if(isNaN(number)) {
        return Promise.reject(`'${number}' is not a number`);
    }

    return request(`http://localhost:8084?number=${number}`)
        .then(count => `Number of primes from 1 to ${number} is ${count}`);
};
```

下面再来看一个实例，假设我们有一个文件，每一行有一个数字，我们想要确定每一行的数字内有多少个质数，可以这样做：

```javascript
const countPrimesForEachLine = function(pathToFile) {
    fs.readFile(pathToFile)
        .then(content => content.toString())
        .then(content =>content.split('\n'))
        .then(lines => Promise.all(lines.map(countPrimes)))
        .then(counts => console.log(counts))
        .catch(error => console.log(error));
};
```

现在创建两个文件，第一个是`numbers.txt`，每一行为有效值：

```text
100
1000
5000
```

第二个为`numbers-with-error.txt`，有一行不是有效数字：

```text
100
invalid text
5000
```

执行`countPrimesForEachLine()`：

```javascript
countPrimesForEachLine('numbers.txt');
countPrimesForEachLine('numbers-with-error.txt');
```

由于含有无效数字，一旦有promise抛出错误，则`all()`立刻停止，故先执行完毕：

```text
'invalid text' is not a number
[ 'Number of primes from 1 to 100 is 25',
'Number of primes from 1 to 1000 is 168',
'Number of primes from 1 to 5000 is 669' ]
```

## Async和Await

尽管promsie为我们带来了更好的异步编程体验，但其写法仍然与同步执行代码相去胜远。

`async`和`await`的出现使得同步和异步代码的写法具有了一致性。使用该功能有两个规则：

* 要想像同步函数一样编写异步函数，需要为异步函数加上`async`关键字
* 要想像调用同步函数一样调用异步函数，需要在调用前加上`await`关键字。且`await`关键字只能出现在`async`标注的函数内部

现在分别创建一个同步函数和异步函数：

```javascript
const computeSync = function(number) {
    if(number < 0) {
        throw new Error('no negative, please');
    }

    return number * 2;
};

const computeAsync = function(number) {
    if(number < 0) {
        return Promise.reject('no negative, please');
    }

    return Promise.resolve(number * 2);
};
```

接下来对之前的函数进行调用：

```javascript
const callComputeSync = function(number) {
    try {
        const result = computeSync(number);
        console.log(`Result is ${result}`);
    } catch(ex) {
        console.log(ex.message);
    }
}

const callComputeAsync = function(number) {
    computeAsync(number)
        .then(result => console.log(`Result is ${result}`))
        .catch(err => console.log(err));
}
```

我们发现两者的写法存在很大差异。如果用`async`和`await`呢？

```javascript
const callCompute = async function(number) {
    try {
        const result = await computeAsync(number);
        console.log(`Result is ${result}`);
    } catch(ex) {
        console.log(ex);
    }
}
```

这时与同步函数的写法几乎相同，带来了更加一直的编程体验。


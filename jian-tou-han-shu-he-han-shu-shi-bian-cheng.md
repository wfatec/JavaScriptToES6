# 箭头函数和函数式编程

## 从匿名函数到箭头函数

JS有三种定义函数的方式：

1. 命名函数

```javascript
function sqr(n) { return n * n; }
```

1. 匿名函数

```javascript
const sqr = function(n) { return n * n; };
```

1. 箭头函数

```javascript
const sqr = (n) => n * n;
```

箭头函数的出现主要可以用于替代匿名函数。无疑，箭头函数比匿名函数更加简洁，易于阅读。接下来将着重讨论箭头函数与匿名函数的一些区别。

### 去除括号

当参数只有一个时，可以省略括号：

```javascript
const greet = subject => console.log('Hello ' + subject);
```

### 多行箭头函数

多行箭头函数就不像单行是那样简洁了，需要给函数体加上花括号`{}`，每行语句或表达式末尾希望加入`;`。

```javascript
const factorial = (number) => {
    let product = 1;
    for(let i = 1; i <= number; i++) {
        product *= i;
    }
    return product;
};
```

### 使用Rest参数

箭头函数同样支持Rest参数：

```javascript
const greet =
    (message, ...subjects) => console.log(message + ' '+ subjects.join(', '));
greet('Hi', 'Developers', 'Geeks');
```

输出：`Hi Developers, Geeks`

### 使用默认参数

箭头函数同样支持默认参数：

```javascript
const power = (number, exp = 2) => Math.pow(number, exp);

console.log(power(4, 3));
console.log(power(4));
```

## 匿名函数VS箭头函数

事实上箭头函数相较于匿名函数，在语意上也存在较大差别，这些差别尤为值得关注。

### 词法作用域VS动态作用域

函数中的变量大多来源于参数或者局部定义，然而有些参数却是在外部定义的。举个例子：

```javascript
[1, 2, 3].map(function(e) { return e * 2; })
```

这里的变量`e`来源于输入的参数，现在加入一个变量：

```javascript
[1, 2, 3].map(function(e) { return e * factor; })
```

这里的`factor`既不是输入参数，也不是局部定义的变量，那它来自哪里呢？

有两种可能：

1. 函数所使用的变量定义时所在的作用域--这被称为词法作用域\(lexical scoping\)
2. 函数调用时所在的作用于--这被称为动态作用域\(dynamic scoping\)

大多编程语言青睐词法作用域，也有一些语言使用动态作用域。JS比较特殊--两者都有。这也是造成匿名函数出现错误的一个根源。

JS对所有非参数，非局部变量都使用词法作用域，`this`和`arguments`除外，而箭头函数则对所有参数和变量使用词法作用域。

### this和arguments词法作用域

举个例子来说明`this`的一些奇怪的行为：

```javascript
this.stuff = 'from lexical scope';
const someValue = 4;
const self = this;

setTimeout(function() {
    console.log('someValue is ' + someValue); //lexical scope for someValue
    console.log('this...' + this.stuff); //dynamic scope for this
    console.log('self...' + self.stuff); //lexical scope for self
}, 1000);
```

结果为:

```text
someValue is 4
this...undefined
self...from lexical scope
```

由于`this`和其他变量有着不同的作用域，编程人员通常需要使用`self`这样的变量来从外部作用域获取`this`。但是箭头函数不会改变`this`的作用域:

```javascript
setTimeout(() => {
    console.log('someValue is ' + someValue); //lexical scope for someValue
    console.log('this...' + this.stuff); //lexical scope for this
    console.log('self...' + self.stuff); //lexical scope for self
}, 1000);
```

这时结果完全正确：

```text
someValue is 4
this...from lexical scope
self...from lexical scope
```

接下来再举个例子说明`arguments`在两者之间的区别:

```javascript
Line    1 const create = function(message) {
        2   console.log('First argument for create: ' + arguments[0]);
        3   return function() {
        4       console.log('First argument seen by greet: ' + arguments[0]);
        5   };
        6 };
        7
        8 const greet = create('some value');
        9 greet('hi');
```

结果为：

```text
First argument for create: some value
First argument seen by greet: hi
```

现在用箭头函数来改造：

```javascript
const create = function(message) {
    console.log('First argument for create: ' + arguments[0]);
    return () => console.log('First argument seen by greet: ' + arguments[0]);
};

const greet = create('some value');
greet('hi');
```

这时结果为：

```text
First argument for create: some value
First argument seen by greet: some value
```

这时两个`arguments`都在同一个词法作用域中，因此结果相同。这就提醒我们，如果想使用`arguments`的动态特性，则仍使用匿名函数，或者直接使用Rest参数来代替`arguments`。

### bind,call,apply的区别

`bind()`函数对于绑定函数值和函数柯里化很有帮助，例如：

```javascript
const greet = function(message, name) {
    console.log(message + ' ' + name);
};

const sayHi = greet.bind(null, 'hi');

sayHi('Joe');
```

这里`greet()`函数已经柯里化，预先绑定了一个参数值，结果为`hi joe`。

事实上`bind()`还可以通过第一个参数绑定`this`，但在箭头函数中，由于`this`使用词法作用域，因此第一个参数会被忽略，具体形式为`anArrowFunc.bind(null, someinput)`。

如果函数依赖于`this`，`call`和`apply`函数可以有一定作用，但是对于箭头函数来说，使用`call`和`apply`就没什么意义了，我们应该尽量避免使用。

## 箭头函数的局限性

### 只能匿名

这似乎有些矛盾，但有时候能给匿名函数命名是有作用的，例如：

```javascript
setTimeout(function repeat(count) {
    console.log('called...');
    if(count > 1)
        setTimeout(repeat.bind(null, count - 1), 1000);
}.bind(null, 5), 1000);
```

这时函数作为`setTimeout`的一个参数，而对于需要递归调用的情况则非常有效。

当然，我们可以用命名函数达到同样的效果：

```javascript
const repeat = function repeat(count) {
    console.log('called...');
    if(count > 1)
        setTimeout(repeat.bind(null, count - 1), 1000);
};
setTimeout(repeat.bind(null, 5), 1000);
```

### 没有Constructor

函数可能被用作构造器，并通过`new`来调用并生成实例对象。

```javascript
//function Car(year) {
//or
const Car = function(year) {
    this.year = year;
};
```

这是我们可以这样生成实例：

```javascript
const car1 = new Car(2018);
```

而箭头函数不能作为构造器，试验一下：

```javascript
const Car = (year) => this.year = year;

const car1 = new Car(2018);
```

这时抛出错误：

```text
const car1 = new Car(2018);
             ^
TypeError: Car is not a constructor
```

### new.target是词法作用域

函数可以通过`new.target`来判断其作为一个构造函数被调用还是作为普通函数被调用：

```javascript
const f1 = function() {
    if(new.target) {
        console.log('called as a constructor');
    }
    else {
        console.log('called as a function');
    }
};
new f1();
f1();
```

输出：

```text
called as a constructor
called as a function
```

当使用箭头函数时：

```javascript
const arrow = () => {
    console.log(new.target);
};

arrow();
```

`new.target`值为`undefined`。

如果一个箭头函数在另一个函数内部被定义，箭头函数将得到所在函数的`new.target`属性。

```javascript
const outer = function() {
    return () => console.log(new.target);
};

const arrow1 = new outer();
const arrow2 = outer();

arrow1();
arrow2();
```

结果为：

```text
[Function: outer]
undefined
```

### 没有prototype属性

```javascript
const aFunc = function() {};
const anArrow = () => {};

console.log(aFunc.prototype);
console.log(anArrow.prototype);
```

输出：

```text
aFunc {}
undefined
```

### 无法变为Generators

```javascript
const primesStartingFrom = function*(start) {
    let index = start;
    while(true) {
        if(isPrime(index)) yield index;
        index++;
    }
};
```

此前的例子中我们实现了一个生成器，如果使用箭头函数，将无法实现：

```javascript
const primesStartingFrom = *(start) => { //Will not work
//...
```

抛出错误：

```text
const primesStartingFrom = *(start) => { //Will not work
                           ^
SyntaxError: Unexpected token *
```

### throw需要包裹

之前提到过我们可以这样定义单行箭头函数：

```javascript
const alwaysTrue = () => true;
```

但却不包括throw：

```javascript
const mapFunction = () => throw new Error('fail'); //BROKEN CODE
```

此时抛出错误：

```text
SyntaxError: Unexpected token throw
```

必须使用`{}`进行包裹：

```javascript
const madFunction = () => { throw new Error('fail'); };
```

### 注意返回对象字面量

当需要直接返回一个对象字面量时，可能会这么写：

```javascript
const createObject = (name) => { firstName: name };

console.log(createObject('George'));
```

但这里JS会将`{}`理解为语句块标识，而不反悔任何值，结果为`undefined`。这时可以通过`()`来告诉JS这是一个返回字段：

```javascript
const createObject = (name) => ({ firstName: name });

console.log(createObject('George'));
```

结果为:

```text
{ firstName: 'George' }
```

## 何时使用箭头函数

这里给出一些总结：

* 不要在class，对象字面量，或是`Object.prototype`中使用箭头函数定义方法。这里最大的问题就是`this`的词法作用域。如果一个方法用箭头函数定义，`this`将不是指向调用该方法的实例。
* 避免将多行箭头函数作为参数传递给一个函数。
* 在只有一行时，使用箭头函数。
* 在注册事件响应方法时，如果`this`需要使用动态作用域，不要使用箭头函数；反之，若需要词法作用域，则使用箭头函数。
* 使用单行箭头函数作为参数传递给函数。

## 箭头函数&函数式编程

举一个命令式编程的例子：

```javascript
const pickNamesInUpperCaseOfLength = function(names, length) {
    let result = '';

    for(let i = 0; i < names.length; i++) {
        if(names[i].length === length) {
            result += names[i].toUpperCase() + ', ';
        }
    }

    return result.substring(0, result.length - 2);
};
```

命令式编程有两个主要痛点：

* 包含可变性；变量`result`在迭代过程中会被改变
* 我们需要告诉它要做什么以及怎么做

我们可以通过函数式编程解决上述问题。

函数式编程使用高阶函数\(high-order functions\)，可以接受一个函数并返回一个新的函数。

JS提供了一些高阶函数，例如Array中的`filter()`和`map()`。重构上述函数：

```javascript
const pickNamesInUpperCaseOfLength = function(names, length) {
    return names.filter(function(name) { return name.length === length; })
        .map(function(name) { return name.toUpperCase(); })
        .join(', ');
};
```

这里还可以通过箭头函数加以优化：

```javascript
const pickNamesInUpperCaseOfLength = function(names, length) {
    return names.filter((name) => name.length === length)
        .map((name) => name.toUpperCase())
        .join(', ');
};
```

这时，我们的代码变得更加简洁和优雅。


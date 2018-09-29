# 变量和常量

ES6中一个非常重要概念就是常量和变量的区分，通过`let`和`const`取代之前的`var`，这是一大改进，我们应当尽量避免使用`var`。

## var的缺点

1. 无法阻止在作用域中被重定义
2. 没有会计作用域

### 重定义

在同一个作用域中多次定义同一个变量是一个很糟糕的实践，并经常会导致一些错误。举个例子：

```javascript
Line 1 'use strict';
2 var max = 100;
3 console.log(max);
4
5 var max = 200;
6 console.log(max);
```

在第5行中变量`max`已经存在，这是一个重复定义的语句，实际上如果想对一个已经存在的变量进行修改，应当不再对该变量进行声明。再来看一个例子：

```javascript
var a = 100;
function fn() {
    alert(a);   //undefined
    var a = 200;
    alert(a);   //200
}
fn();
alert(a);   //100
var a;
alert(a);    //100
var a = 300;
alert(a);   //300
```

前两个很简单，不解释 了，涉及到声明提前的问题。

后面仨为啥呢，这要总结下重复声明的问题： 1. 使用var语句多次声明一个变量不仅是合法的,而且也不会造成任何错误.

1. 如果重复使用的一个声明有一个初始值,那么它担当的不过是一个赋值语句的角色.
2. 如果重复使用的一个声明没有一个初始值,那么它不会对原来存在的变量有任何的影响.

如果一个函数有很多行，我们可能会在不经意间产生了变量的重复定义，而JS却不会为之抛出错误提示。并且这样的代码产生的效果往往令人难以理解，增加了阅读难度。

### 没有块级作用域

`var`只有在函数内部声明并使用时才具有块级作用域，这意味着在分支语句或是循环语句中，我们定义的`var`事实上是和外部处于同一个作用域。举个例子：

```javascript
'use strict';
console.log(message);
console.log('Entering loop');
for(var i = 0; i < 3; i++) {
console.log(message); //visible here, but undefined
var message = 'spill ' + i;
}
console.log('Exiting loop');
console.log(message);
```

结果为：

```text
undefined
Entering loop
undefined
spill 0
spill 1
Exiting loop
spill 2
```

结论：`var`**是糟糕的，不要使用它**

## 使用let

`let`是`var`的天然替代者，任何能用var实现的地方都能用let作为替代，切let去除了var中存在的一些顽疾。

### 无重复定义

`let`不允许在同一个作用于中重复定义，其行为类似于严格模式下的`var`。举个例子：

```javascript
'use strict';
//BROKEN_CODE
let max = 100;
console.log(max);
let max = 200;
console.log(max);
```

执行时会抛出如下错误：

```text
let max = 200;
    ^
SyntaxError: Identifier 'max' has already been declared
```

这为我们编写更健壮的程序提供了帮助。

### 块级作用域

使用`let`声明的变量具有块级作用域，这些变量只在定义时所在`{...}`内部有效，且只能在定义之后才能使用，不会出现变量提升。改造一下之前的例子：

```javascript
//console.log(message); //ERROR if this line is uncommented
console.log('Entering loop');
for(let i = 0; i < 3; i++) {
    //console.log(message); //ERROR if this line is uncommented
    let message = 'spill ' + i;
}
console.log('Exiting loop');
//console.log(message); //ERROR if this line is uncommented
```

以上代码充分说明了`let`相对于`var`语义上的区别。

## 使用const

`let`虽然能够防止重复定义，但却不能阻止被修改，如何定义一个不可更改的变量，也就是常量呢？

### const

`const`可用于定义一个常量，举个例子：

```javascript
//BROKEN CODE
'use strict';
let price = 120.25;
const tax = 0.825;
price = 110.12;
tax = 1.25;
```

结果会抛出一个错误：

```text
tax = 1.25;
    ^
TypeError: Assignment to constant variable.
```

### 走进const

尽管const能够定义一个常量，但其仍存在一定得局限性，它只能防止基本类型的数据或者对象的引用被更改，对于对象本身的更改却无能为力，举个例子：

```javascript
const max = 200;
const ok = true;
const nothing = undefined;
const nope = null;
const sam = { first: 'Sam', age: 2 };
//max = 200; //Not allowed
//ok = true; //Not allowed
//nothing = undefined; //Not allowed
//nope = null; //Not allowed
//sam = { first: 'Sam', age: 2 }; //Not allowed
sam.age = 3;
```

`sam.age = 3`可以顺利执行。

### 对象常量化

如何创建一个不可更改的常量对象呢？我们先看一个例子：

```javascript
//BROKEN CODE
const greet = 'dude';
console.log(greet);
greet[0] = 'r';
console.log(greet);
```

结果为：

```text
dude
dude
```

为什么这个对象没有被更改呢？到这里其实很多人知道了答案，这是一个string的实例，string对象在JS中是不可变类型。

JS会默认忽略不可变对象的更改，但不会抛出提示，如果使用`'use strict';`则会做出提示：

```javascript
//BROKEN CODE
'use strict';
const greet = 'dude';
console.log(greet);
greet[0] = 'r';
console.log(greet);
```

现在，当我们修改字符串实例时，会抛出错误

```text
greet[0] = 'r';
         ^

TypeError: Cannot assign to read only property '0' of string 'dude'
```

由于使用了const，greet的引用是不可变的，但是该实例也是不可变的。那有没有什么方法将我们自己的 实例设置为不可变类型呢？`freeze()`方法可以帮我们做到这一点。

```javascript
//BROKEN CODE
'use strict';
const sam = Object.freeze({ first: 'Sam', age: 2 });
//sam = {}; //ERROR, the reference sam is immutable
sam.age = 3;
console.log(sam.age);
```

输出为：

```text
sam.age = 3;
        ^
TypeError: Cannot assign to read only property 'age' of object '#<Object>'
```

似乎我们已经实现了不可变的需求，但需要注意的是，`freeze()`实现的是**浅冻结**，所以只有对象中最顶层的属性是不可变的，对于多层嵌套的对象，子属性依旧可以更改。

## 更安全的代码

由于`var`没有块级作用域，使得此前的开发者们经常使用**自执行函数**的设计模式。这个模式用于生成局部变量和函数，让外部不可见。

举个例子：

```javascript
//BROKEN CODE
'use strict';
var result = 0;
for(var i = 0; i < 5; i++) {
var sqrt = Math.sqrt(i);
    result += sqrt;
}
console.log(result);
console.log(sqrt); //sqrt is visible here, though not intended
```

为了避免内部函数被外部获取，我们通常会使用一个自执行函数包裹：

```javascript
//BROKEN CODE
'use strict';
var result = (function() {
    var result = 0;
    for(var i = 0; i < 5; i++) {
        var sqrt = Math.sqrt(i);
        result += sqrt;
    }
    return result;
})();
console.log(result);
console.log(sqrt); //ERROR because sqrt is not visible here,
//that's the desired behavior
```

这样的设计模式在ES6中将不再需要。

### 优先使用const

对于变量的定义有如下原则：

* 不要使用`var`
* 尽可能使用`const`
* 只在需要修改的情况下使用`let`

使用`const`有如下好处：

* 代码更少出错
* 代码可读性更强
* 阻止不可预料的更改
* 在使用函数形代码时更加安全


# Javascript陷阱

JS非常强大，但有时候也会给我们带来一些小惊喜，ES6本质上还是基于ES5实现的，因此一些历史残留问题依然存在，下面对这些"惊喜"进行一些梳理，让大家有一个清晰的认识，避免一些意外的问题。

## 换行需谨慎

事实上，绝大多数动态语言对于分号的使用都是一个可选项，但JS却不是这样，并且对于JS来说，有些地方的分号是建议省略，而有些地方却是必须的，而这些必须加入分号的地方若是没有出现分号，JS也不会报错。

为了避免这些问题，我们首先需要理解JS的**自动分号插入(ASI)**规则。

一个有效的程序以一个`;`结尾，如果给定的脚本最后没有`;`，则JS会自动插入一个`;`。

由于是从左向右解析，如果遇到一个意料之外的符号，且一个换行符将其与之前的符号分割开，这时就会自动在这个意外的符号之前插入`;`。举个例子：

```js
//BROKEN CODE
const unexpected = function() {
    let first
    second = 1;
    console.log(first);
    console.log(second);
}
unexpected();
console.log(second);
```

代码中符号`second`不应该出现在`first`之后，因此当出现换行时，JS自动在`first`之后插入了`;`。这时`second`就成了全局变量，结果输出为:

```
undefined
1
1
```

如果候选符号是`break,continue,return,throw,yield`，并且在候选符号和后续符号之间有一个换行符，这是JS也会自动在候选符号后插入`;`。举个例子：

```js
//BROKEN CODE
const compute = function(number) {
    if(number > 5) {
        return number
        + 2;
    }

    if(number > 2) {
        return
        number * 2; 
    }
};

console.log(compute(6));
console.log(compute(3));
```

由于第二个`return`后面跟着的是换行符，JS会在其后面自动插入`;`，因此最终返回结果为：

```
8
undefined
```

再来看一下第一个`return`，尽管这一行也没有`;`，但是`+`跟在`number`后面是合法的，因此不会自动在`number`之后插入`;`。如果将`+ 2`改为`2`，那么`2`在`number`之后就是不合法的，JS就会自动插入`;`，结果为`6`而不是抛出错误。

如果一行相对较短，可以一个清晰的分号作为结尾。此外，按照惯例，我们不会在`}`之后加`;`。如果一行很长，则需要分为多行，这是就需要对自动插入分号的行为多加注意。

## 使用===

使用===替代==是一个老生常谈的问题，这个问题ES6也依旧存在，来看个例子：

```js
//BROKEN CODE
const a = '1';
const b = 1;
const c = '1.0';
console.log(a == b);
console.log(b == c);
console.log(a == c);
```

由于==在进行比较时，会自动进行类型强制转换，数字和字符串比较时，会将字符串强制转换为数字再进行比较，因此结果为:

```
true
true
false
```

由于这些隐式转换，会让代码的可读性变差，同时也提高了bug的风险，因此在绝大多数情况下建议使用===来代替==。

## 使用前请声明

在JS中，未声明的变量不会报错，而是会默认复制到全局对象中，这会带来污染全局对象的风险，此外也会导致一些意外的bug。举个例子：

```js
//BROKEN CODE
const oops = function() {
    haha = 2;
    onsole.log(haha);
};

oops();
console.log(haha);
```

输出为：

```
2
2
```

就是由于`haha`未声明，所以挂载到了全局对象上，修改为`let haha = 2`即可避免上述问题。

再来看个例子:

```js
//BROKEN CODE
const outer = function() {
    for(i = 1; i <= 3; i++) {
        inner();
    }
};
const inner = function() {
    for(i = 1; i <= 5; i++) {
        console.log(i);
    }
};
outer();
```

结果只输出一组

```
1
2
3
4
5
```

修改为

```js
const outer = function() {
    for(let i = 1; i <= 3; i++) {
        inner();
    }
};
const inner = function() {
    for(let i = 1; i <= 5; i++) {
        console.log(i);
    }
};
outer();
```

此时成功打印三次。

## 使用严格模式

使用严格模式可以在编译时进行语法检查，对于变量未声明等情况会抛出错误提示，举个例子：

```js
//BROKEN CODE
'use strict';
const oops = function() {
    haha = 2;
    console.log(haha);
};
oops();
console.log(haha);
```

这是会在控制台抛出如下错误：

```
haha = 2;
     ^

ReferenceError: haha is not defined
```

这会极大降低代码出现未知错误的风险。
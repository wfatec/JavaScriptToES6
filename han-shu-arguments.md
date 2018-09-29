# 函数参数

本章将回顾一下`arguments`及其强大之处和存在的问题

## arguments的优缺点

看一个例子：

```js
    const max = function(a, b) {
    if (a > b) {
        return a;
    }
    return b;
};
console.log(max(1, 3));
console.log(max(4, 2));
console.log(max(2, 7, 1));
```

虽然我们的函数只定义了两个参数，但如果传入三个参数，一样可以得出结果：

```js
3
4
7
```

如果传入的参数多于定义的参数，则多余部分将会被忽略。

所有入参可以在函数内部通过`arguments`获取，举例说明其用法：

```js
const max = function() {
    console.log(arguments instanceof Array);
    let large = arguments[0];
    for(let i = 0; i < arguments.length; i++) {
        if(arguments[i] > large) {
            large = arguments[i];
        }
    }
    return large;
};
console.log(max(2, 1, 7, 4));
```

该版本的`max()`函数没有明确定义入参，此时对于入参的数量没有限定，输出结果为：

```
false
7
```

尽管`arguments`被广泛用于JS中，但仍有很多问题：

- 方法无法传递出清晰的意图--更重要的是会造成误导。看起来函数没有出现任何参数，但却在执行过程中进行了使用。
- `arguments`是一个类数组对象--它用起来类似数组，但仅仅只是表面上。
- 代码无法向使用Array那样优雅的编写。

## 使用Rest参数

Rest参数可以使用{...}来进行占位，且Rest参数的数据类型是Array。将此前的`max()`函数进行改造：

```js
const max = function(...values) {
    console.log(values instanceof Array);
    let large = values[0];
    for(let i = 0; i < values.length; i++) {
        if(values[i] > large) {
            large = values[i];
        }
    }
    return large;
};
console.log(max(2, 1, 7, 4));
```

此时`values`是一个数组，结果为：

```
true
7
```

这意味着我们可以使用一些Array特有的方法进行优化：

```js
const max = function(...values) {
    return values.reduce((large, e) => large > e ? large : e, values[0]);
};
```

这时，我们的代码显得优雅了很多。

JS对于Rest参数有一些合理的规则需要注意：

- rest参数必须在参数的最后。
- 函数参数中最多只能有一个rest参数。
- rest参数中仅包含未明确定义的参数。

## 解构操作

解构操作有点类似于Rest参数，都是使用`{...}`作为操作符号，但解构操作主要出现在函数调用的时候。

已知一个`greet`函数：

```js
const greet = function(...names) {
    console.log('hello ' + names.join(', '));
};
```

如果有两个独立的参数，可以这样传递：

```js
const jack = 'Jack';
const jill = 'Jill';
greet(jack, jill);
```

如果参数在一个数组中，可以这样：

```js
const tj = ['Tom', 'Jerry'];
greet(tj[0], tj[1]);
```

虽然可以使用，但不够优雅，这是可以使用解构操作：

```js
greet(...tj);
```

解构操作可以在任意可迭代的对象中使用。

解构操作的出现让`applay()`函数不在需要：

```js
greet.apply(null, tj); //no more stinky null
```

解构操作还能将一个数组解构赋值到离散的参数中：

```js
const names1 = ['Laurel', 'Hardy', 'Todd'];
const names2 = ['Rock'];
const sayHello = function(name1, name2) {
    console.log('hello ' + name1 + ' and ' + name2);
};
sayHello(...names1);
sayHello(...names2);
```

入参中多余数量的参数同样会被忽略。若入参数量少于函数定义的参数数量，则剩余部分赋值为`undefined`.

我们同样可以将解构操作和离散参数组合使用：

```js
const mixed = function(name1, name2, ...names) {
    console.log('name1: ' + name1);
    console.log('name2: ' + name2);
    console.log('names: ' + names);
};
mixed('Tom', ...['Jerry', 'Tyke', 'Spike']);
```

结果为：

```
name1: Tom
name2: Jerry
names: Tyke,Spike
```

applay()函数只能用于函数调用，对于构造函数却无能为力，而解构操作却没有这些限制：

```js
const patternAndFlags = ['r', 'i'];
const regExp = new RegExp(...patternAndFlags);
```

解构赋值同样可以用在复制，连接和操作数组：

```js
const names1 = ['Tom', 'Jerry'];
const names2 = ['Butch', 'Spike', 'Tyke'];
console.log([...names1, 'Brooke']);
console.log([...names1, ...names2]);
console.log([...names2, 'Meathead', ...names1]);
```

结果为：

```
[ 'Tom', 'Jerry', 'Brooke' ]
[ 'Tom', 'Jerry', 'Butch', 'Spike', 'Tyke' ]
[ 'Butch', 'Spike', 'Tyke', 'Meathead', 'Tom', 'Jerry' ]
```

解构操作还有一个令人惊艳的功能，它可以用于复制对象的内容并可以选择增加新的属性或内容。

```js
const sam = { name: 'Sam', age: 2 };
console.log(sam);
console.log({...sam, age: 3});
console.log({...sam, age: 4, height: 100 });
console.log(sam);
```

输出：

```
{ name: 'Sam', age: 2 }
{ name: 'Sam', age: 3 }
{ name: 'Sam', age: 4, height: 100 }
{ name: 'Sam', age: 2 }
```

除了更加优雅和简洁外，解构操作的引入使得代码获得了更高的扩展性。

## 定义参数默认值

我们可以通过如下三种方式从默认参数中获益：

- 作为函数的使用者，我们不必额外传入和默认值一样的参数值。
- 作为函数的作者，可以更自由的对函数进行升级，而不用影响既存代码。
- 我们可以抵消JS中没有函数重载的缺陷。

定义一个函数用于对书籍数组进行排序：

```js
const sortByTitle = function(books) {
    const byTitle = function(book1, book2) {
        return book1.title.localeCompare(book2.title);
    };
    return books.slice().sort(byTitle);
};
```

这里不直接使用`sort()`而是先使用`slice()`是因为这会改变原始数组的排序--**更改函数输入的原始参数是一种糟糕的程序实践**。`sort()`函数对输入数组进行了复制，因此不会影响原始输入。

输入参数如下：

```js
const books = [
    { title: 'Who Moved My Cheese' },
    { title: 'Great Expectations' },
    { title: 'The Power of Positive Thinking' }
];
console.log(sortByTitle(books));
```

输出为:

```
[ { title: 'Great Expectations' },
    { title: 'The Power of Positive Thinking' },
    { title: 'Who Moved My Cheese' } ]
```

现在，设想一下又有一个新的需求，需要用新的排序规则进行排序，这时我们应该怎么办呢？再定义一个函数？显然有些过于繁琐。再增加一个参数？但这可能会与已存在的代码发生冲突。

技术上讲，如果直接新增加一个额外的参数，已有的代码将不会受到影响--至少不会立即受到影响。当调用函数时，新加入的参数未收到对应入参，将默认为`undefined`，然后函数内部对这个值的类型进行判断来确定执行逻辑。这样的方法可以实现，但同样太过繁杂。最好的方式是：**默认参数**。

用默认值重新改造：

```js
const sortByTitle = function(books, ascending = true) {
    const multiplier = ascending ? 1 : -1;
    const byTitle = function(book1, book2) {
        return book1.title.localeCompare(book2.title) * multiplier;
    };
    return books.slice().sort(byTitle);
};

console.log(sortByTitle(books));
console.log(sortByTitle(books, false));
```

输出为：

```
[ { title: 'Great Expectations' },
{ title: 'The Power of Positive Thinking' },
{ title: 'Who Moved My Cheese' } ]
[ { title: 'Who Moved My Cheese' },
{ title: 'The Power of Positive Thinking' },
{ title: 'Great Expectations' } ]
```

### 多默认值

一个函数可以有任意多个默认参数。例如：

```js
const fetchData = function(
    id,
    location = { host: 'localhost', port: 443 },
    uri = 'employees') {
    console.log('Fetch data from https://' +
        location.host + ':' + location.port + '/' + uri);
};
```

上面的代码中，后两个参数均有默认参数值，调用方法可以是：

```js
fetchData(1, { host: 'agiledeveloper', port: 404 }, 'books');
fetchData(1, { host: 'agiledeveloper', port: 404 });
fetchData(2);
```

### 传递undefined

设想一个问题：若上面的`fetchData()`函数调用时，只想传入`uri`，而对于`location`则想使用其默认值，这是该怎么做呢？

这是就需要在对应位置传入`undefined`，规则如下：

- 若有效值传入默认参数，则使用该传入值。

- 若传入`null`，则该参数的值为`null`。

- 若传入`undefined`，则使用默认值进行替换。

根据上述规则，可以按如下方式调用：

```js
fetchData(3, undefined, 'books');
```

### 表达式作为默认值

默认值不止可以设置为字面量，还可以是一个表达式：

```js
const fileTax = function(papers, dateOfFiling = new Date()) {
    console.log('dateOfFiling: ' + dateOfFiling.getFullYear());
};

fileTax('stuff', new Date('2016-12-31'));
fileTax('stuff');
```

结果为：

```
dateOfFiling: 2016
dateOfFiling: 2018
```

表达式计算默认值时，可能会用到左边的参数值：

```js
const computeTax = function(amount,
    stateTax = 15, localTax = stateTax * .10) {
    console.log('stateTax: ' + stateTax + ' localTax: ' + localTax);
};

computeTax(100, 10, 2);
computeTax(100, 10);
computeTax(100);
```

结果为:

```
stateTax: 10 localTax: 2
stateTax: 10 localTax: 1
stateTax: 15 localTax: 1.5
```

**不要让参数表达式使用右侧参数**，将

```js
const computeTax = function(amount,
    stateTax = 15, localTax = stateTax * .10) {
```

修改为：

```js
const computeTax = function(amount,
    stateTax = localTax * 10, localTax = stateTax * .10) {
```

这时前两个调用不会报错，但最后一个调用会抛出如下错误：

```
stateTax: 10 localTax: 2
stateTax: 10 localTax: 1
...
stateTax = localTax * 10, localTax = stateTax * .10) {
            ^
ReferenceError: localTax is not defined
```

### 默认值参数和Rest参数的相互作用

Rest参数有一些规则需要遵守：

- 最多有一个Rest参数
- Rest参数必须在参数列表的最后

当默认值参数和Rest参数同时使用时会发生什么呢？来看个栗子：

```js
const product = function(first, second = 1, ...moreValues) {
    console.log(first + ', ' + second + ', length:' + moreValues.length); 
};
```

上面的函数有一个required参数，一个default参数和一个Rest参数，由于Rest参数必须出现在最后，尽管这时第二个参数second事实上是无需传入的，但却必须用`undefined`来占位。

这是可能会想是否可以给Rest参数赋予默认值呢？我们来尝试一下：

```js
//BROKEN CODE const notAllowed = function(first, second, ...moreValues = [1, 2, 3]) {}

If we do not provide any values for the rest parameter, then we want it to assume the values [1, 2, 3]. And JavaScript says:

const notAllowed = function(first, second, ...moreValues = [1, 2, 3]) {} 
                                                         ^

SyntaxError: Rest parameter may not have a default initializer
```

这时JS会抛出错误，也就是说Rest参数在未传递参数时，会默认是一个空数组，而不是使用默认值代替。
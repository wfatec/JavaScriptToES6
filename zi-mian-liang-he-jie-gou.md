# 字面量和解构

## 使用模板语法

对于字符串和字符串变量的组合，传统的做法是通过`+`号连接，

```javascript
const name1 = 'Jack';
const name2 = 'Jill';

console.log('Hello ' + name1 + ' and ' + name2);
```

但是这样显得多余繁琐和难以阅读。

### 模板语法

JS使用反引号来表示模板字符串：

```javascript
console.log(`Hello ${name1} and ${name2}`);
```

输出：

```text
Hello Jack and Jill
```

`${`会被认为开始模板语法，将后续`}`前的语句看作表达式：

```javascript
const price = 1;

console.log(`The price of a { symbol is $${price * 0.01 }.`);
```

输出

```text
The price of a { symbol is $0.01.
```

### const,let和模板语法

之前都是用`const`声明模板中的变量，我们同样可以使用`let`，不过需要格外小心：

```javascript
let value = 4;

const msg1 = `The value is ${value}`;
const print = () => `The value is ${value}`;

value = 0;

console.log(msg1);
console.log(print());
```

结果为：

```text
The value is 4
The value is 0
```

### 模板语法嵌套

模板语法同样可以嵌套使用：

```javascript
const hours = 14;
const event = 'meeting';

console.log(`The ${event} will happen ${hours < 12 ? 'in the morning' :
    `later in the day, in the ${hours < 20 ? 'evening' : 'night'}`}.`);
```

输出：

```text
The meeting will happen later in the day, in the evening.
```

在使用嵌套的模板语法时，需要考虑代码是否更易阅读，如果答案是不易阅读，则将嵌套部分抽离出来替换为独立的函数：

```javascript
const when = (hrs) =>
    hrs < 12 ? 'in the morning' :
        `later in the day, in the ${hrs < 20 ? 'evening' : 'night'}`;

console.log(`The ${event} will happen ${when(hours)}.`);
```

## 多行字符串

模板语法可以简洁的创建多行字符串而无须多次拼接：

```javascript
const name = 'John Doe';

const message = `Dear ${name},
We're delighted to let you know that you have been included in
our routine spam starting with this one.

    You can thank us later.
`;

console.log(message);
```

输出：

```text
Dear John Doe,
We're delighted to let you know that you have been included in
our routine spam starting with this one.

    You can thank us later.
```

多行字符串会保留缩进，这一点需要注意。

## 标记模板

目前为止我们接触的都是未标记的模板语法，但是我们可以在模板语法钱加上标记。

在学会使用标记模板前，让我们使用一个内置标记模板函数`raw()`。先看个例子：

```javascript
console.log('some special characters: \\ \\n \\b \'');
```

输出为

```text
some special characters: \ \n \b '
```

字符串将所有特殊字符输出了，但需要在每个特殊字符钱加入`\`，再看去除`\`的情况：

```javascript
console.log("some special characters: \ \n \b '");
```

输出为：

```text
some special characters:
    '
```

显然无法输出特殊字符。但每次加上`\`过于繁琐，这时可以使用`String`类的`raw()`方法：

```javascript
console.log(String.raw`some special characters: \ \n \b '`);
```

尽管tag写作一个函数，但我们无需像函数那样去调用，而是直接将之放到模板语法前面，且**不要加上括号**。

输出为：

```text
some special characters: \ \n \b '
```

`raw`标记对于从模板中获取原始字符串非常有效。标记对将模板进行特殊处理非常有用，它并不一定需要返回字符串，返回值可以是字符串，对象或者什么都不返回。

那么如何创建一个标签语法呢？

```javascript
const printDetails = function(texts, ...expressions) {
    console.log(texts);
    console.log(expressions);
};

const name = 'John';
printDetails`Hello ${name}, how are you?`;
```

`printDetails()`函数有两个参数。`text`是模板中所有字符串字面量所组成的数组。`expressions`则是所有表达式的数组。当`printDetails()`作为模板语法的标记时，`text`数组将有两个字符串：表达式之前和表达式之后。`expression`数组则包含一个值：模板语法中表达式执行的结果，在本例中为`'John'`。`printDetails()`函数不反悔任何结果，这没什么问题。这里的执行结果为：

```text
[ 'Hello ', ', how are you?' ]
[ 'John' ]
```

这里需要注意的是`text`**数组永远比**`expression`**数组多一个元素**。

标记还可用于对模板进行转换：

```javascript
const mask = function(texts, ...expressions) {

    const createMask = (text) => '*'.repeat(text.length);

    const maskedText = expressions
        .map((expression, index) =>
            `${texts[index]}${createMask(expression.toString())}`)
        .join('');

    const closingText = texts[texts.length - 1];

    return `${maskedText}${closingText}`;
};

const agent = 'Bond';
const organization = 'MI6';

console.log(mask`Hi, I'm ${agent}, with ${organization}.`);
```

输出为：

```text
Hi, I'm ****, with ***.
```

由于标记可以将模板转换为多种表示方式，因此其应用的可能性是无穷无尽的。

## 增强的对象字面量

从已有数据中创建对象是一个常见问题，传统的写法非常的繁琐：

```javascript
const createPerson = function(name, age, sport, sportFn) {
    const person = {
        name: name,
        age: age,
        toString: function() {
            return this.name + ' ' + this.age;
        }
    };

    person['play' + sport] = sportFn;

    return person;
};

const sam =
    createPerson('Sam', 21, 'Soccer',
        function() { console.log(`${this.name}, kick, don't touch`); });

console.log(sam.name);
console.log(sam.toString());
sam.playSoccer();
```

输出：

```text
Sam
Sam 21
Sam, kick, don't touch
```

### 属性简写

之前的例子中通过`name:name`来对属性赋值，现在可以进行简化：

```javascript
const createPerson = function(name, age, sport, sportFn) {
    return {
        name,
        age,
```

### 方法简写

`toString`方法可以简写为：

```javascript
toString() {
    return `${this.name} ${this.age}`;
},
```

### 对象字面量中的计算属性

计算属性，如`playSoccer`，它的属性名是基于一个变量值计算得到的。我们可以这样改造：

```javascript
[`play${sport}`] : sportFn
```

## 解构

解构是从数组和对象中抽离数据的优雅方法。它去除了过多且重复的`index`操作的使用。

### 数组解构

函数只能返回一个数值：基本类型或是一个对象。除了返回数组外并没有一个优雅的方法来返回多个值。这让函数内部的代码容易编写，但是却让接收方难以优雅的处理。

这里是一个函数，它返回一个数组：

```javascript
const getPresidentName = function(number) {
    //implemented only for number 6
    return ['John', 'Quincy', 'Adams'];
};
```

要想使用这个返回的数组需要这样：

```javascript
const president6 = getPresidentName(6);
const firstName = president6[0];
const lastName = president6[2];
```

可以看到必须通过index来索引并使用数组中的值，有没有什么方法能更简洁的获取数组内部的值呢？

#### 提取数组元素

让我们通过解构赋值的方式重构上述代码：

```javascript
const [firstName, middleName, lastName] = getPresidentName(6);
```

这里我们直接将数组元素赋值到具体变量中。

#### 忽略元素值

如果你只关心数组的第一个值，可以像这样：

```javascript
const [firstName] = getPresidentName(6);
```

数组中剩余的元素值将会被忽略，如果想忽略`middleName`，可以像这样：

```javascript
const [firstName,, lastName] = getPresidentName(6);
```

#### 提取数组有效值之外的数值

JS并不会对这种情况抛出错误：

```javascript
const [firstName,, lastName, nickName] = getPresidentName(6);
console.log(nickName);
```

这时`nickName`将赋值为`undefined`。

#### 提供默认值

在所抽离的元素值为`undefined`时，可以使用默认值：

```javascript
const [firstName,, lastName, nickName='Old Man Eloquent'] =
    getPresidentName(6);

console.log(nickName);
```

这时，`nickName`值为"Old Man Eloquent"。

#### Rest提取

我们同样可以将剩余元素值放入一个数组中：

```javascript
const [firstName, ...otherParts] = getPresidentName(6);
```

`otherParts`值为：\['Quincy', 'Adams'\]。

#### 数据交换

我们可以使用解构特性来进行数据交换

```javascript
let [a, b] = [1, 2];
console.log(`a=${a} b=${b}`);
[a, b] = [b, a];
console.log(`a=${a} b=${b}`);
```

#### 提取参数值

```javascript
const printFirstAndLastOnly = function([first,, last]) {
    console.log(`first ${first} last ${last}`);
};

printFirstAndLastOnly(['John', 'Q', 'Adams']);
```

### 对象解构

首先定义一个对象：

```javascript
const weight = 'WeightKG';

const sam = {
    name: 'Sam',
    age: 2,
    height: 110,
    address: { street: '404 Missing St.'},
    shipping: { street: '500 NoName St.'},
    [weight]: 15,
    [Symbol.for('favoriteColor')]: 'Orange',
};
```

现在，我们来提取具体属性值。如果我们只想获取某些属性，可以这样：

```javascript
const firstName = sam.name;
const theAge = sam.age;
```

#### 解构对象

与解构数组类似，直接上代码：

```javascript
const { name: firstName, age: theAge } = sam;
```

这里将`name`属性中的值赋值给`firstName`，将`age`中的值赋值给变量`theAge`。我们可以不把它看成是一个数值提取操作，而是看作是一种**模式匹配**。

设想如果有一个表达式`{ a: 1, b: X, c: 3 } = { a: 1, b: 22, c: 3 }`，如果让你推断一下`X`的值是多少，答案将是22。因为两边的每个属性都有相同的名字，我们通过比较，判定X的值必然和右边b的值相同。现在再来看一下以前的的代码：

```javascript
const { name: firstName, age: theAge } = { name: 'Sam', age: 2, height: 110 };
```

可以更好的理解这一现象。

#### 提取到具有相同名称的变量

```javascript
const { name, age: theAge：theAge } = sam;
```

`theAge`的属性名和变量名相同，可以简写为:

```javascript
const { name, age: theAge } = sam;
```

#### 提取计算属性

```javascript
const { [weight]: wt, [Symbol.for('favoriteColor')]: favColor } = sam;
```

#### 设置默认值

```javascript
const { lat, lon, favorite = true} = {lat: 84.45, lon: -114.12};
```

#### 函数入参的提取

先看个例子：

```javascript
const printInfo = function(person) {
    console.log(`${person.name} is ${person.age} years old`);
};

printInfo(sam);
```

这是一个传统的写法，大家都很熟悉，但是通过解构，我们可以让代码更简洁：

```javascript
const printInfo = function({name: theName, age: theAge}) {
    console.log(`${theName} is ${theAge} years old`);
};

printInfo(sam);
```

如果让局部变量和参数名相同，可以最终简化为：

```javascript
const printInfo = function({name, age}) {
    console.log(`${name} is ${age} years old`);
};
```

#### 深度解构

目前为止，我们提取的都是对象的顶层属性，解构语法还能让我们轻松的提取更加底层的属性值：

```javascript
const { name, address: { street } } = sam;
```

注意，这里我们只定义了两个变量`name`和`street`，任何试图获取`adress`都将导致"variable not defined"的错误。

#### 冲突处理

如果想同时获取`shipping`和`address`中的`street`属性，该如何避免冲突呢？只需采用不同的变量名即可：

```javascript
const { name, address: { street }, shipping: { street: shipStreet } } = sam;
```

#### 提取到已存在的变量

此前，我们通过`[existingVariable] = array`语法将数组中的值赋值给了一个已存在的变量，我们理所当然的会写下下面的代码：

```javascript
let theName = '--';
{ name: theName } = sam;
```

但是执行后发现会抛出一个错误：

```javascript
{ name: theName } = sam;
                  ^

SyntaxError: Unexpected token =
```

这里JS无法理解这个赋值操作，它看起来像是一个JS对象或是一个代码区块。

不用担心，我们可以这样做：

```javascript
let theName = '--';
({ name: theName } = sam);
```

我们将提取操作的代码放到一对`()`中，分号需要放到括号的外面。

#### 用...提取

有时候，我们需要复制整个对象，同时还可能会新增一些属性，或是修改已有的属性。解构可以很好的满足这些需求。

先来看一个传统的做法：

```javascript
const addAge = function(person, theAge) {
    return {first: person.first, last: person.last, age: theAge };
};

const parker = { first: 'Peter', last: 'Parker' };
```

输出为：

```text
{ first: 'Peter', last: 'Parker', age: 15 }
```

可以看到整个过程非常繁琐，且缺少灵活性，例如修改一下`person`实例：

```javascript
const parker = { first: 'Peter', last: 'Parker',
    email: 'spiderman@superheroes.example.com' };

console.log(addAge(parker, 15));
```

输出还是：

```text
{ first: 'Peter', last: 'Parker', age: 15 }
```

新加入的属性未能打印出来，这时，通过解构语法中的`...`操作符可以很好的解决这一问题：

```javascript
const addAge = function(person, theAge) {
    return {...person, last: person.last.toUpperCase(), age: theAge };
}

const parker = { first: 'Peter', last: 'Parker',
    email: 'spiderman@superheroes.example.com' };

console.log(addAge(parker, 15));
```


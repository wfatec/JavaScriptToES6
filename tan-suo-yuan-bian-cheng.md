# 探索元编程

元编程是在运行时扩展程序的一个途径，它是一种通过编写代码来产生新的代码的能力。它是JS最为复杂以及最新和最强大的功能。

元编程有两种情况：成员注入以及成员合成。成员注入将在本章进行讨论，用于向已存在的类增加已知的方法。成员合成将在下一章进行讨论，用于基于当前对象的状态动态创建方法和属性。

## 强大的元编程及其风险

当使用第三方的类时，如果你说过：“让这个类拥有某个自定义的方法会很酷”，那么你可以使用元编程来实现这个愿望。

一般来说，动态类型的语言由于它们分发方法时，没有严格的类型检查，因此提供了更好的元编程能力。

仅仅只是动态语言还不够，语言还需要为元编程提供特殊的工具，最好的例子就是JS。尽管这门语言在创建之初就是动态类型的，但是直到最近，它才提供了必要的工具来充分实现元编程。

### 注入 vs. 合成

元编程带来了两个概念：注入\(injection\)和合成\(synthesis\)。前者比较简单，并且JS从一开始就有这种能力。后者更加复杂也更加强大，直到最近JS才具备这样的能力。

注入是一种可以向一个类中增加或替换特定的方法或属性的技术。设想一下你想知道一个指定日期是否是闰年。你当然可以从date对象中提取其年份，然后传递到一个工具方法来告诉你给定年份是否为闰年。但是，如果我们能够使用`givenDate.isInLeapYear()`，那么显然会让问题更加简洁。而无需获取`Date`类的源码即可实现这个案例的能力，即元编程，更具体来说就是成员注入。

合成比注入具有更强的动态性，我们可以称之为成熟的元编程，它具有更强的成熟性和实践性。设想`Employee`是一个类，表示数据库中的雇员数据。该数据具有很强的流动性，例如，每个雇员可能有一些属性：`firstName`,`secondName`,`corporateCreditCard`等等。在写代码的时候我们不知道会有那些属性，随着系统的升级，数据库中某些属性可能删除，某些属性有可能新增。然而，使用`Employee`类的程序员可能想些一些方法，例如：`Employee.findThoseWithFirstName('Sara')`或者`Employee.findThoseWithCorporateCreditCard('xxxx-xxxx-xxxx-1234')`。在将来，当一个名为`costCenter`的新属性增加进来时，`Employee`类的使用者邮箱实现`Employee.findThoseWithCostCenter(...)`。

这些`findThose...`方法无法确定在某个时间段存在。但是，当一个以`findThoseWith`开头的方法被调用时，方便起见，我们可能会希望合成它，或是动态创建代码来查询`findThoseWith`跟随的字段。

### 元编程的风险

元编程对于改变对象和类的结构具有极其强大的能力，所以在使用时需要小心谨慎。当在调用的实例中存在一些新的以及含义不明的方法调用时，你可能会变得很沮丧，例如`Date`类。更有甚者，元编程可能导致一些动态行为，并导致代码出现bug。

记住一个Voltaire的一句名言：“能力越大，责任越大”。当时用元编程时：

* 尽量少用，且只在绝对必要时使用。
* 不要随意的在代码中使用注入或是合成方法。更好的构建自己的应用，让开发者能够在特定的位置找到和注入及合成相关的代码。当开发者发现一段不熟悉的方法调用时，能够更轻松的定位与元编程无关的代码。
* 全面的代码检查。找一个同事来检查你的代码，多双眼睛的审视能够减少风险。
* 严格的自动测试。

## 动态获取

当明确知道成员名称时，我们可以使用点语法，例如`sam.age`或者`sam.play()`来获取属性和方法。如果直到运行时才能知道成员名称，则可以使用`[]`语法，例如`sam[fieldName]`或`sam[methodName]()`。

当使用\[\]时，尽量使用变量名，若直接使用字符串，转义工具以及代码压缩工具可能会将成员进行重命名，若\[\]中的名称和实际属性名不同，则可能会抛出错误。

如果对找出`instance`实例中的所有成员感兴趣，可以使用`Object.keys(instance)`方法。之所以将方法名定为`keys`，是由于JS将对象看作是哈希表。或者，你可以使用`for member in instance`来遍历所有成员。让我们看一个实例：

```javascript
class Person {
    constructor(age) {
        this.age = age;
    }

    play() { console.log(`The ${this.age} year old is playing`); }

    get years() { return this.age; }
}

const sam = new Person(2);

console.log(sam.age);
sam.play();

const fieldName = 'age';
const methodName = 'play';

console.log(sam[fieldName]);
sam[methodName]();

console.log(`Members of sam: ${Object.keys(sam)}`);

for(const property in sam) {
    console.log(`Property: ${property} value: ${sam[property]}`);
}
```

结果为：

```text
2
The 2 year old is playing
2
The 2 year old is playing
Members of sam: age
Property: age value: 2
```

尽管`age`字段被`keys`展示出来，但是`constructor()`,`play()`方法以及`years`属性都未能显示出来。这是因为这些属性或方法并不是该对象本身的一部分，而是保存在对象的原型上。让我们使用`Object`的`getOwnPropertyName()`方法来查询原型：

```javascript
console.log(Object.getOwnPropertyNames(Reflect.getPrototypeOf(sam)));
```

`getOwnPropertyName()`方法获取给定对象的所有字段，属性和方法\(`hasOwnProperty()`获取对象的可枚举属性和方法，注意区别\)，结果为：

```text
[ 'constructor', 'play', 'years' ]
```

拥有动态获取并迭代对象成员的能力，我们可以在运行时研究任何对象，这和在Java和C\#中使用的反射机制非常类似。

## 成员注入

有时候我们希望创建一个类或对象中原本不存在的成员，这时就需要用到成员注入。首先我们将研究如何想一个实例注入一个成员，然后再研究怎样向一个类注入成员。

### 向实例注入方法

我们来对一个`String`类的实例对象进行注入。通常我们不会用`new`来创建一个字符串，可能会用`const text = 'live';`来代替`const text = new String('live');`。但是**基本类型的字符串不允许注入属性**。因此，这里我们使用`new`。稍后我们将学习如何通过方法注入让基本类型的字符串也能生效。

假设我们希望反转一个字符串，来检查给定字符串是否是一个回文：

```javascript
const text = new String('live');

try {
    text.reverse();
} catch(ex) {
    console.log(ex.message);
}
```

此时并没有`reverse()`方法，因此抛出错误：

```text
text.reverse is not a function
```

在实例中注入方法非常简单，直接将函数赋值给任意喜欢的属性名:

```javascript
text.reverse = function() { return this.split('').reverse().join(''); };

console.log(text.reverse());
```

结果为：

```text
evil
```

此时，我们只是在特定的实例上进行了方法注入，

```javascript
const anotherText = new String('rats');

try {
    console.log(anotherText.reverse());
} catch(ex) {
    console.log(ex.message);
}
```

此时，结果为：

```text
anotherText.reverse is not a function
```

显然，只在实例上进行注入风险较小，切不会对其他类的实例产生影响，若想直接对类进行注入，则需要非常慎重，除非你非常确定的知道自己在做什么。

### 向类的原型注入方法

当我们向一个类的原型注入方法后，其所有实例将都用用该方法：

```javascript
'use strict';

const text = new String('live');
const anotherText = 'rats';
const primitiveText = 'part';

String.prototype.reverse =
    function() { return this.split('').reverse().join(''); };

console.log(text.reverse());
console.log(anotherText.reverse());
console.log(primitiveText.reverse());
```

结果为：

```text
evil
star
trap
```

### 注入一个属性

注入字段\(field\)和方法时，你可以直接将值或函数赋值给你定义的成员名称，但是属性注入的情况大为不同。

当创建一个类时，我们像写方法一样写属性，使用`get`标注getters，而用`set`来标注setters。因此你可能想尝试像注入方法一样注入一个属性，并在代码中对应的位置增加`get`或者`set`；很遗憾，这不会生效。

要想注入一个属性，需要使用名为`defineProperty()`的特殊方法。该方法有三个参数：注入的属性的目标对象，注入的属性名字符串，以及一个含有`get`和/或`set`对象。

下面是一个实例，向一个`Date`类的实例注入`isInLeapYear`属性：

```javascript
const today = new Date();

Object.defineProperty(today, 'isInLeapYear', {
    get: function() {
        const year = this.getFullYear();
        return (year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0);
    }
});

console.log(`${today.getFullYear()} is a leap year?: ${today.isInLeapYear}`);
```

该属性是一个只读属性，因为我们这里只提供了一个getter，而没有setter。结果为：

```text
2018 is a leap year?: false
```

怎样让所以有`Date`实例拥有该属性呢？

将`today`替换为`Date.prototype`：

```javascript
Object.defineProperty(Date.prototype, 'isInLeapYear', {
    get: function() {
        const year = this.getFullYear();
        return (year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0);
    }
});

for(const year of [2018, 2019, 2020, 2021]) {
    const yayOrNay = new Date(year, 1, 1).isInLeapYear ? '' : 'not ';
    console.log(`${year} is ${yayOrNay}a leap year`);
}
```

结果为：

```text
2018 is not a leap year
2019 is not a leap year
2020 is a leap year
2021 is not a leap y
```

注入属性相较于字段和方法的注入需要花费更多的精力。

### 注入多个属性

接下来我们来研究如何注入多个属性。

首先，思考一下向一个已存在的类添加一组有用的属性。`Array`类提供了很多非常酷的方法，但是并没有一个优雅的途径来获取首尾的元素。我们将要向`Array`类注入`first`和`last`方法。首先新建一个数组：

```javascript
const langs = ['JavaScript', 'Ruby', 'Python', 'Clojure'];
```

获取首尾元素可以这样：

```javascript
const firstElement = langs[0];
const lastElement = langs[langs.length - 1]; //eh?
```

但这样写不够人性化，接下来用注入的方式为`Array`添加方法：

```javascript
Object.defineProperties(Array.prototype, {
    first: {
        get: function() { return this[0]; },
        set: function(value) { this[0] = value; }
    },
    last: {
        get: function() { return this[this.length - 1]; },
        set: function(value) { this[Math.max(this.length - 1, 0)] = value; }
    }
});
```

与`defineProperty()`不同，`defineProperties()`只有两个参数：目标对象，以及以属性作为key的对象。每一个属性提供一个getter和/或setter。

这时可以将代码修改为：

```javascript
const firstElement = langs.first;
const lastElement = langs.last;

console.log(firstElement);
console.log(lastElement);

langs.first = 'Modern JavaScript';
langs.last = 'ClojureScript';

console.log(langs);
```

检查其输出为：

```text
JavaScript
Clojure
[ 'Modern JavaScript', 'Ruby', 'Python', 'ClojureScript' ]
```


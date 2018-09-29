# 类

在过去，JS也存在面向对象的用法，但却由于其基于原型链的实现且没有明确的类的声明，导致一直以来其面向对象的特性不被大多数人所认可。ES6新增的class语法弥补了这一缺憾，为我们提供了更好的开发体验，且语义上也更为清晰。

## 创建一个类

### 旧方法

通过构造函数实现，通常首字母大写来区分普通函数和构造函数：

```javascript
function Car() {
    this.turn = function(direction) { console.log('...turning...'); }
}
```

或者：

```javascript
function Car() {}

Car.prototype.turn = function(direction) { console.log('...turning...'); }
```

或者：

```javascript
function Car() {}

Car.turn = function(direction) { console.log('...turning...'); }
```

每种方法都有各自的问题，并且有多种途径定义函数给开发者带来了额外的负担，且容易产生错误。

另一个问题是，没有什么办法能阻止将`new`放到一个函数前的行为，例如：`new car()`，或者将构造函数当成普通函数触发，例如：`Car()`。目前通常的做法是通过写入额外的判断逻辑来解决这些问题，额不是JS本身会抛出错误。

那么继承呢？我们如何来重写方法？我们是否使用

```javascript
this.__proto__.foo.apply(this, arguments);
```

方法来调用基类的方法？编写这样的代码语义不清且易出错。

### 使用新语法

定义一个`Car`类：

```javascript
class Car {}

console.log(Car);
```

看起来非常简洁且语义清晰。但是尽管使用`class`语法，我们实际上还是创建了一个函数，一个只能用`new`调用的函数。输出结果为：

```text
[Function: Car]
```

虽然`class`语法实际上还是定义了一个函数，但如果我们像普通函数那样调用，则会得到一个错误：

```javascript
Car(); //BROKEN CODE
^

TypeError: Class constructor Car cannot be invoked without 'new'
```

此外，不像`function Car()`语法，`class Car`不会导致声明提升，即类的定义不会移动到文件或函数的最上放。因此，下面的代码是无效的：

```javascript
new Car(); //BROKEN CODE

class Car {}
```

抛出错误：

```text
ReferenceError: Car is not defined
```

但是，如果类的定义出现在具体执行流之前，则不会出错：

```javascript
const createCar = function() {
    return new Car();
};

class Car {}

console.log(createCar());
```

## 执行Constructor

如果想在实例化时执行一些操作，则需要定义一个明确的构造器。

让我们检查一下默认构造器：

```javascript
class Car {}

console.log(Reflect.ownKeys(Car.prototype));
```

我们使用了`Reflect`类的`ownKeys()`方法来检查`Car`类原型对象的属性，结果为：

`[ 'constructor' ]`

我们可以为构造器提供具体的执行过程：

```javascript
class Car {
    constructor(year) {
        this.year = year;
    }
}

console.log(new Car(2018));
```

输出为：

```text
Car { year: 2018 }
```

注意，只有在初始化时需要执行具体操作时，才需要定义构造函数，否则使用默认构造函数即可。

## 定义一个方法

定义一个方法时，函数体需要用`{}`包裹，但是不需要加上`function`关键字。

```javascript
class Car {
    constructor(year) {
        this.year = year;
        this.miles = 0;
    }

    drive(distance) {
        this.miles += distance;
    }
}
```

## 定义计算成员

有时候我们需要为类的成员赋予动态名称，例如属性名和方法名。

```javascript
const NYD = `New Year's Day`;

class Holidays {
    constructor() {
        this[NYD] = 'January 1';
        this["Valentine's Day"] = 'February 14';
    }

    [
        'list holidays']() {
            return Object.keys(this);
    }
}
```

除了在类的内部定义方法或属性，我们还可以在实例上进行添加：

```javascript
const usHolidays = new Holidays();
usHolidays['4th of July'] = 'July 4';
```

## 新建属性

假设我们想知道车的使用年数，其生产日期早初始化时获取，我们通过`getAge()`方法来获取具体使用时间：

```javascript
getAge() {
    return new Date().getFullYear() - this.year;
}
```

调用方法为：

```javascript
const car = new Car(2007);

console.log(car.getAge());
```

这样的代码可以生效，但是`getAge()`是Java风格的`getter`，C\#开发者写属性而不是`getter`方法。JS现在提供了同样的能力。一个属性可以有一个`getter`，一个`setter`，或者两者都有。如果一个属性是有`getter`，则它是一个只读属性，现在我们将注意力先放到`getter`上。

如果一个方法仅仅只有类似`getter`的行为，那么将它作为一个只读属性而不是一个方法。现在让我们把`getAge()`转化为一个属性：

```javascript
get age() {
    return new Date().getFullYear() - this.year;
}
```

这个`getter`属性使用`get`关键字，后接属性名称`name`。如果忽略`get`关键字，则和普通的类方法`age()`没什么区别。注意，此时我们不能调用`age()`，因为它不是一个方法，我们必须直接使用这个属性名，像这样：

```javascript
console.log(car.age);
car.age = 7;
```

当`car.age`被用于表达式中时，JS将会调用函数体中的`get age()`。

如果将`car.age`放到赋值语句的左边，JS会寻找`set age(value)`。由于这个属性没有`setter`，JS会忽略该赋值语句。如果我们使用`'use strict';`-- 则会抛出错误：`Cannot set property age of #<Car> which has only a getter`。

让我们在`Car`中创建一个读写属性：

```javascript
get distanceTraveled() { return this.miles; }

set distanceTraveled(value) {
    if(value < this.miles) {
        throw new Error(
        `Sorry, can't set value to less than current distance traveled.`);
    }

    this.miles = value;
}
```

接下来测试一下我们的代码：

```javascript
const car = new Car(2007);
car.drive(10);

console.log(car.distanceTraveled);

car.distanceTraveled = 14;
console.log(car.distanceTraveled);

try {
    car.distanceTraveled = 1;
} catch(ex) {
    console.log(ex.message);
}
```

结果为：

```text
10
14
Sorry, can't set value to less than current distance traveled.
```

setter属性主要用于一些属性更改前的检验和认证。

## 定义类方法

当创建一个抽象时，我们经常需要使用一些方法，而这些方法可能与具体实例无关。类方法，而非实例方法，就是用于这个时候。

JS通过`static`关键字，让一切变得很简单。

首先我们在类中增加一个属性：

```javascript
Car.distanceFactor = 0.01; //This goes outside class Car {...}
```

我们也可以定义一个属性`getter`：

```javascript
static get ageFactor() { return 0.1; }
```

静态`getter`，静态`setter`或静态方法中的`this`是动态的，它不指向类的实例。当类中的静态成员在类上被调用时，`this`指向这个类，当时当`this`绑定到其他对象时，就不再指向这个类了。

最后，定义一个`static`方法：

```javascript
static pickBetter(carA, carB) {
    const computeScore = car =>
        car.age * Car.ageFactor + car.distanceTraveled * Car.distanceFactor;

    return computeScore(carA) < computeScore(carB) ? carA : carB;
}
```

测试一下：

```javascript
const car1 = new Car(2007);
car1.drive(150000);

const car2 = new Car(2010);
car2.drive(175000);

console.log(Car.pickBetter(car1, car2));
```

注意，金泰方法不能通过实例对象调用。

## 类表达式

类表达式在运行时动态创建类时非常有效。类表达式和类声明的主要区别有两个：

1. 类的名称对于类表达式来说是可选项，而对于类声明确实必要的
2. 类表达式应该被看作一个表达式，也就是说它应该被返回，并传递给另一个函数，或者存到一个变量中

来看一个例子：

```javascript
const createClass = function(...fields) {
    return class {
        constructor(...values) {
            fields.forEach((field, index) => this[field] = values[index]);
        }
    };
};
```

`createClass()`类似一个工厂函数，用于动态创建一个类。

我们可以在接收端赋任何的名称：

```javascript
const Book = createClass('title', 'subtitle', 'pages');
const Actor = createClass('firstName', 'lastName', 'yearStarted');
```

当获取到类创建后的引用之后，我们就可以像类声明定义的类一样进行使用：

```javascript
const fisher = new Actor('Carrie', 'Fisher', 1969);
console.log(fisher);
```

输出：

```text
{ firstName: 'Carrie', lastName: 'Fisher', yearStarted: 1969 }
```

由于我们的类在创建时没有给予名称，因此实例的输出看起来像是一个JS对象。

在很少的情况下，你可能发现对类表达式定义的类命名是有意义的，比如下面的情况：

```javascript
const Movie = class Show {
    constructor() {
        console.log('creating instance...');
        console.log(Show);
    }
};

console.log('Movie is the class name');
console.log(Movie);
const classic = new Movie('Gone with the Wind');

try {
    console.log('however...');
    console.log(Show);
} catch(ex) {
    console.log(ex.message);
}
```

名称`show`只在类内部可见，在外部只能通过`Movie`来找到累的引用。输出：

```text
Movie is the class name
[Function: Show]
creating instance...
[Function: Show]
however...
Show is not defined
```

## 内置类:Set,Map,WeakSet,和WeakMap

我们在编程中进场要用到各种对象集合。在其他语言中，你可能会用到数组，队列，集合，映射表或者字典，但很可惜，过去JS只提供了数组。

现在，JS为sets和maps提供了内置的类。

### 使用Set

数组类型足以处理有序数据集合的任务。但如果你想创建一个无序集合呢？如果你希望集合元素是互不相同的呢？例如，保存了一个用户的信用卡集合，你可能想查询一个特定的信用卡是否已经存在于这个集合，这时数组就显得比较乏力了。事实上，这时你需要的是一个Set。

Set是一组独一无二的基本类型和对象类型的集合 -- 不允许出现重复。

下面是一个拥有5个值得Set，但其中一个值却不会出现在Set实例中，因为这是一个重复值：

```javascript
const names = new Set(['Jack', 'Jill', 'Jake', 'Jack', 'Sara']);

console.log(names.size);
```

返回结果为4。你还可以向一个已存在的集合添加元素：

```javascript
names.add('Mike');
```

`add()`方法的一个很棒的特性就是会返回一个当前的集合 -- 这让它能够方便的进行链式调用：

```javascript
names.add('Kate')
    .add('Kara');
```

我们还可以用`has()`方法来判断一个值在set中是否已经存在。我们还能通过`clear()`方法来清空已存在的set；或者使用`delete()`方法删除set中某个已存在的元素值。

要获取一个`Set`中所有的值，可以使用`keys()`或者`values()`。这两个方法会返回`Set`类型的迭代器，举例如下：

```javascript
for(const key of names.keys()){
    console.log(key)
}
```

输出：

```text
Jack
Jill
Jake
Sara
```

事实上`Set`每个元素的key和value值相同，使用`entries()`方法输出结果：

```javascript
for(const entry of names.entries()){
    console.log(entry)
}
```

输出：

```text
["Jack","Jack"]
["Jill","Jill"]
["Jake","Jake"]
["Sara","Sara"]
```

我们知道，任何正确实现了迭代器方法`[Symbol.iterator]`的实例都可以进行遍历。我们看一下`Set`的实例是否实现了该方法：

```javascript
console.log(names[Symbol.iterator])
```

输出结果为:

```text
ƒ values() { [native code] }
```

显然JS原生实现了该方法，这也意味着我们还能直接使用`for`循环来遍历一个`Set`实例，像这样：

```javascript
for(const name of names) {
    console.log(name);
}
```

如果你更喜欢函数式风格，`Set`可以让你通过`forEach`来达成所愿：

```javascript
names.forEach(name => console.log(name));
```

说到函数式编程，你可能还会想到`filter()`和`map()`方法。很遗憾，`Set`没有提供这些方法，但是有一个变通的方案。你可以从集合中创建一个数组，然后就可以在这个数组上使用这些函数化的方法了。例如：

```javascript
[...names].filter(name => name.startsWith('J'))
    .map(name => name.toUpperCase())
    .forEach(name => console.log(name));
```

### 使用Map

映射或是字典是编程中重要的数据结构。想象一下我们需要跟踪赛季中球队和球队的得分。一个映射能够让创建和跟新得分变得很轻松，并且可以根据队名快速的查找其对应的得分，很难相信一个严谨的程序会没有映射。

尽管JS的对象含有键和值，并且尽管没有`Map`类型，过去的编程人员通常使用简单的对象来表示映射。不幸的是，这会导致一些问题。

1. 没有简单的途径来迭代所有的键 -- `keys()`方法会将属性名强制转化为字符串，这可能会导致键名的冲突。
2. 没有简单的方法来增加新的键和值。

简而言之，使用普通对象来表示一个映射不够实用和优雅。JS中新增加的`Map`类型解决了这些问题。

一个映射是键和值的关联集合，其中键是唯一的。键和值可能是任意基本类型或对象。举个例子：

```javascript
const scores =
    new Map([['Sara', 12], ['Bob', 11], ['Jill', 15], ['Bruce', 14]]);

scores.set('Jake', 14);

console.log(scores.size);
```

通过`set()`方法增加新的键值，通过`size`属性来获取当前映射所拥有的键的数量。

要想遍历集合的键值，我们可以使用`entries()`方法。例如，我们提取每个键值对的队名和得分并打印：

```javascript
for(const [name, score] of scores.entries()) {
    console.log(`${name} : ${score}`);
}
```

我们同样可以使用`forEach()`方法，但是这里传递给`forEach()`的参数显得有些奇怪。先来看一下实例，然后再继续讨论其参数：

```javascript
scores.forEach((score, name) => console.log(`${name} : ${score}`));
```

第一个参数是值，而第二个参数才是键，我们理所当然的会认为第一个参数应该是键名，而第二个参数才是具体的值。其实这是有原因的，因为`forEach()`方法可能只用于迭代具体的值，而对于键名却不关心：

```javascript
scores.forEach(score => console.log(score));
```

现在明白这样处理的原因了吧~

如果你只想迭代键名，那么可以使用`keys()`方法，同时如果只想获取并迭代具体的值，则可以使用`values()`。最后，如果需要查询一个键名是否存在，可以使用`has()`方法。

### WeakSet和WeakMap

设想一下，如果向一个集合增加一个对象，或者将对象作为映射的键名，如果这个对象在应用中不再需要，它也不会被垃圾回收。因为`Set`和`Map`会阻止其被清理。这对于内存使用非常不利。`WeakSet`和`WeakMap`分别作为`Set`和`Map`的配对物，可以用于解决这类问题，因为两个对于内存使用的影响都很小。

那么为什么需要这些弱类型呢？

设想一个场景，不同的车辆信息基于数据库中的车辆的识别号\(VIN\)来查询。你应该不想每次需要这些信息时，都发送一个fetch请求，更高效的做法应该是缓存这些信息，例如保存在映射中。然而当车辆的数量非常巨大时，某些车辆不在被使用，这时你就需要手动的去清楚这些数据，否则就会导致内存的过度使用。

这时，轮到`WeakMap`登场了，当一个VIN被废弃，`WeakMap`中作为key与之关联数据就会变得陈旧，并且将会准备被垃圾回收。当内存需求量提高，运行时\(runtime\)将会动态清理这些陈旧数据。

另一个使用场景是在GUI编程中。一个UI控制逻辑可能会添加到一个集合，以此事件可以被送送到这个逻辑片段。然而，如果这个UI控制逻辑不在需要，我们将不再希望它出现在这个集合中。如果使用`Set`，我们必须手动删除。这时`WeakSet`可以自动释放这些不在需要的对象。

当然`WeakSet`和`WeakMap`的使用也存在一些限制：

* 存储于`Set`中的值以及`Map`中的keys可能是基本类型，也可能是对象类型，而`WeakSet`中的值和`WeakMap`中的keys则必须是对象，不能是基本类型。
* 弱集合是不可枚举的。原因是在枚举过程中，集合中的对象可能会被垃圾回收，而这会导致迭代时发生错误。

`WeakSet`只提供了`add()`，`delete()`和`has()`方法。`WeakMap`只提供了`get()`，`delete()`，`set()`和`has()`方法。正如我们不能对弱集合进行枚举，我们也不能查询它的大小 -- meiyou `size`属性。

让我们比较一下`Map`和`WeakMap`的行为。下面是一个`Map`的例子：

```javascript
const MAX = 100000000;
const map = new Map();

for(let i = 0; i <= MAX; i++) {
    const key = {index: i};
    map.set(key, i);
}

console.log("DONE");
```

在每次迭代过程中，会在堆中创建一个新的对象，然后将这个对象插入并作为映射的一个key。由于`Map`将会让这些对象处于被引用状态，因此这些对象不会被垃圾回收，最终导致堆内存溢出：

```text
...
FATAL ERROR: invalid table size Allocation failed -
JavaScript heap out of memory
```

当修改为如下代码时：

```javascript
//...
const map = new WeakMap();
//...
```

最终不会输出任何错误：

```text
DONE
```


# 继承

与其他主流的编程语言不同，JS并不是基于类的概念来实现继承的，它是通过内部的原型链来实现继承的效果，这会让很多其他语言的开发者感到困惑，例如Java等。此外这样的继承机制也容易带来维护上的困难和概念上的混淆。

幸好，ES6的出现为我们带来了耳目一新的感觉，让一切变得自然和易于理解。但要注意，**新的语法并没有改变内部的继承机制**，换而言之，它只是一个语法糖而已。

## 理解原型继承

原型继承的实现使用了委托(delegation)。JS遵循着**委托优于继承**的理念，基于原型的语言使用对象链来委托请求调，依赖于原型链上的下一个对象作为它的基(base)。而基于类的继承就灵活很多，只会继承到父类(parent)，不会继续向前追溯。此外，原型继承是动态的；你可以在运行时修改作为基的对象，这个基对象被称为对象的原型。

### 原型链

由于继承的执行使用的是对象链，而非类层级结构，为了理解原型继承，我们首先需要了解对象链的行为。举个例子：

```js
class Counter {}

const counter1 = new Counter();
const counter2 = new Counter();

const counter1Prototype = Reflect.getPrototypeOf(counter1);
const counter2Prototype = Reflect.getPrototypeOf(counter2);

console.log(counter1 === counter2); //false
console.log(counter1Prototype === counter2Prototype); //true
```


类的实例互不相同，但是却共享同一个原型对象。

JS构建了一个原型链。以之前代码为例，结果为：


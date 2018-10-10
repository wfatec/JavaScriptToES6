# 使用Modules

好的软件设计必然是内聚的。当一段代码是紧凑的，关注点单一且只做一件事情，那么我们可以认为这个代码是内聚的。我们应该努力在各个层面实现内聚，包括：函数，类，甚至文件。

我们总是希望共同实现同一功能的代码是在一个文件中，而非分散在多个文件，这样更易于理解和维护。JS模块就是为此而生，通过`imports`引入依赖，通过`exports`导出供他人调用的功能。

## 创建一个模块

NodeJS从8.5版本起为模块提供了实验性的支持，方法是在命令行加入`--experimental-modules`。NodeJS引入模块文件后缀名从`.js`更改为`.mjs`。

接下来咯一个例子，模块名为`right`，文件名为`right.mjs`：

```javascript
console.log('executing right module');

const message = 'right called';

export const right = function() {
    console.log(message);
};
```

其中`message`对外部是不可见的。接下来创建第二个模块`middle`，并加载之前的模块：

```javascript
import { right } from './right';

console.log('executing middle module');

export const middle = function() {
    console.log('middle called');
};
```

通常我们将所有需要导入的模块放到文件的开头，且`imports`在嵌套代码中不会生效。

最后创建一个`left`模块：

```javascript
import { right } from './right';
import { middle } from './middle';

middle();
right();
```

现在让我们仔细分析一下，当`left`执行时，首先加载了`right`模块。然后加载`middle`模块，但是`middle`模块中又同样加载了`right`模块。可能你会产生疑问，`right`模块会被加载两次吗？幸运的是，不会。JS模块的管理非常智能，**一个模块只会在执行控制流首次引入时加载一次，如果一个模块已经加载，加载请求将会被忽略，但是引入的任何变量都会被赋予合适的引用**。为了验证这一观点，我们执行一个`left`模块；记住加上必要的命令行选项：

```text
node --experimental-modules left.mjs
```

输出结果为：

```text
(node:78813) ExperimentalWarning: The ESM module loader is experimental.
executing right module
executing middle module
middle called
right called
```

结果表明，我们可以自由的引入模块而不必担心产生重复引用等问题。

## 模块的导出

JS为导出模块提供了一些选项，我们可以根据自身需要来进行选择。

### 行内导出

这是最为简洁的方法。下面的代码道出了一个基本数据类型，一个函数，一个对象，以及一个类：

```javascript
export const FREEZING_POINT = 0;

export function f2c(fahrenheit) {
    return (fahrenheit - 32) / 1.8;
}

export const temperaturePoints = { freezing: 0, boiling: 100 };

export class Thermostat {
    constructor() {
        //...initialization sequence
    }
}

const FREEZINGPOINT_IN_F = 32;
```

### 明确声明导出

尽管行内导出的方式能够直观的判断引用是否需要导出到外部，但是却很难让人一眼看出一个文件中所有需要导出的部分，这是可以通过明确声明的方式，批量导出：

```javascript
function c2f(celsius) {
    return celsius * 1.8 + 32;
}

const FREEZINGPOINT_IN_K = 273.15, BOILINGPOINT_IN_K = 373.15;

export { c2f, FREEZINGPOINT_IN_K };
```

**我们应该更倾向于使用行内导出的方式，只有当行内导出不适合时，才考虑直接声明的方式**。

### 导出时使用别名

```javascript
function c2k(celsius) {
    return celsius + 273.15;
}

export { c2k as celsiusToKelvin };
```

这时`c2k`仅在模块内部可见。

### 默认导出

一个模块只能有一个默认导出。

想定义一个默认导出，只需要在`export`关键字后面加上`default`关键字。然而默认导出有一个限制：`export default`不允许出现在`const`和`let`之前。简而言之，行内的默认导出允许导出函数和类，但是不允许导出变量。你可以明确导出变量和常量为默认值。

行内默认导出：

```javascript
export default function unitsOfMeasures() {
    return ['Celsius', 'Delisle scale', 'Fahrenheit', 'Kelvin', /*...*/];
}
```

同样可以明确声明：

```javascript
function unitsOfMeasures() {
    return ['Celsius', 'Delisle scale', 'Fahrenheit', 'Kelvin', /*...*/];
}

export default unitsOfMeasures;
```

还有一个需要注意的地方是，对于默认导出来说，在模块外部的名称也是`default`并且导入该模块时可以将名称`default`绑定到其他任意的名称。因此，如果内部无需使用该默认导出的引用，可以忽略其名称：

```javascript
export default function() {
    return ['Celsius', 'Delisle scale', 'Fahrenheit', 'Kelvin', /*...*/];
}
```

对于类，也同样如此。

### 重新导出其他模块

我们有时候需要将其它模块的导出归并到当前模块。从而让使用者能够更方便的进行使用。

例如创建一个`weather`模块，它想暴露出来自`temperature`和`pressure`的函数，这时，用户就不需要导入三个模块了，只需要导入`weather`模块即可。

下面是重新导出`temperature`中所有导出引用的方法\(**除了默认导出以外**\)：

```javascript
export * from './temperature';
```

现在引入`weather`的模块就能使用所有来自`temperature`导出的引用了。

我们同样可以只选择需要的导出：

```javascript
export { Thermostat, celsiusToKelvin } from './temperature';
```

这时，只有`Thermostat`和`celsiusToKelvin`被导出。

我们同样可以在导出时重命名，以及重新导出`default`作为当前模块的`default`：

```javascript
export { Thermostat as Thermo, default as default } from './temperature';
```

同样，也可以将其他导出内容作为当前模块的默认导出：

```javascript
export { Thermostat as Thermo, f2c as default } from './temperature';
```

## 模块的导入

JS提供了多种导入策略，我们可以从中选择最符合业务场景的方式。

### 导入命名的exports

导入命名的exports要遵循两条规则

1. 引入时，与被引用名称一致
2. 名称需用`{}`包裹

举例如下：

```javascript
import { FREEZING_POINT, celsiusToKelvin } from './temperature';

const fpInK = celsiusToKelvin(FREEZING_POINT);
```

### 解决冲突

冲突的出现可能有两种情况：

1. 引入模块的导出名称与本模块的其他成员名称相同。
2. 不同引入模块的导出名称相同。

```javascript
import { Thermostat } from './temperature';
import { Thermostat } from './home';
```

此时抛出错误：

```text
import { Thermostat } from './home';
         ^^^^^^^^^^

SyntaxError: Identifier 'Thermostat' has already been declared
```

一个解决方案是将其中一个名称用别名替换：

```javascript
import { Thermostat } from './temperature';
import { Thermostat as HomeThermostat } from './home';
```

另一个方案是将其中一个模块的引入放置到一个命名空间对象：

```javascript
import { Thermostat } from './temperature';
import * as home from './home';

console.log(Thermostat);
console.log(home.Thermostat);
```

当引入的模块较多时，使用命名空间的方式能够极大降低冲突的发生。

### 导入一个默认export

下面这种写法写的非常奇怪：

```javascript
import { default as uom } from './temperature';
```

实际上只需要这样：

```javascript
import uom from './temperature';
```

### 同时引入默认及命名exports

```javascript
import uom, { celsiusToKelvin, FREEZING_POINT as brrr } from './temperature';
```

### 全部导入到命名空间

```javascript
import * as heat from './temperature';
const fpInK = heat.celsiusToKelvin(heat.FREEZING_POINT);
```

此时`heat`中并不包括`default`，如果不想遗漏`default`，可以这样：

```javascript
import uom, * as heat from './temperature';
```

### 引入副作用

在极少的情况下，我们希望需要引入一个模块，但是却不会使用这个模块的任何导出，而是想执行模块中的代码，例如将某些变量挂在的`window`对象。这个文件可能并不实际导出任何引用，即使有，可能用户也并不关心。这种情况下我们可以在`import`后直接跟上模块名称。例如：

```javascript
import 'some-side-effect-causing-module'
```

此时，将会执行这个模块而不引入任何引用。

尽管有这个功能，但是**尽量避免创建带有副作用的模块**，因为这会让代码难以维护和测试，且容易产生错误。


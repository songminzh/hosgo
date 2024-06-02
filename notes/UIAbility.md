## 1. 概述
AbilityStage是一个Module级别的组件容器，应用的HAP在首次加载时会创建一个AbilityStage实例，可以对该Module进行初始化等操作。

AbilityStage与Module一一对应，即一个Module拥有一个AbilityStage。

## 2. 使用AbilityStage能力
AbilityStage文件需要手动创建，可以在对应的ets目录下创建一个名为`MainAbilityStage`的ets文件。

```typescript
import AbilityStage from '@ohos.app.ability.AbilityStage';
import type Want from '@ohos.app.ability.Want';

export default class MainAbilityStage extends AbilityStage {
  onCreate(): void {
    // 应用的HAP在首次加载的时，为该Module初始化操作
  }
  onAcceptWant(want: Want): string {
    // 仅specified模式下触发
    return 'MainAbilityStage';
  }
}
```

在`module.json5`配置文件中，通过配置`srcEntry`参数来指定模块对应的代码路径，以作为HAP加载的入口。

```ts
{
  "module": {
    "name": "entry",
    "type": "entry",
    "srcEntry": "./ets/myabilitystage/MyAbilityStage.ets",
    ...
  }
}
```

## 3. 生命周期与事件回调
`AbilityStage`拥有`onCreate()`生命周期回调和`onAcceptWant()`、`onConfigurationUpdated()`、`onMemoryLevel()`事件回调。

* `onCreate()`：在开始加载对应Module的第一个UIAbility实例之前会先创建AbilityStage，并在AbilityStage创建完成之后执行其onCreate()生命周期回调。
* `onAcceptWant()`：UIAbility指定实例模式（specified）启动时候触发的事件回调。
* `onConfigurationUpdated()`：当系统全局配置发生变更时触发的事件，系统语言、深浅色等，配置项目前均定义在Configuration类中。
* `onMemoryLevel()`：当系统调整内存时触发的事件。

## 结构
* HAP（Harmony Ability Package）是应用安装和运行的基本单元。HAP包是由代码、资源、第三方库、配置文件等打包生成的模块包，其主要分为两种类型：entry和feature。
* HAR（Harmony Archive）是静态共享包，可以包含代码、C++库、资源和配置文件。通过HAR可以实现多个模块或多个工程共享ArkUI组件、资源等相关代码。
* HSP（Harmony Shared Package）是动态共享包，可以包含代码、C++库、资源和配置文件，通过HSP可以实现应用内的代码和资源的共享。HSP不支持独立发布，而是跟随其宿主应用的APP包一起发布，与宿主应用同进程，具有相同的包名和生命周期。
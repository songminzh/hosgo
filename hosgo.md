[TOC]

🔔 欢迎您参加掘金 X 华为鸿蒙有奖征文活动，期待大们用HarmonyOS NEXT实现自己创意的过程

🙋投稿流程：
1.注册华为平台账号：【https://id1.cloud.huawei.com/AMW/portal/home.html】
2.获取HarmonyOS NEXT学习体验机会，实现您的创意过程
HarmonyOS NEXT定向招募申请链接🔗：
https://docs.qq.com/doc/DZHhHTEJEaGh0S05w
申请渠道填写：掘金征文活动
填写错误将会导致审核不通过噢
申请链接禁止转发🈲️
申请审核周期：3个工作日内

3.结合自己的开发体验在稀土掘金官网 juejin.cn/ 发表文章，分类选择不限，标签添加“HarmonyOS”，创作话题选择“华为鸿蒙有奖征文”，且在文章首或尾句带下“本文正在参加华为鸿蒙有奖征文征文活动”即可
参与活动用户有机会参加HarmonyOS 竞赛

🎁获奖同学有机会获得价值¥3699元2024稀土掘金开发者大会线下2天通票4张、限量稀土掘金 Touch系列「能量加满」无线充电座、限量稀土掘金 x A-SOUL 周边等

🔍详情戳文章了解：
https://juejin.cn/post/7366945260792168486

check

https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-run-emulator-0000001582636200#section147575117514

# HarmonyOS Development

## ArkTS语言
ArkTS是HarmonyOS优选的主力应用开发语言。

### 演进
> JS --> TS --> ArkTS（方舟）

### ArkTS声明式开发范式
* 装饰器
用来装饰类、结构体、方法以及变量，赋予其特殊的含义。
`@Component`：自定义组件；
`@Entry`：入口组件；
`@State`：组件中的状态变量，此状态改变会引起UI变更。

* 自定义组件
可复用的UI单元，可组合其它组件，使用`@Component`描述。

* UI描述
声明式的方式来描述UI的结构，如`build()`方法内部的代码块。

* 内置组件
框架中默认内置的基础和布局组件，可直接被开发者调用，如：Column、`Text`、`Divider`、`Button`。

* 事件方法
用于添加组件对事件的响应逻辑，统一通过事件方法进行设置，如跟随在`Button`后面的`OnClick()`。

* 属性方法
用于组件属性的配置，统一通过属性方法进行设置，如`fotSize()`、`width()`、`height()`、`color()`等，可通过链式调用的方式设置多项属性。

总体而言，ArkUI开发框架通过扩展成熟语言、结合语法糖或者语言原生的元编程能力、以及UI组件、状态管理等方面设计了统一的UI开发范式，结合原生语言能力共同完成应用开发。


### 组件状态管理装饰器
用来管理组件中的状态，它们分别是：@State、@Prop、@Link。

* @State装饰的变量是组件内部的状态数据，当这些状态数据被修改时，将会调用所在组件的build方法进行UI刷新。

* @Prop与@State有相同的语义，但初始化方式不同。@Prop装饰的变量必须使用其父组件提供的@State变量进行初始化，允许组件内部修改@Prop变量，但更改不会通知给父组件，即@Prop属于单向数据绑定。

* @Link装饰的变量可以和父组件的@State变量建立双向数据绑定，需要注意的是：@Link变量不能在组件内部进行初始化。

* @Builder装饰的方法用于定义组件的声明式UI描述，在一个自定义组件内快速生成多个布局内容。

### 声明式UI特征
* 声明式描述
* 状态驱动视图更新

## UIAbility
> 应用程序入口 & 系统调度单元

**一个App可以包含一个或多个UIAbility**

### 生命周期
* Create（创建）
* Distroy（销毁）
* Foreground（前台）
* Background（后台）

![0000000000011111111.20240320115212.51149570375184611494552745264337](assets/0000000000011111111.20240320115212.51149570375184611494552745264337.png)

其中`WindowStageCreate`和`WindowStageDestroy`为窗口管理器（`WindowStage`）在UIAbility中管理UI界面功能的两个生命周期回调，从而实现UIAbility与窗口之间的弱耦合。

### 跳转
#### 跳转到次级页面

* 第一种方式：`router.pushUrl()`
```
router.pushUrl({
  url: 'pages/Next',
  params: {
    src: '',
  }
}, router.RouterMode.Single)
```

* 第二种方式：`router.replaceUrl()`
```
router.replaceUrl({
  url: 'pages/Second',
  params: {
    src: '',
  }
}, router.RouterMode.Single)
```

其中`params`为跳转页面时传递的参数，在次级页面获取上级页面传递过来的参数：

```
@State src: string = (router.getParams() as Record<string, string>)['src'];
```

#### 返回页面

* 返回到上一级页面
```
Router.back()
```

* 返回到指定页面
```
Router.back( { url: 'pages/Home' } )
```

### UIAbility的启动模式
* singleton（单实例模式）
* multiton（多实例模式）
* specified（指定实例模式）


## ArkUI
### 基础组件
* Text：文本
* Image：图片
* TextInput：单行文本输入框
* Button：按钮
* LoadingProgress：加载

可根据不同需求灵活选用UI控件，并设置其属性，实现预期性效果。

### 容器组件
* Row：行容器
* Column：列容器
* Flex：弹性容器
* Swiper：滑块容器

Column和Row容器的接口都有一个可选参数`space`，表示子组件在主轴方向上的间距。
Row和Column有两个重要属性，分别是`justifyContent`和`alignItems`。
|属性名称|描述|
|------|------|
|justifyContent|子控件在主轴方向的对齐格式|
|alignItem|子控件在交叉轴方向的对齐格式|

`justifyContent`的参数类型为`FlexAlign`：
* Start：元素在主轴方向首端对齐，第一个元素与行首对齐，同时后续的元素与前一个对齐。
* Center：元素在主轴方向中心对齐，第一个元素与行首的距离以及最后一个元素与行尾距离相同。
* End：元素在主轴方向尾部对齐，最后一个元素与行尾对齐，其他元素与后一个对齐。
* SpaceBetween：元素在主轴方向均匀分配弹性元素，相邻元素之间距离相同。 第一个元素与行首对齐，最后一个元素与行尾对齐。
* SpaceAround：元素在主轴方向均匀分配弹性元素，相邻元素之间距离相同。 第一个元素到行首的距离和最后一个元素到行尾的距离是相邻元素之间距离的一半。
* SpaceEvenly：元素在主轴方向等间距布局，无论是相邻元素还是边界元素到容器的间距都一样。

Column的`alignItem`的参数类型为`HorizontalAlign`：
* Start：设置子组件在水平方向上按照起始端对齐。
* Center（默认值）：设置子组件在水平方向上居中对齐。
* End：设置子组件在水平方向上按照末端对齐。


Row的`alignItem`的参数类型为`VerticalAlign`：
* Top：设置子组件在垂直方向上居顶部对齐。
* Center（默认值）：设置子组件在竖直方向上居中对齐。
* Bottom：设置子组件在竖直方向上居底部对齐。


### 列表组件
* List：列表
* Grid：网格

一般采用`ForEach`进行循环渲染，包含三个参数：
* arr: 数据源，为Array类型的数组。
* itemGenerator：组件生成函数。
* keyGenerator：键值生成函数。(非必传)

```
ForEach(
  arr: Array,
  itemGenerator: (item: any, index: number) => void,
  keyGenerator?: (item: any, index: number) => string
)
```

### Tabs

设置TabBar位置和排列方向：
* 顶部（默认）：BarPosition.Start，vertical属性方法设置为false。
* 左侧：BarPosition.Start，vertical属性方法设置为true。
* 底部：BarPosition.End，vertical属性方法设置为false。
* 右侧：BarPosition.End，vertical属性方法设置为true。

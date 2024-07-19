# Navigation

## 什么是Navigation？
Navigation是ArkUI中的路由容器组件，一般作为首页的根容器，适用于模块内和跨模块的路由切换。支持一次开发，多端部署场景。

Navigation组件适用于模块内页面切换，通过组件级路由能力实现更加自然流畅的转场体验，是官方推荐的导航组件（相较于Router，Navigation的支持面更广，也更适合实现一多，所以建议使用Navigation）。

看到这里，很多iOS开发者可能比较熟悉，这个组件类似于iOS中的UINavigationController，可以用于根控制器实现页面的跳转和传值，同时可以实现系统或自定义标题栏、导航Item等，我们可以在Navigation中看到这些特性。

### Navigation的组成
Navigation包含导航页（NavBar）和子页（NavDestination）。
导航页又包含以下三个部分：

* 标题栏(Titlebar，包含菜单栏menu)：通过title属性设置标题。
* 内容区(Navigation子组件)：默认首页显示导航内容（Navigation的子组件）或非首页显示（NavDestination的子组件），首页和非首页通过路由进行切换。
* 工具栏(Toolbar)：通过toolbarConfiguration实现对工具栏的配置。

![navi-1](assets/navi-1.png)


上图所示为单页面模式布局示意图，左边为导航页，右边为子页，可以通过路由转换实现页面跳转。

1. 标题栏
![navi-2](assets/navi-2.png)
标题栏有两种模式，分别为Mini和Full，可以控制标题显示的突出程度。

2. 菜单栏
![navi-3](assets/navi-3.png)
菜单栏可以设置Navigation的右上角菜单按钮的样式和点击事件。

3. 工具栏
![navi-4](assets/navi-4.png)
工具类是Navigation底部的操作按钮，可以设置多个ToolBarItem。

### 路由跳转
![navi-5](assets/navi-5.png)
Navigation路由跳转相关操作是基于页面栈`NavPathStack`提供的方法进行，每个Navigation都需要创建并传入一个`NavPathStack`对象，用于管理页面。

NavPathStack通过push、pop、remove等操作控制页面的入栈和出栈，从而完成页面的跳转。










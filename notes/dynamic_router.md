[TOC]

# 【拥抱鸿蒙】Navigation下动态路由的实现与应用

## 概述
在上一篇文章[HarmonyOS NEXT深入理解路由容器之Navigation](https://juejin.cn/post/7393746524474146879)中我们谈到了Navigation作为路由容器的一些特性。

其中也列举了`NavPathStack`创建和传递的方式，那么如何实现动态路由并实现基于Navigation的页面跳转呢？

我们知道，路由管理是指在应用程序开发中对用户界面的不同页面或视图之间导航和流转进行控制和管理的一种机制。它确保了用户能够从一个界面平滑过渡到另一个界面，并且能够跟踪和控制这些界面（或称为路由）的堆叠顺序和生命周期。

自动生成路由栈（`NavPathStack`）与页面之间的关联，并合理控制路由栈的空间管理，将是动态路由实现的关键。

## 目标
* 定义一个路由管理模块，各个提供路由页面的模块均依赖此模块。
* 构建Navgation组件时，将`NavPactStack`注入路由管理模块，路由管理模块对`NavPactStack`进行封装，对外提供路由能力。
* 各个路由页面将模块名称、路由名称、WrappedBuilder封装后构建函数注册路由模块。
* 当路由需要跳转到指定路由时，路由模块完成对指定路由模块的动态导入，并完成路由跳转。

## 实现
### 构建相关数据模型
* RouterInfo

```ts
/// 路由信息
export interface RouterInfo {
  name: string;            // 跳转页面名称
  pageModule: string;      // 跳转目标页在包内的路径，相对src目录的相对路径
  registerFunct?: string;  // 跳转目标页的入口函数名称，必须以@Builder修饰。
  pageSource?: string;     // 应用自定义字段。可以通过配置项读取接口getConfigInRouteMap获取。
}

/// 路由配置
export interface RouterConfig {
  libPrefix: string;
  mapPath: string;
}

/// 路由表
export class RouterMapModel {
  routerMap: RouterInfo[] = [];
}

/// 首页路由信息
export const HOME_PAGE: RouterInfo = {
  pageModule: "entry",
  name: "EntryView",
  registerFunct: "",
  pageSource: ""
}

/// 自定义装饰器
export function AppRouter(param: AppRouterParam) {
  return Object;
}

/// 装饰器参数
export interface AppRouterParam {
  // 跳转的路由名
  name: string;
  // 是否需要传递参数，需要的话设置为true，否则可不需要设置。
  hasParam?: boolean;
}
```

* RouterParam

```ts
/// 路由参数
export class RouterParam {
  data?: Object;
  model?: string;
}
```

### 加载路由

创建一个名为`RouterLoader`的class用于加载路由信息。

```ts
import { RouterInfo, RouterMapModel } from '../model/RouterInfo';
import { Context } from '@ohos.arkui.UIContext';
import { resourceManager } from '@kit.LocalizationKit';
import { JSON, util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';

/// 加载路由
export class  RouterLoader {

  public static load(dir: string, routerMap: Map<string, RouterInfo>, context: Context) {
    const rm: resourceManager.ResourceManager = context.resourceManager;

    try {
      rm.getRawFileList(dir).then((value: Array<string>) => {
        let decoder: util.TextDecoder = util.TextDecoder.create("utf-8", {
          fatal: false,
          ignoreBOM: true
        })

        value.forEach((fileName: string) => {
          let fileBytes: Uint8Array = rm.getRawFileContentSync(`${dir}/${fileName}`);
          let retStr = decoder.decodeWithStream(fileBytes);
          let routerMapModel: RouterMapModel = JSON.parse(retStr) as RouterMapModel;
          RouterLoader.loadRouterMap(routerMapModel, routerMap);
        })
      }).catch((error: BusinessError) => {
        console.error(`promise getRawFile failed, error code:${error.code}, message :${error.message}.`);
      })
      } catch (error) {
        let code = (error as BusinessError).code;
        let message = (error as BusinessError).message;
        console.error(`promise getRawFile failed, error code:${code} ,message :${message}`);
      }
    }

    private static loadRouterMap(routerMapModel: RouterMapModel, routerMap: Map<string, RouterInfo>): void {
      routerMapModel.routerMap.forEach((routerInfo: RouterInfo) => {
        if (routerMap.has(routerInfo.name)) {
          console.warn("duplicate router declare");
      } else {
        routerMap.set(routerInfo.name, routerInfo);
      }
    })
  }

}
```

这里依赖我们之前创建的`RouterInfo`和`RouterMapModel`，主要逻辑是使用`routerMap`将路由名称（页面名）与`RouterInfo`尽量关联，并保存在`Map`中。

### 实现路由拦截
实现一个路由拦截器`interceptor`的类，定义拦截容器、注册方法和公共拦截逻辑。

其实现思路为：

* 拦截器获取拦截容器list中所有注册过的子模块的拦截函数，如果子模块拦截函数返回true，即需要拦截，否则放行。
* 通过循环拦截容器list得到返回true时通知动态路由不再继续跳转, 否则返回false，通知动态路由继续执行跳转，跳转到我的页面。

```ts
/**
 * 定义拦截实现接口
 *
 * @param routerInfo 需要拦截的路由名
 * @param param 路由参数
 */
export interface InterceptorExecute {
  executeFunction(appUri: string, param?: string): boolean;
}

/**
 * 定义拦截器方法
 */
export class Interceptor {
  // 定义拦截器容器
  private static list: Array<InterceptorExecute> = [];

  /**
   * 注册拦截页面
   *
   * @param interceptorFnc 子模块传过来的自定义拦截函数
   */
  public static registerInterceptorPage(interceptorFnc: InterceptorExecute): void {
    Interceptor.list.push(interceptorFnc);
  }

  /**
   * 公共拦截器逻辑
   *
   * @param appUri 接收传过来的路由名
   * @param param 路由参数
   */
  public static interceptor(appUri: string, param?: string): boolean {
    // 循环拦截器容器中所有的子模块自定义的拦截函数
    for (let i = 0; i < Interceptor.list.length; i++) {
      if (Interceptor.list[i].executeFunction(appUri, param))
        return true; // 如果子模块拦截函数返回true，即需要拦截
    }
    // 否则就放行
    return false;
  }
}

```

### 实现动态路由
1. 创建一个class，命名为：`DynamicRouter`，并为其添加import和属性：

```ts
import { RouterInfo, HOME_PAGE, RouterConfig } from '../model/RouterInfo'
import { Context } from '@ohos.abilityAccessCtrl';
import { RouterLoader } from './RouterLoader';
import { BusinessError } from '@kit.BasicServicesKit';
import { Interceptor } from './Interceptor';

export class DynamicRouter {
  // 路由配置
  static config: RouterConfig;
  // 路由表信息
  static routerMap: Map<string, RouterInfo> = new Map();
  // 管理需要动态导入的模块
  static builderMap: Map<string, WrappedBuilder<[object]>> = new Map<string, WrappedBuilder<[object]>>()
  // 路由栈
  static navPathStack: NavPathStack = new NavPathStack();
  // 自动生成的路由列表
  static appRouterList: Array<RouterInfo> = new Array();
  // 引用列表
  static referrer: string[] = [];
}
```

2. 根据`RouterConfig`和`Context`进行动态路由初始化。

```ts
/* 动态路由初始化 */
  public static routerInit(config: RouterConfig, context: Context) {
    DynamicRouter.config = config;
    DynamicRouter.appRouterList.push(HOME_PAGE);

    // 加载路由表
    RouterLoader.load(config.mapPath, DynamicRouter.routerMap, context);
  }
```


3. 通过builderName，注册WrappedBuilder对象，用于动态创建页面。

```ts
/* 通过名称注册Builder */
  private static registerBuilder(builderName: string, builder: WrappedBuilder<[object]>){
    DynamicRouter.builderMap.set(builderName, builder);
  }
```

4. 获取`NavPathStack`和`WrappedBuilder`。

```ts
/* 获取Builder */
public static getBuilder(builderName: string): WrappedBuilder<[object]> {
    const builder = DynamicRouter.builderMap.get(builderName);

    if (!builder) {
      console.error(`The builder ${builderName} is not found`);
    }

    return builder as  WrappedBuilder<[object]>;
  }

/* 获取NavPathStack */
public static getNavPathStack(): NavPathStack {
    return DynamicRouter.navPathStack;
}
```

5. 引用的获取和存储

```ts
/* 获取路由来源 */
  public static getRouterReferrer(): string[] {
    return DynamicRouter.referrer;
  }

  /* 存储引用信息 */
  private static Add2RouterList(routerInfo: RouterInfo) {
    DynamicRouter.appRouterList.push(routerInfo);
    const referrerModel: RouterInfo = DynamicRouter.appRouterList[DynamicRouter.appRouterList.length-2];
    DynamicRouter.referrer[0] = referrerModel.pageModule;
    DynamicRouter.referrer[1] = referrerModel.name;

    console.info(`From appRouterList push preview module name is ${DynamicRouter.referrer[0]}, path is ${DynamicRouter.referrer[1]}`);
  }
```

6. 实现push
跳转到下一个并根据条件进行路由拦截。

```ts
/* 根据路由信息跳转到对应页面 */
public static pushUri(name: string, param?: ESObject) {
    // 如果路由表中没有该路由信息，返回
    if (!DynamicRouter.routerMap.has(name)) {
      console.error("The name is not found in router map");
      return;
    }

    let routerInfo: RouterInfo = DynamicRouter.routerMap.get(name)!;

    if (!DynamicRouter.builderMap.has(name)) {
      // 首次跳转，需要动态引用模块
      import(`${DynamicRouter.config.libPrefix}/${routerInfo.pageModule}`)
        .then((module: ESObject) => {
          module[routerInfo.registerFunct!](routerInfo);

          // 在路由模块的动态路由.pushUri()中调用拦截方法，此处必须等待动态路由加载完成后再进行拦截，否则页面加载不成功，导致无法注册拦截的函数，出现首次拦截失效。
          if (Interceptor.interceptor(name, param)) {
            return;
          }
        })
        .catch((error: BusinessError) => {
          console.error(`promise import module failed, error code:${error.code}, message:${error.message}`);
        })
    } else {
      // 非首次跳转，路由拦截
      if (Interceptor.interceptor(name, param)) {
        return;
      }

      DynamicRouter.navPathStack.pushPath({ name: name, param: param });
      DynamicRouter.Add2RouterList(routerInfo);
    }
  }
```

7. 路由注册

```ts
/* 注册动态路由需要加载的页面，用于自动生成的路由 */
  public static registerAppRouterPage(routerInfo: RouterInfo, wrapBuilder: WrappedBuilder<[object]>) {
    const builderName: string = routerInfo.name;
    if (!DynamicRouter.builderMap.has(builderName)) {
      // 注册路由
      DynamicRouter.registerBuilder(builderName, wrapBuilder);
    }
  }
```

8. 实现Pop

```ts
/* pop到上一级页面 */
public static popAppRouter() {
    const referrerModel: RouterInfo = DynamicRouter.appRouterList[DynamicRouter.appRouterList.length - 1]
    DynamicRouter.referrer[0] = referrerModel.pageModule;
    DynamicRouter.referrer[1] = referrerModel.name;

    if (DynamicRouter.appRouterList.length > 1) {
      // 当前处于次级页面
      DynamicRouter.appRouterList.pop();
    } else {
      // 当前位于首页
      console.info("At Home page, need not pop.")
    }

    // 查找到对应路由栈进行pop
    DynamicRouter.navPathStack.pop();
  }
  
/* 清空页面栈，返回根页面 */
  public static clear() {
    DynamicRouter.navPathStack.clear();
  }
```

## 使用

从API version 12开始，Navigation支持使用系统路由表的方式进行动态路由。

各业务模块（HSP/HAR）中需要独立配置router_map.json文件，在触发路由跳转时，应用只需要通过NavPathStack提供的路由方法，传入需要路由的页面配置名称。

此时系统会自动完成路由模块的动态加载、页面组件构建，并完成路由跳转，从而实现了开发层面的模块解耦。












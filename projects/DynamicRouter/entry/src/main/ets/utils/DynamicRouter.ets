import { RouterInfo, HOME_PAGE, RouterConfig } from '../model/RouterInfo'
import { Context } from '@ohos.abilityAccessCtrl';
import { RouterLoader } from './RouterLoader';
import { BusinessError } from '@kit.BasicServicesKit';
import { Interceptor } from './Interceptor';


/**
 * 动态路由
 *
 * 实现步骤：
 * 1. 将主模块的NavPathStack传入createRouter接口，注册路由
 * 2. 通过registerBuilder接口，将需要动态加载的模块注册到路由中
 * 3. 通过push接口，跳转到指定的模块页面
 * 4. 通过pop、clear等接口完成其它路由操作
 */
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

  /* 动态路由初始化 */
  public static routerInit(config: RouterConfig, context: Context) {
    DynamicRouter.config = config;
    DynamicRouter.appRouterList.push(HOME_PAGE);

    // 加载路由表
    RouterLoader.load(config.mapPath, DynamicRouter.routerMap, context);
  }

  /* 通过名称注册Builder */
  private static registerBuilder(builderName: string, builder: WrappedBuilder<[object]>){
    DynamicRouter.builderMap.set(builderName, builder);
  }

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

  /* 注册动态路由需要加载的页面，用于自动生成的路由 */
  public static registerAppRouterPage(routerInfo: RouterInfo, wrapBuilder: WrappedBuilder<[object]>) {
    const builderName: string = routerInfo.name;
    if (!DynamicRouter.builderMap.has(builderName)) {
      // 注册路由
      DynamicRouter.registerBuilder(builderName, wrapBuilder);
    }
  }


}

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
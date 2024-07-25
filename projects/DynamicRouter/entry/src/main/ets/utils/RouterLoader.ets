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
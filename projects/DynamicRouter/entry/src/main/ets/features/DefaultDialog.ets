import { DynamicRouter } from '../utils/DynamicRouter';
import { DialogOption } from './DialogOption';

@Component

export struct DefaultDialog {

  private dialogOption?: DialogOption;
  private opacityNum: number = 0;
  private translateY: number | string = "";

  build() {

    NavDestination() {

      Stack({ alignContent: this.dialogOption?.style?.align }) {

        Column() {
          // 模态遮罩

        }
        .backgroundColor(this.dialogOption?.style?.transparent ? Color.Transparent : this.dialogOption?.style?.backgroundColor) // 背景颜色
        .opacity(this.opacityNum)
        .onClick(() => {
          animateTo({
            duration: 200,
            curve: Curve.Friction,
            onFinish: () => {
              this.dialogOption?.instance?.close();
            }
          }, () => {
            this.opacityNum = 0  // 修改模态遮罩的透明度
            if (this.dialogOption?.style?.align === Alignment.Bottom) {
              this.translateY = "100%"
            }
          })
        })

        Column() {
          // 弹窗内容
          this.dialogOption?.view?.builder(this.dialogOption);
        }
        .translate({ x: 0, y: this.translateY })
      }
      .width("100%")
      .height("100%")
    }
    .mode(NavDestinationMode.DIALOG)  // 页面类型为dialog
    .onReady((ctx: NavDestinationContext) => {
      console.log("onReady")
      this.dialogOption = ctx.pathInfo.param as DialogOption;
    })
    .onBackPressed((): boolean => {
      if (this.dialogOption?.onBackPressed) {
        return this.dialogOption?.onBackPressed();
      } else {
        return false;
      }
    })
  }

}
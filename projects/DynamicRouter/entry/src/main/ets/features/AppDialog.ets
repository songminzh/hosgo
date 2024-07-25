import { DynamicRouter } from '../utils/DynamicRouter';
import { DialogOption } from './DialogOption';

const APP_DIALOG: string = "AppDialog";

export class AppDialog {
  static indexArr: number[] = [];
  private stackIndex: number = 0;
  private option?: DialogOption;
  private static toastBuilder?: WrappedBuilder<object[]>

  /* 通过可选参数创建 */
  public static buildWithOption(option?: DialogOption): AppDialog {
    let dialog: AppDialog = new AppDialog();
    let index: number = DynamicRouter.getNavPathStack().size() - 1;
    AppDialog.indexArr.push(index);
    dialog.stackIndex = index;
    dialog.option = option;

    return dialog;
  }

  /* 通过builder创建*/
  public static build(builder: WrappedBuilder<Object[]>): AppDialog {
    let option: DialogOption = new DialogOption();
    option.view = builder;
    return AppDialog.buildWithOption(option);
  }

  /* 创建toast */
  public static toast(msg: string): AppDialog {
    let option: DialogOption = new DialogOption();
    option.view = AppDialog.toastBuilder;
    option.buildParams = msg;
    return AppDialog.buildWithOption(option);
  }

  /* 打开弹窗 */
  public open() {
    DynamicRouter.getNavPathStack().pushPathByName(APP_DIALOG, this.option, this.option!.onPop!, true);

    return this;
  }

  /* 关闭弹窗*/
  public close(param?: Object) {
    if (DynamicRouter.getNavPathStack().size() > this.stackIndex) {
      DynamicRouter.getNavPathStack().popToIndex(this.stackIndex, param);
    }
  }

  /* 关闭所有弹窗 */
  public static closeAll() {
    DynamicRouter.getNavPathStack().removeByName(APP_DIALOG);
  }

  /* 关闭上一个弹窗 */
  public static closeLast(param?: Object) {
    let lastIndex = AppDialog.indexArr.pop();
    if (lastIndex && DynamicRouter.getNavPathStack().size() > lastIndex) {
      DynamicRouter.getNavPathStack().popToIndex(lastIndex, param);
    } else {
      AppDialog.closeAll();
    }
  }

  /* Set options */

  public buildParams(buildParam: Object): AppDialog {
    this.option!.buildParams = buildParam;
    return this;
  }

  public param(param: Object) {
    this.option!.param = param;
    return this;
  }

  public onBackPressed(callback: () => boolean): AppDialog {
    this.option!.onBackPressed = callback;
    DynamicRouter.getNavPathStack().pop();
    return this;
  }

  public onPop(callback: (data: PopInfo) => void): AppDialog {
    this.option!.onPop = callback;
    return this;
  }

  public animation(animation: TransitionEffect): AppDialog {
    this.option!.animation = animation;
    return this;
  }

  public duration(duration: number): AppDialog {
    this.option!.duration = duration;
    return this;
  }

  public align(align: Alignment): AppDialog {
    this.option!.style!.align = align;
    return this;
  }

  public transparent(transparent: boolean): AppDialog {
    this.option!.style!.transparent = transparent;
    return this;
  }












}
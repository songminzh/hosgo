/**
 *  Todo item
 */

import CommonConstants from '../common/constant/CommonConstant';

@Component
export struct TodoItem {
  private content?: string;
  @State isCompleted: boolean = false;

  build() {
    Row() {
      // checkbox
      Image(this.isCompleted ? $r('app.media.ic_ok') : $r('app.media.ic_default'))
        .objectFit(ImageFit.Contain)
        .width($r('app.float.checkbox_width'))
        .height($r('app.float.checkbox_width'))
        .margin($r('app.float.checkbox_margin'))

      // tasks
      Text(this.content)
        .fontSize($r('app.float.item_font_size'))
        .fontWeight(CommonConstants.FONT_WEIGHT)
        .opacity(this.isCompleted ? CommonConstants.OPACITY_COMPLETED : CommonConstants.OPACITY_DEFAULT)
        .decoration({
          type: this.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None,
        })
    }
    .borderRadius(CommonConstants.BORDER_RADIUS)
    .width(CommonConstants.LIST_DEFAULT_WIDTH)
    .height($r('app.float.list_item_height'))
    .backgroundColor($r('app.color.page_background'))
    .onClick(() => {
      this.isCompleted = !this.isCompleted;
    })
  }
}
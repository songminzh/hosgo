import CommonConstants from '../common/constants/CommonConstants';

@Component
export default struct TextInputWidget {
  private inputImage?: Resource;
  private hintText?: Resource;

  build() {
    Row() {
      Image(this.inputImage !== undefined ? this.inputImage : '')
        .width($r('app.float.input_image_size'))
        .height($r('app.float.input_image_size'))
        .margin({ left: $r('app.float.input_image_left') })
      TextInput({ placeholder: this.hintText })
        .fontSize($r('app.float.input_text_size'))
        .padding({ left: $r('app.float.input_left_inside') })
        .placeholderColor($r('app.color.place_color'))
        .backgroundColor(Color.White)
        .fontWeight(FontWeight.Normal)
        .fontStyle(FontStyle.Normal)
        .fontColor(Color.Black)
        .margin({ right: $r('app.float.input_right_inside') })
        .layoutWeight(CommonConstants.WEIGHT_ONE)
        .height($r('app.float.text_input_height'))
        .enableKeyboardOnFocus(false)
    }
    .margin({ top: $r('app.float.input_row_top') })
    .borderRadius($r('app.float.input_row_radius'))
    .backgroundColor(Color.White)
    .width(CommonConstants.COMMON_DIALOG_WIDTH)
    .height($r('app.float.input_row_height'))
  }
}
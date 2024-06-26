import prompt from '@ohos.promptAction';
import router from '@ohos.router';
import CommonConstants from '../common/CommonConstants'

@Extend(TextInput)
function inputStyle() {
  .placeholderColor($r('app.color.placeholder_color'))
  .height($r('app.float.login_input_height'))
  .fontSize($r('app.float.big_text_size'))
  .backgroundColor($r('app.color.background'))
  .width(CommonConstants.FULL_PARENT)
  .padding({ left: CommonConstants.INPUT_PADDING_LEFT })
  .margin({ top: $r('app.float.input_margin_top') })
}

@Extend(Line)
function lineStyle() {
  .width(CommonConstants.FULL_PARENT)
  .height($r('app.float.line_height'))
  .backgroundColor($r('app.color.line_color'))
}

@Extend(Text)
function textStyle() {
  .fontColor($r('app.color.other_login_text_color'))
  .fontSize($r('app.float.small_text_size'))
  .fontWeight(FontWeight.Medium)
}

@Entry
@Component
struct Login {
  @State isShowProgress: boolean = false;
  @State account: string = "";
  @State password: string = "";
  private timeoutId: number = -1

  login(): void {
    if (this.account === "" || this.password === "") {
      prompt.showToast({
        message: $r('app.string.input_empty_tips')
      })
    } else {
      this.isShowProgress = true;
      if (this.timeoutId === -1) {
        this.timeoutId = setTimeout(() => {
          this.isShowProgress = false;
          this.timeoutId = -1;
          router.replaceUrl({url: "pages/Main"})
        }, CommonConstants.LOGIN_DELAY_TIME);
      }
    }
  }

  otherLogin(type: number): void {
    switch (type) {
      case 1: //todo: 登录方式一

        break;
      case 2: //todo: 登录方式二

        break;
      case 3: //todo: 登录方式三

      break;

      default:
        break;
    }
  }

  @Builder
  CustomBtn(src: Resource, index: number) {
    Button( { type: ButtonType.Circle, stateEffect: true } ) {
      Image(src)
    }
    .width($r('app.float.other_login_image_size'))
    .height($r('app.float.other_login_image_size'))
    .backgroundColor($r('app.color.background'))
    .onClick(() => {
      this.otherLogin(index);
    })
  }

  build() {
    Column() {
      // logo
      Column() {
        Image($r('app.media.logo'))
          .width($r('app.float.logo_image_size'))
          .height($r('app.float.logo_image_size'))
          .margin( {
            top: $r('app.float.logo_margin_top'),
            bottom: $r('app.float.logo_margin_bottom')
          } )
        Text($r('app.string.login_page'))
          .fontColor(Color.Black)
          .fontSize($r("app.float.setting_account_fontSize"))
          .fontWeight(FontWeight.Bold)
          .margin( {
            bottom: $r('app.float.logo_margin_bottom')
          } )
        Text($r('app.string.login_more'))
          .fontColor($r('app.color.login_more_text_color'))
      }
      .margin( {
        bottom: $r('app.float.login_more_margin_bottom')
      } )

      // 输入框
      Column() {
        TextInput( {placeholder: $r('app.string.account')} )
          .type(InputType.Number)
          .inputStyle()
          .onChange((value: string) => {
            this.account = value;
          })
        Line().lineStyle()

        TextInput( {placeholder: $r('app.string.password')} )
          .type(InputType.Password)
          .inputStyle()
          .onChange((value: string) => {
            this.password = value;
          })
        Line().lineStyle()

        Row( {space: CommonConstants.COMMON_SPACE} ) {
          Text($r('app.string.message_login'))
            .textStyle()
          Text($r('app.string.forgot_password'))
            .textStyle()
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width(CommonConstants.FULL_PARENT)
        .margin( {
          top: $r('app.float.forgot_margin_top')
        } )
      }
      .margin( {
        top: $r("app.float.input_margin_top"),
      } )

      // 登录、注册按钮
      Column() {
        Button($r('app.string.login'))
          .height($r('app.float.login_button_height'))
          .width(CommonConstants.BUTTON_WIDTH)
          .type(ButtonType.Capsule)
          .margin( {
            top: $r('app.float.login_button_margin_top'),
            bottom: $r('app.float.login_button_margin_bottom')
          } )
          .onClick(() => {
            this.login();
          })

        Text($r('app.string.register_account'))
          .fontColor($r('app.color.login_button_color'))
      }

      if (this.isShowProgress) {
        LoadingProgress()
          .color($r('app.color.loading_color'))
          .width($r('app.float.login_progress_size'))
          .height($r('app.float.login_progress_size'))
          .margin( {
            top: $r('app.float.login_progress_margin_top')
          })
      }

      // 其他登录方式
      Blank()
      Text($r('app.string.other_login_method'))
        .fontSize($r('app.float.normal_text_size'))
        .fontColor($r('app.color.other_login_text_color'))
      .margin( {
        top: $r('app.float.other_login_margin_top'),
        bottom: $r('app.float.setting_button_bottom')
      } )
      Row( {space: CommonConstants.LOGIN_METHODS_SPACE} ) {
        this.CustomBtn($r('app.media.login_method1'), 1)
        this.CustomBtn($r('app.media.login_method2'), 2)
        this.CustomBtn($r('app.media.login_method3'), 3)
      }
    }
    .backgroundColor($r('app.color.background'))
    .width(CommonConstants.FULL_PARENT)
    .height(CommonConstants.FULL_PARENT)
    .padding( {
      left: $r('app.float.page_padding_hor'),
      right: $r('app.float.page_padding_hor'),
      bottom: $r('app.float.login_page_padding_bottom')
    } )
  }
}
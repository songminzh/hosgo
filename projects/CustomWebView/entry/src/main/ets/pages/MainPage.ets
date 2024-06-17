import { CommonConstant as Const } from '../common/Constant'
import { NavigatorBean } from 'viewmodel/NavigatorBean'

@Extend(Button)
function fancy(top: string) {
  .fontSize(Const.MAIN_CONSTANT_BUTTON_FONT_SIZE)
  .fontColor($r('app.color.start_window_background'))
  .width(Const.MAIN_CONSTANT_BUTTON_WIDTH)
  .height(Const.MAIN_CONSTANT_BUTTON_HEIGHT)
  .margin({ top: top })
  .backgroundColor($r('app.color.blue'))
  .borderRadius(Const.MAIN_CONSTANT_BUTTON_BORDER_RADIUS)
}

@Entry
@Component

struct MainPage {
  build() {
    Column() {
      Image($r('app.media.background'))
        .width(Const.MAIN_CONSTANT_FULL_HEIGHT)
        .height(Const.MAIN_CONSTANT_IMAGE_HEIGHT)
      Navigator({ target: Const.WEB_PAGE_URI, type: NavigationType.Push }) {
        Button($r('app.string.loadLocalH5'))
          .fancy(Const.MAIN_CONSTANT_BUTTON_MARGIN_TOP)
      }
      .params({ path: Const.LOCAL_PATH, tips: $r('app.string.local') } as NavigatorBean)

      Navigator({ target: Const.WEB_PAGE_URI, type: NavigationType.Push }) {
        Button($r('app.string.loadCloudH5'))
          .fancy(Const.MAIN_CONSTANT_BUTTON_MARGIN_TOP_BUTTON)
      }
      .params({ path: Const.CLOUD_PATH, tips: $r('app.string.online') } as NavigatorBean)

      Navigator({ target: Const.VUE_PAGE_URI, type: NavigationType.Push }) {
        Button($r('app.string.loadVue'))
          .fancy(Const.MAIN_CONSTANT_BUTTON_MARGIN_TOP_BUTTON)
      }
      .params({ path: Const.VUE_PATH, tips: $r('app.string.local') } as NavigatorBean)

      Navigator({ target: Const.VUE_PAGE_URI, type: NavigationType.Push }) {
        Button($r('app.string.loadCloudVue'))
          .fancy(Const.MAIN_CONSTANT_BUTTON_MARGIN_TOP_BUTTON)
      }
      .params({ path: Const.VUE_CLOUD_PATH, tips: $r('app.string.online') } as NavigatorBean)

    }
    .height(Const.MAIN_CONSTANT_FULL_HEIGHT)
    .backgroundColor($r('app.color.navy_blue'))
  }
}
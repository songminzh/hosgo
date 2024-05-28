import router from '@ohos.router'
import CommonConstants from '../common/CommonConstants'
import ItemData from '../viewmodel/ItemData'
import MainViewModel from  '../viewmodel/MianViewModel'
import SettingCell from './SettingCell'

@Component
export default struct SettingView {
  build() {
    Scroll() {
      Column({ space: CommonConstants.COMMON_SPACE }) {
        // 标题
        Text($r('app.string.mainPage_tabTitles_mine'))
          .fontWeight(FontWeight.Medium)
          .fontSize($r('app.float.page_title_text_size'))
          .margin({ top: $r('app.float.mainPage_tabTitles_margin'), bottom: $r('app.float.mainPage_tabTitles_margin')})
          .padding({ left: $r('app.float.mainPage_tabTitles_padding') })
          .width(CommonConstants.FULL_PARENT)
          .textAlign(TextAlign.Start)

        // 我的
        Row() {
          Image($r('app.media.mine_normal'))
          .width($r('app.float.setting_account_size'))
          .height($r('app.float.setting_account_size'))

          Column(){
            Text($r('app.string.setting_account_name'))
              .fontSize($r('app.float.setting_account_fontSize'))

            Text($r('app.string.setting_account_email'))
              .fontSize($r('app.float.little_text_size'))
              .margin({ top: $r('app.float.setting_name_margin') })
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: $r('app.float.setting_account_margin') })
        }
        .margin({ top: $r('app.float.setting_account_margin') })
        .alignItems(VerticalAlign.Center)
        .width(CommonConstants.FULL_PARENT)
        .height($r('app.float.setting_account_height'))
        .backgroundColor(Color.White)
        .padding({ left: $r('app.float.setting_account_padding') })
        .borderRadius($r('app.float.setting_account_borderRadius'))

        // 列表
        List() {
          ForEach(MainViewModel.getSettingListData(), (item: ItemData) => {
            ListItem() {
              SettingCell({item: item})
            }
          .height($r('app.float.setting_list_height'))
          }, (item: ItemData) => JSON.stringify(item));
        }
        .backgroundColor(Color.White)
        .width(CommonConstants.FULL_PARENT)
        .height(CommonConstants.SET_LIST_WIDTH)
        .divider({
          strokeWidth: $r('app.float.setting_list_strokeWidth'),
          color: Color.Gray,
          startMargin: $r('app.float.setting_list_startMargin'),
          endMargin: $r('app.float.setting_list_endMargin')
        })
        .borderRadius($r('app.float.setting_list_borderRadius'))
        .padding({
          top: $r('app.float.setting_list_padding'),
          bottom: $r('app.float.setting_list_padding')
        })

        Blank()
        // 退出登录按钮
        Button($r('app.string.setting_button'))
          .width(CommonConstants.BUTTON_WIDTH)
          .borderRadius($r('app.float.setting_list_borderRadius'))
          .margin({ bottom: $r('app.float.setting_button_bottom')})
          .fontColor($r('app.color.setting_button_fontColor'))
          .fontSize($r('app.float.normal_text_size'))
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('app.color.setting_button_backgroundColor'))
          .onClick(() => {
            router.replaceUrl({ url:'pages/Login' });
          })
      }
      .height(CommonConstants.FULL_PARENT)
    }
  }
}
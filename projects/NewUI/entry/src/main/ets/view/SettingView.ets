import CommonConstants from '../common/CommonConstants'
import ItemData from '../viewmodel/ItemData'
import MainViewModel from  '../viewmodel/MianViewModel'
import SettingCell from './SettingCell'

@Component
export default struct SettingView {
  build() {
    Scroll() {
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
      .height(CommonConstants.FULL_PARENT)
      .divider({
        strokeWidth: $r('app.float.setting_list_strokeWidth'),
        color: Color.Gray,
        startMargin: $r('app.float.setting_list_startMargin'),
        endMargin: $r('app.float.setting_list_endMargin')
      })
    }
    .borderRadius($r('app.float.setting_list_borderRadius'))
    .padding({
      top: $r('app.float.setting_list_padding'),
      bottom: $r('app.float.setting_list_padding')
    })
  }
}
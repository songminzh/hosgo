import CommonConstants from '../common/CommonConstants';
import ItemData from '../viewmodel/ItemData'

@Component
export default struct SettingCell {
  item: ItemData = new ItemData($r('app.string.mainPage_tabTitles_mine'), $r('app.media.home_selected'));

  build() {
    Row() {
      Row({ space: CommonConstants.COMMON_SPACE} ) {
        Image(this.item.img)
          .width($r('app.float.setting_size'))
          .height($r('app.float.setting_size'))

        Text(this.item.title)
          .fontSize($r('app.float.normal_text_size'))
      }

      if (this.item.others) {
        Toggle({ type: ToggleType.Switch, isOn: false})
          .onChange((isOn: boolean) => {
            isOn = !isOn;
          })
      } else {
        Image($r('app.media.right_grey'))
          .width($r('app.float.setting_jump_width'))
          .height($r('app.float.setting_jump_height'))
      }
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width(CommonConstants.FULL_PARENT)
    .padding({
      left: $r('app.float.setting_settingCell_left'),
      right: $r('app.float.setting_settingCell_right')
    })
  }
}
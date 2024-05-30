import CommonUtils from '../common/utils/CommonUtils';
import CustomItem from '../viewmodel/CustomItem'
import Logger from '../common/utils/Logger'
import CommonConstants from '../common/constants/CommonConstants';

@CustomDialog
export default struct CustomDialogWidget {
  @State items: Array<CustomItem> = [];
  @Link selectedContent: string;
  private controller?: CustomDialogController;

  aboutToAppear(): void {
    let context: Context = getContext(this);
    if (CommonUtils.isEmpty(context) || CommonUtils.isEmpty(context.resourceManager)) {
      Logger.error(CommonConstants.TAG_CUSTOM, 'context or resourceManager is null');
      return;
    }

    let manager = context.resourceManager;
    manager.getStringArrayValue($r('app.strarray.hobbies_data').id, (error, hobbyArray) => {
      if (!CommonUtils.isEmpty(error)) {
        Logger.error(CommonConstants.TAG_CUSTOM, 'error = ' + JSON.stringify(error));
      } else {
        hobbyArray.forEach((itemTitle: string) => {
          let item = new CustomItem();
          item.title = itemTitle;
          item.isChecked = false;
          this.items.push(item);

          Logger.info(item.title);
        });
      }
    });
  }

  build() {
    Column() {
      // 标题
      Text($r('app.string.title_hobbies'))
        .fontSize($r('app.float.title_hobbies_size'))
        .fontColor($r('app.color.custom_color'))
        .lineHeight($r('app.float.title_line_height'))
        .fontWeight(CommonConstants.BIGGER)
        .alignSelf(ItemAlign.Start)
        .margin({ left: $r('app.float.title_left_distance') })

      // 选项列表
      List() {
       ForEach(this.items, (item: CustomItem) => {
         ListItem() {
          Row() {
            Text(item.title)
              .fontSize($r('app.float.label_size'))
              .fontColor($r('app.color.custom_color'))
              .layoutWeight(CommonConstants.WEIGHT_ONE)
              .textAlign(TextAlign.Start)
              .fontWeight(CommonConstants.BIGGER)
              .margin({ left: $r('app.float.label_left_distance') })
            Toggle({ type: ToggleType.Checkbox, isOn: false })
              .onChange((isCheck) => {
                item.isChecked = isCheck;
              })
              .width($r('app.float.toggle_size'))
              .height($r('app.float.toggle_size'))
              .margin({ right: $r('app.float.toggle_right_distance') })
          }
         }
         .height($r('app.float.options_height'))
         .margin({
           top: $r('app.float.options_top_distance'),
           bottom:$r('app.float.options_bottom_distance')
         })
       }, (item: CustomItem) => JSON.stringify(item.title))
      }
      .margin({
        top: $r('app.float.list_top_distance'),
        bottom: $r('app.float.list_bottom_distance')
      })
      .divider({
        strokeWidth: $r('app.float.divider_height'),
        color: $r('app.color.divider_color')
      })
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.None)
      .width(CommonConstants.FULL_WIDTH)
      .height($r('app.float.options_list_height'))

      // 操作按钮
      Row() {
        Button($r('app.string.cancel_button'))
          .dialogButtonStyle()
          .onClick(() => {
            this.controller?.close();
          })

        Blank()
          .backgroundColor($r('app.color.custom_blank_color'))
          .width($r('app.float.blank_width'))
          .opacity($r('app.float.blank_opacity'))
          .height($r('app.float.blank_height'))

        Button($r('app.string.definite_button'))
          .dialogButtonStyle()
          .onClick(() => {
            this.setSelectedItems(this.items);
            this.controller?.close();
          })
      }
    }
  }
  
  setSelectedItems(items: CustomItem[]) {
    if (CommonUtils.isEmpty(items)) {
      Logger.error(CommonConstants.TAG_HOME, "Items is empty")
      return;
    }

    let selectedText: string = items.filter((isCheckedItem: CustomItem) => isCheckedItem?.isChecked)
      .map<string>((checkedItem: CustomItem) => {
        return checkedItem.title!;
      })
      .join(CommonConstants.COMMA);

    if (!CommonUtils.isEmpty(selectedText)) {
      this.selectedContent = selectedText;
    }
  }
}

@Extend(Button)
function dialogButtonStyle() {
  .fontSize($r('app.float.button_text_size'))
  .fontColor(Color.Blue)
  .layoutWeight(CommonConstants.WEIGHT_ONE)
  .height($r('app.float.button_height'))
  .backgroundColor(Color.White)
}
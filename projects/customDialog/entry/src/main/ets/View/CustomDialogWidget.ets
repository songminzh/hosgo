import CommonUtils from '../common/utils/CommonUtils';
import CustomItem from '../viewmodel/CustomItem'
import Logger from '../common/utils/Logger'
import CommonConstants from '../common/constants/CommonConstants';

@CustomDialog
export default struct CustomDialogWidget {
  @State items: Array<CustomItem> = [];
  @Link selectContent: string;
  private controller?: CustomDialogController;

  aboutToAppear(): void {

  }

  build() {
    Column() {
      // 标题
      Text($r('app.string.title_hobbies'))
        .fontSize($r('app.float.title_hobbies_size'))
        .fontColor($r('app.color.custom_color'))



      // 选项列表
      List() {}

      // 操作按钮
      Row() {
        Button($r('app.string.cancel_button'))


        Button($r('app.string.definite_button'))
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
      this.selectContent = selectedText;
    }
  }

}
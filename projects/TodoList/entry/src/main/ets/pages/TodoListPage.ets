
import CommonConstants from '../common/constant/CommonConstant';
import { TodoItem } from '../view/TodoItem';
import DataModel from '../viewModel/DataModel';

@Entry
@Component
struct TodoListPage {
  private totalTasks: Array<string>;

  aboutToAppear() {
    this.totalTasks = DataModel.getData();
  }

  aboutToDisappear() {
    this.totalTasks = null;
  }

  build() {
    Column({ space: CommonConstants.COLUMN_SPACE }) {
      // 标题
      Text($r('app.string.page_title'))
        .fontSize($r('app.float.title_font_size'))
        .fontWeight(FontWeight.Bold)
        .lineHeight($r('app.float.title_font_height'))
        .width(CommonConstants.TITLE_WIDTH)
        .margin(
          {
            top: $r('app.float.title_margin_top'),
            bottom: $r('app.float.title_margin_bottom')
          }
        )
        .textAlign(TextAlign.Start)

      // 待办事项
      ForEach(this.totalTasks, (item: string) => {
        TodoItem({ content: item })
      }, (item: string) => JSON.stringify(item))
    }
    .width(CommonConstants.FULL_LENGTH)
    .height(CommonConstants.FULL_LENGTH)
    .backgroundColor($r('app.color.start_window_background'))
  }
}
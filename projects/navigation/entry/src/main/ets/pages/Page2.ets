import { PageUtils } from '../utils/PageUtils';

@Component
export struct Page2 {
  @Consume('pageStack') pageStack: NavPathStack;

  build() {
    NavDestination() {
      Column() {
        Blank(50)
        Button("返回")
          .onClick(() => {
            this.pageStack.pop()
          })
        Blank(50)
        Button("返回根视图")
          .onClick(() => {
            this.pageStack.clear()
          })
        Blank(50)
        Text(PageUtils.getPageStackInfo(this.pageStack))
      }
    }
    .title("Page2")
  }
}
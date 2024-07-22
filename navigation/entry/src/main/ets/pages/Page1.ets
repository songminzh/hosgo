import { PageUtils } from '../utils/PageUtils';

@Component
export struct Page1 {
  @Consume('pageStack') pageStack: NavPathStack;

  build() {
    NavDestination() {
      Column() {
        Blank(50)
        Button("下一页")
          .onClick(() => {
            this.pageStack.pushPathByName('Page2', "C", (popInfo) => {
              console.log('Pop page name is: ' + popInfo.info.name + ', result: ' + JSON.stringify(popInfo.result))
            });
          })
        Blank(50)
        Button("返回")
          .onClick(() => {
            this.pageStack.pop()
          })
        Blank(50)
        Button("替换 By name")
          .onClick(() => {
            this.pageStack.replacePathByName("Page0", "替换到Page0");
          })
        Blank(50)
        Text(PageUtils.getPageStackInfo(this.pageStack))
      }
    }
    .title('Page1')
  }
}
import { PageUtils } from '../utils/PageUtils';

@Component
export struct Page0 {
  @Consume('pageStack') pageStack: NavPathStack;

  build() {

    NavDestination() {
      Column() {
        Blank(50)
        Button("下一页")
          .onClick(() => {
            this.pageStack.pushPathByName('Page1', "B", (popInfo) => {
              console.log('Pop page name is: ' + popInfo.info.name + ', result: ' + JSON.stringify(popInfo.result))
            });
          })
        Blank(50)
        Button("返回")
          .onClick(() => {
            this.pageStack.pop("agree", true);
          })
        Blank(50)
        Text(PageUtils.getPageStackInfo(this.pageStack))
      }
    }
    .title('Page0')
  }
}
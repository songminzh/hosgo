import { BusinessError } from '@kit.BasicServicesKit';
import { PageUtils } from '../utils/PageUtils';
import { Page0 } from './Page0';
import { Page1 } from './Page1';
import { Page2 } from './Page2';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();
  // 创建一个页面栈对象并传入Navigation
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack()

  @Builder
  pageMap(name: string) {
    if (name === 'Index') {
      Index()
    } else if(name === 'Page0') {
      Page0()
    } else if (name === 'Page1') {
      Page1()
    } else if (name === 'Page2') {
      Page2()
    }
  }
  
  build() {
    Navigation(this.pageStack) {
      Column() {
        Blank(50)
        Button("下一页")
          .onClick(() => {
            let pathInfo : NavPathInfo = new NavPathInfo('Page0', "A");
            this.pageStack.pushDestination(pathInfo);
          })
        Blank(50)
        Text(PageUtils.getPageStackInfo(this.pageStack))
      }
    }
    .title("Index")
    .navDestination(this.pageMap)

  }

}
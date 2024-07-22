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


  // 自定义TabBar
  @Builder
  tabBarBuilder(title: string, index: number, normalIcon: Resource, selectedIcon: Resource) {
    Column() {
      Image(this.currentIndex === index ? selectedIcon : normalIcon)
        .width(24)
        .height(24)
      Text(title)
        .fontFamily('HarmonyHeiTi-Medium')
        .fontSize(10)
        .fontColor(this.currentIndex === index ? '@0A59F7' : 'rgba(0,0,0,0.60)')
        .textAlign(TextAlign.Center)
        .lineHeight(14)
        .fontWeight(500)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.currentIndex = index;
      this.tabsController.changeIndex(index)
    })
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
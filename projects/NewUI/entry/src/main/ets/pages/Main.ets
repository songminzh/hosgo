
import CommonConstants from '../common/CommonConstants'
import HomeView from '../view/HomeView';
import SettingView from '../view/SettingView';

@Extend(TabContent)
function TabContentStyle() {
  .padding({
    left: $r('app.float.mainPage_padding'),
    right: $r('app.float.mainPage_padding')
  })
  .backgroundColor($r('app.color.mainPage_backgroundColor'))
}

@Entry
@Component
struct Mian {
  @State currentIndex: number = CommonConstants.HOME_TAB_INDEX;
  private tabsController: TabsController = new TabsController();

  @Builder TabBuilder(title: string, index: number, selectedImg: Resource, normalImg: Resource) {
    Column() {
      Image(this.currentIndex === index ? selectedImg : normalImg)
        .width($r('app.float.mainPage_baseTab_size'))
        .height($r('app.float.mainPage_baseTab_size'))
      Text(title)
        .margin({ top: $r('app.float.mainPage_baseTab_top') })
        .fontSize($r('app.float.main_tab_fontSize'))
        .fontColor(this.currentIndex === index ? $r('app.color.mainPage_selected') : $r('app.color.mainPage_normal'))
    }
    .justifyContent(FlexAlign.Center)
    .height($r('app.float.mainPage_barHeight'))
    .width(CommonConstants.FULL_PARENT)
    .onClick(() => {
      this.currentIndex = index;
      this.tabsController.changeIndex(this.currentIndex);
    })
  }

  build() {
    Tabs({
      barPosition: BarPosition.End,
      controller: this.tabsController
    }) {
      // 首页
      TabContent() {
        HomeView()
      }
      .TabContentStyle()
      .tabBar(this.TabBuilder(CommonConstants.HOME_TITLE, CommonConstants.HOME_TAB_INDEX, $r('app.media.home_selected'), $r('app.media.home_normal')))

      // 我的
      TabContent() {
        SettingView()
      }
      .TabContentStyle()
      .tabBar(this.TabBuilder(CommonConstants.MINE_TITLE, CommonConstants.MINE_TAB_INDEX, $r('app.media.mine_selected'), $r('app.media.mine_normal')))
    }
    .width(CommonConstants.FULL_PARENT)
    .backgroundColor(Color.White)
    .barHeight($r('app.float.mainPage_barHeight'))
    .barMode(BarMode.Fixed)
    .onChange((index: number) => {
      this.currentIndex = index;
    })
  }
}
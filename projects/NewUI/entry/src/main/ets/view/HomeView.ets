
import CommonConstants from '../common/CommonConstants';
import MainViewModel from '../viewmodel/MianViewModel';
import ItemData from '../viewmodel/ItemData'

@Component
export default struct HomeView {
  private swiperController: SwiperController = new SwiperController();

  build() {
    Scroll() {
      Column({ space: CommonConstants.COMMON_SPACE }) {
        // Title
        Text($r('app.string.mainPage_tabTitles_home'))
          .fontWeight(FontWeight.Medium)
          .fontSize($r('app.float.page_title_text_size'))
          .margin({ top: $r('app.float.mainPage_tabTitles_margin')})
          .padding({ left: $r('app.float.mainPage_tabTitles_padding') })
          .width(CommonConstants.FULL_PARENT)
          .textAlign(TextAlign.Start)

        // 轮播
        Swiper(this.swiperController) {
          ForEach(MainViewModel.getSwiperImages(), (img: Resource) => {
           Image(img).borderRadius($r('app.float.home_swiper_borderRadius'))
          }, (img: Resource) => JSON.stringify(img.id))
        }
        .margin({ top: $r('app.float.home_swiper_margin')} )
        .autoPlay(true)

        // 网格列表一
        Grid() {
          ForEach(MainViewModel.getFirstGridData(), (item: ItemData) => {
            GridItem() {
              Column() {
                Image(item.img)
                  .width($r('app.float.home_homeCell_size'))
                  .height($r('app.float.home_homeCell_size'))

                Text(item.title)
                  .fontSize($r('app.float.little_text_size'))
                  .margin({ top: $r('app.float.home_homeCell_margin') })
              }
            }
          }, (item: ItemData) => JSON.stringify(item))
        }
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .rowsTemplate('1fr 1fr')
        .columnsGap($r('app.float.home_grid_columnsGap'))
        .rowsGap($r('app.float.home_grid_rowGap'))
        .padding({ top: $r('app.float.home_grid_padding'), bottom: $r('app.float.home_grid_padding') })
        .height($r('app.float.home_grid_height'))
        .backgroundColor(Color.White)
        .borderRadius($r('app.float.home_grid_borderRadius'))

        // 列表标题
        Text($r('app.string.home_list'))
        .fontSize($r('app.float.normal_text_size'))
        .fontWeight(FontWeight.Medium)
        .width(CommonConstants.FULL_PARENT)
        .margin({ top: $r('app.float.home_text_margin')})

        // 网格列表二
        Grid() {
          ForEach(MainViewModel.getSecondGridData(), (item: ItemData) => {
            GridItem() {
              Column() {
                Text(item.title)
                  .fontSize($r('app.float.normal_text_size'))
                  .fontWeight(FontWeight.Medium)

                Text(item.others)
                  .margin({ top: $r('app.float.home_list_margin') })
                  .fontSize($r('app.float.little_text_size'))
                  .fontColor($r('app.color.home_grid_fontColor'))
              }
              .alignItems(HorizontalAlign.Start)
            }
            .padding({ top: $r('app.float.home_list_padding'),  left: $r('app.float.home_list_padding') })
            .borderRadius($r('app.float.home_backgroundImage_borderRadius'))
            .align(Alignment.TopStart)
            .backgroundImage(item.img)
            .backgroundImageSize(ImageSize.Cover)
            .width(CommonConstants.FULL_PARENT)
            .height(CommonConstants.FULL_PARENT)
          }, (item: ItemData) => JSON.stringify(item))
        }
        .width(CommonConstants.FULL_PARENT)
        .height($r('app.float.home_secondGrid_height'))
        .columnsTemplate('1fr 1fr')
        .rowsTemplate('1fr 1fr')
        .columnsGap($r('app.float.home_grid_columnsGap'))
        .rowsGap($r('app.float.home_grid_rowGap'))
        .margin({ bottom: $r('app.float.setting_button_bottom') })
      }
    }
    .height(CommonConstants.FULL_PARENT)
  }
}

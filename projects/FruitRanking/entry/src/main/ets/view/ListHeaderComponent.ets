// 表头组件
import { FontSize, ListHeaderStyle } from '../common/Constants'

@Component
export struct ListHeaderComponent {
  paddingValue: Padding | Length = 0;
  widthValue: Length = 0;

  build() {
    Row() {
      // 排名
      Text($r("app.string.page_number"))
        .fontColor($r('app.color.font_description'))
        .fontSize(FontSize.SMALL)
        .width(ListHeaderStyle.LAYOUT_WEIGHT_LEFT)
        .fontWeight(ListHeaderStyle.FONT_WEIGHT) // 字重

      // 种类
      Text($r("app.string.page_type"))
        .fontColor($r('app.color.font_description'))
        .fontSize(FontSize.SMALL)
        .width(ListHeaderStyle.LAYOUT_WEIGHT_CENTER)
        .fontWeight(ListHeaderStyle.FONT_WEIGHT)

      // 得票数
      Text($r("app.string.page_vote"))
        .fontColor($r('app.color.font_description'))
        .fontSize(FontSize.SMALL)
        .width(ListHeaderStyle.LAYOUT_WEIGHT_RIGHT)
        .fontWeight(ListHeaderStyle.FONT_WEIGHT)
    }
    .padding(this.paddingValue)
    .width(this.widthValue)
  }
}
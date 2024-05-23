
import { FontSize, FontWeight, ItemStyle, WEIGHT } from '../common/Constants';
@Component
export struct ListItemComponent {
  index?: number;
  name?: Resource;
  @Prop vote: string;
  @Prop isSwitchDataSource: boolean;
  @State isChange: boolean = false;

  build() {
    Row() {
      // 序号
      Column() {
        if (this.isRenderCircleText()) {
          if (this.index !== undefined) {
            // 圆圈
            Row() {
              Text(this.index?.toString())
                .fontWeight(FontWeight.BOLD)
                .fontSize(FontSize.SMALL)
                .fontColor(Color.White)
            }
            .justifyContent(FlexAlign.Center)
            .borderRadius(ItemStyle.CIRCLE_TEXT_BORDER_RADIUS)
            .size( {
              width: ItemStyle.CIRCLE_TEXT_SIZE,
              height: ItemStyle.CIRCLE_TEXT_SIZE
            } )
            .backgroundColor($r('app.color.circle_text_background'))
          }
        } else {
          // 数字
          Text(this.index?.toString())
            .lineHeight(ItemStyle.TEXT_LAYOUT_SIZE)
            .textAlign(TextAlign.Center)
            .width(ItemStyle.TEXT_LAYOUT_SIZE)
            .fontWeight(FontWeight.BOLD)
            .fontSize(FontSize.SMALL)
        }
      }

      // 名称
      Text(this.name)
        .width(ItemStyle.LAYOUT_WEIGHT_CENTER)
        .fontWeight(FontWeight.BOLDER)
        .fontSize(FontSize.MIDDLE)
        .fontColor(this.isChange ? ItemStyle.COLOR_BLUE : ItemStyle.COLOR_BLACK)

      // 票数
      Text(this.vote)
        .width(ItemStyle.LAYOUT_WEIGHT_RIGHT)
        .fontWeight(FontWeight.BOLD)
        .fontSize(FontSize.SMALL)
        .fontColor(this.isChange ? ItemStyle.COLOR_BLUE : ItemStyle.COLOR_BLACK)
    }
    .height(ItemStyle.BAR_HEIGHT)
    .width(WEIGHT)
    .onClick(() => {
      this.isSwitchDataSource = !this.isSwitchDataSource;
      this.isChange = !this.isChange;
    })
  }

  isRenderCircleText(): boolean {
    // 判断是否为前三名
    return this.index <= 3;
  }

}
@Entry
@Component
struct Index {
  @State message: string = 'hdc2024';

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('hdc2024')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
    }
    .height('100%')
    .width('100%')
  }
}
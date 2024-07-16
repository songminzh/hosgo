import { image } from '@kit.ImageKit'
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ImageOCRUtil } from '../common/utils/ImageOCRUtil';
import { CommonUtils } from '../common/utils/CommonUtils';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct Index {
  private imageSource: image.ImageSource | undefined = undefined;
  @State selectedImage: PixelMap | undefined = undefined;
  @State dataValues: string = '';

  build() {
    Column() {
      // 选中的图片
      Image(this.selectedImage)
        .objectFit(ImageFit.Fill)
        .height('40%')

      // 识别的内容
      Text(this.dataValues)
        .copyOption(CopyOptions.LocalDevice)
        .height('30%')
        .width('90%')
        .margin(10)

      // 选择图片按钮
      Button('选择图片')
        .type(ButtonType.Capsule)
        .fontColor(Color.White)
        .width('80%')
        .margin(10)
        .onClick(() => {
          this.selectImage();
        })

      Button('开始识别')
        .type(ButtonType.Capsule)
        .fontColor(Color.White)
        .alignSelf(ItemAlign.Center)
        .width('80%')
        .margin(10)
        .onClick(() => {
          ImageOCRUtil.recognizeText(this.selectedImage, (content: string) => {
            if (!CommonUtils.isEmpty(content)) {
              this.dataValues = content;
            }

            // 释放内存空间
            this.imageSource?.release();
            this.selectedImage?.release();
          });
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  private async selectImage() {
    let context = getContext(this) as common.Context;
    let uri = await ImageOCRUtil.openAlbum(context);
    if (uri === undefined) {
      hilog.error(0x0000, 'OCR', 'Failed to get the uri of photo.')
      return;
    }

    this.loadImage(uri);
  }

  loadImage(path: string) {
    setTimeout(async () => {
      let fileSource = await fileIo.open(path, fileIo.OpenMode.READ_ONLY);
      this.imageSource = image.createImageSource(fileSource.fd);
      this.selectedImage = await this.imageSource.createPixelMap();
    })
  }

}

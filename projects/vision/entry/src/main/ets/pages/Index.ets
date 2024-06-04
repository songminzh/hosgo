import { image } from '@kit.ImageKit'
import { fileIo, picker } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import fileIO from '@ohos.fileio';
import { textRecognition } from '@kit.CoreVisionKit';

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
        .height('60%')

      // 识别的内容
      Text(this.dataValues)
        .copyOption(CopyOptions.LocalDevice)
        .height('15%')
        .width('60%')
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
          this.recognizeText();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  private async selectImage() {
    let uri = await this.openAlbum();
    if (uri === undefined) {
      hilog.error(0x0000, 'OCR', 'Failed to get the uri of photo.')
      return;
    }

    this.loadImage(uri);
  }

  /**
   * 打开相册选择照片
   * @returns 异步返回照片
   */
  private openAlbum(): Promise<string> {
    return new Promise<string>((resolve, reject) => {
      let photoPicker = new picker.PhotoViewPicker;
      photoPicker.select({
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1
      }).then((res: picker.PhotoSelectResult) => {
        resolve(res.photoUris[0]);
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, "OCR", `Failed to get photo uri, code: ${err.code}, message: ${err.message}`)
        resolve('')
      })
    })
  }

  private loadImage(name: string) {
    setTimeout(async () => {
      let fileSource = await fileIo.open(name, fileIo.OpenMode.READ_ONLY);
      this.imageSource = image.createImageSource(fileSource.fd);
      this.selectedImage = await this.imageSource.createPixelMap();
    })
  }

  private async recognizeText() {
    if (!this.selectedImage) {
      hilog.error(0x0000, 'OCR', 'the image is not existed')
      return;
    }

    let visionInfo: textRecognition.VisionInfo = {
      pixelMap: this.selectedImage
    };

    let textConfiguration: textRecognition.TextRecognitionConfiguration = {
      isDirectionDetectionSupported: false
    };

    textRecognition.recognizeText(visionInfo, textConfiguration, (error: BusinessError, data: textRecognition.TextRecognitionResult) => {
      // 识别成功，获取结果
      if (error.code == 0) {
        let recognitionRes = data.toString();
        // 将识别结果更新到Text中显示
        this.dataValues = data.value;
      }

      // 释放数据
      if (this.selectedImage && this.imageSource) {
        this.selectedImage.release();
        this.imageSource.release();
      }
    });
  }
}

import { textRecognition } from '@kit.CoreVisionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { picker } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';

export class ImageOCRUtil {

  /**
   * 文字识别
   *
   * @param image 图片源数据
   * @param resultCallback 结果返回
   * @returns
   */
  static async recognizeText(image:  PixelMap | undefined, resultCallback: Function) {
    // 非空判断
    if (!image || image === undefined) {
      hilog.error(0x0000, 'OCR', 'the image is not existed');
      return;
    }

    let visionInfo: textRecognition.VisionInfo = {
      pixelMap: image
    };

    let textConfiguration: textRecognition.TextRecognitionConfiguration = {
      isDirectionDetectionSupported: false
    };

    textRecognition.recognizeText(visionInfo, textConfiguration, (error: BusinessError, data: textRecognition.TextRecognitionResult) => {
      // 识别成功，获取结果
      if (error.code == 0) {
        let recognitionRes = data.value.toString();
        // 将识别结果返回
        resultCallback(recognitionRes);
      } else {
        console.error("获取失败：" + error.code + error.data);
      }
    });
  }


  /**
   * 打开相册选择图片
   * @returns 异步返回图片URI
   */
  static openAlbum(context: common.Context): Promise<string> {
    return new Promise<string>((resolve, _) => {
      let photoPicker = new picker.PhotoViewPicker(context);
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
}
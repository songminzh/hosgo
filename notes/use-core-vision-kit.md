[TOC]
# 【拥抱鸿蒙】HarmonyOS NEXT实现双路预览并识别文字

## 名词解释
* Core Vision Kit：基础视觉服务
* Camera Kit：相机服务
* Core File Kit：文件基础服务
* OCR：Optical Character Recognition，通用文字识别或光学字符识别
* URI: Uniform Resource Identifier，资源标识符，本文中URI指图片资源的访问路径

## 核心功能
本篇所涉及的核心功能就是通用文字识别（OCR）。

OCR是通过拍照、扫描等光学输入方式，把各种票据、卡证、表格、报刊、书籍等印刷品文字转化为图像信息，再利用文字识别技术将图像信息转化为计算机等设备可以使用的字符信息的技术。

首先，我们实现从相册选取一张图片，并识别图片上的文字的功能。这一功能的实现基于系统提供的Core Vision Kit中的OCR能力。

1. 创建一个`ImageOCRUtil`类，用于封装OCR相关功能。
从`CoreVisionKit`中导入`textRecognition`模块，声明一个名为`ImageOCRUtil`的类，并创建其`new()`方法。

```ts
import { textRecognition } from '@kit.CoreVisionKit';

export class ImageOCRUtil {}

export default new ImageOCRUtil();
```

2. 在`ImageOCRUtil`中实现图片中文字识别功能。
构建一个异步方法：`async recognizeText(image:  PixelMap | undefined, resultCallback: Function)`，其中`PixelMap`为图像像素类，用于读取或写入图像数据以及获取图像信息。目前pixelmap序列化大小最大128MB，超过会送显失败。大小计算方式为：宽 x 高 x 每像素占用字节数。

```ts
export class ImageOCRUtil {
  /**
   * 文字识别
   * 
   * @param image 图片源数据
   * @param resultCallback 结果返回
   * @returns
   */
  async recognizeText(image:  PixelMap | undefined, resultCallback: Function) {
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
        let recognitionRes = data.toString();
        // 将识别结果返回
        resultCallback(recognitionRes);
      }
    });
  }
}
```

3. 在`ImageOCRUtil`中实现从相册获取图片URI功能。
这里需用到Core File Kit，可借助图片选择器获取图片的存储路径。

```ts
import { picker } from '@kit.CoreFileKit';

/**
  * 打开相册选择图片
  * @returns 异步返回图片URI
  */
openAlbum(): Promise<string> {
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
```

## UI与调用
为了验证图片识别效果，我们可以搭建简单的UI，提供从相册获取图片 -> 文字识别 -> 显示识别结果这一流程的UI与交互。

在`Index`页面中，UI相关的代码如下：

```ts
import { image } from '@kit.ImageKit'
import { hilog } from '@kit.PerformanceAnalysisKit';
import ImageOCRUtil from '../common/utils/ImageOCRUtil';
import CommonUtils from '../common/utils/CommonUtils';
import { fileIo } from '@kit.CoreFileKit';

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
            // 点击“开始识别”
          });
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  private async selectImage() {
    let uri = await ImageOCRUtil.openAlbum();
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
```

在“开始识别”的按钮的点击事件中，我们调用`ImageOCRUtil`的`recognizeText`，并在其回调中显示识别结果。
并对`imageSource`和`selectedImage`进行`release()`释放内存空间。

```ts
ImageOCRUtil.recognizeText(this.selectedImage, (content: string) => {
  if (!CommonUtils.isEmpty(content)) {
    this.dataValues = content;
  }
  
  // 释放内存空间
  this.imageSource?.release();
  this.selectedImage?.release();
});
```

其实现效果如下所示：

![ocrResult](assets/ocrResult.png)

## 双路预览
为了对文字识别这一功能进行扩展，我们可以结合相机的双路预览功能实时获取图片帧，并对图片帧进行文字识别。

我们创建一个`XComponentPage`的页面，添加一个相机预览视图。

1. 获取ImageReceiver组件的SurfaceId。

```ts
async getImageReceiverSurfaceId(receiver: image.ImageReceiver): Promise<string | undefined> {
    let ImageReceiverSurfaceId: string | undefined = undefined;
    if (receiver !== undefined) {
      console.info('receiver is not undefined');
      let ImageReceiverSurfaceId: string = await receiver.getReceivingSurfaceId();
      console.info(`ImageReceived id: ${ImageReceiverSurfaceId}`);
    } else {
      console.error('createImageReceiver failed');
    }
    return ImageReceiverSurfaceId;
  }
```

2. 创建XComponent组件Surface。

```ts
XComponent({
        // 组件的唯一标识
        id: 'LOXComponent',
        // surface:EGL/OpenGLES和媒体数据写入  component:开发者定制绘制内容
        type: XComponentType.SURFACE,
        // 应用Native层编译输出动态库名称，仅XComponent类型为"surface"时有效
        libraryname: 'SingleXComponent',
        // 给组件绑定一个控制器，通过控制器调用组件方法，仅XComponent类型为"surface"时有效
        controller: this.mXComponentController
      })// 插件加载完成时回调事件
        .onLoad(() => {
          // 设置Surface宽高（1920*1080），预览尺寸设置参考前面 previewProfilesArray 获取的当前设备所支持的预览分辨率大小去设置
          // 预览流与录像输出流的分辨率的宽高比要保持一致
          this.mXComponentController.setXComponentSurfaceSize({ surfaceWidth: 1920, surfaceHeight: 1080 });
          // 获取Surface ID
          this.xComponentSurfaceId = this.mXComponentController.getXComponentSurfaceId();
        })// 插件卸载完成时回调事件
        .onDestroy(() => {

        })
        .width("100%")
        .height(display.getDefaultDisplaySync().width * 9 / 16)
```

3. 实现双路预览。

```ts
import camera from '@ohos.multimedia.camera';


async createDualChannelPreview(cameraManager: camera.CameraManager, XComponentSurfaceId: string, receiver: image.ImageReceiver): Promise<void> {
    // 获取支持的相机设备对象
    let camerasDevices: Array<camera.CameraDevice> = cameraManager.getSupportedCameras();

    // 获取支持的模式类型
    let sceneModes: Array<camera.SceneMode> = cameraManager.getSupportedSceneModes(camerasDevices[0]);
    let isSupportPhotoMode: boolean = sceneModes.indexOf(camera.SceneMode.NORMAL_PHOTO) >= 0;
    if (!isSupportPhotoMode) {
      console.error('photo mode not support');
      return;
    }

    // 获取profile对象
    let profiles: camera.CameraOutputCapability = cameraManager.getSupportedOutputCapability(camerasDevices[0], camera.SceneMode.NORMAL_PHOTO); // 获取对应相机设备profiles
    let previewProfiles: Array<camera.Profile> = profiles.previewProfiles;

    // 预览流1
    let previewProfilesObj: camera.Profile = previewProfiles[0];

    // 预览流2
    let previewProfilesObj2: camera.Profile = previewProfiles[0];

    // 创建 预览流1 输出对象
    let previewOutput: camera.PreviewOutput = cameraManager.createPreviewOutput(previewProfilesObj, XComponentSurfaceId);

    // 创建 预览流2 输出对象
    let imageReceiverSurfaceId: string = await receiver.getReceivingSurfaceId();
    let previewOutput2: camera.PreviewOutput = cameraManager.createPreviewOutput(previewProfilesObj2, imageReceiverSurfaceId);

    // 创建cameraInput对象
    let cameraInput: camera.CameraInput = cameraManager.createCameraInput(camerasDevices[0]);

    // 打开相机
    await cameraInput.open();

    // 会话流程
    let photoSession: camera.PhotoSession = cameraManager.createSession(camera.SceneMode.NORMAL_PHOTO) as camera.PhotoSession;

    // 开始配置会话
    photoSession.beginConfig();

    // 把CameraInput加入到会话
    photoSession.addInput(cameraInput);

    // 把 预览流1 加入到会话
    photoSession.addOutput(previewOutput);

    // 把 预览流2 加入到会话
    photoSession.addOutput(previewOutput2);

    // 提交配置信息
    await photoSession.commitConfig();

    // 会话开始
    await photoSession.start();
  }
```

4. 通过ImageReceiver实时获取预览图像。

```ts
  onImageArrival(receiver: image.ImageReceiver): void {
    receiver.on('imageArrival', () => {
      receiver.readNextImage((err: BusinessError, nextImage: image.Image) => {
        if (err || nextImage === undefined) {
          console.error('readNextImage failed');
          return;
        }
        nextImage.getComponent(image.ComponentType.JPEG, async (err: BusinessError, imgComponent: image.Component) => {
          if (err || imgComponent === undefined) {
            console.error('getComponent failed');
          }
          if (imgComponent && imgComponent.byteBuffer as ArrayBuffer) {
            let imageArrayBuffer = imgComponent.byteBuffer as ArrayBuffer;
            console.log("得到图片数据:" + JSON.stringify(imageArrayBuffer))
            console.log("图片数据长度:" + imageArrayBuffer.byteLength)
            
            // do something
          } else {
            console.error('byteBuffer is null');
          }
          nextImage.release();
        })
      })
    })
  }
```


最后，我们对预览返回进行文字识别。预览返回的结果`imageArrayBuffer`的类型为`ArrayBuffer`，我们需要将其转换为`PixelMap`类，然后再调用`recognizeText()`识别。

```ts
// 转换图片格式为PixelMap，并识别其中的文字

            let imageSource: image.ImageSource = image.createImageSource(imageArrayBuffer);
            try {
              let option: image.DecodingOptions = {
                desiredSize: { width: 1920, height: 1080 }
              }
              let imagePm = await imageSource.createPixelMap(option);
              ImageOCRUtil.recognizeText(imagePm, (res: string) => {
                console.info(res);
              });

            } catch (err) {
              console.error(JSON.stringify(err))
            }
```

完整代码见 -> [hosgo-vision](https://github.com/songminzh/hosgo/tree/main/projects/vision)

参考
* [机器学习-基础视觉服务（ArkTS）](https://developer.huawei.com/consumer/cn/codelabsPortal/carddetails/tutorials_Next-CoreVisionKit)
* [指南-Core Vision Kit](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/core-vision-introduction-0000001815834585)
* [通用文字识别](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/text-recognition-guidelines-0000001796771961)
* [双路预览(ArkTS)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/camera-dual-channel-preview-0000001820880033)
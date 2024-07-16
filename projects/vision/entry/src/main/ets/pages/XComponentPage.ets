import camera from '@ohos.multimedia.camera';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';
import display from '@ohos.display';
import { image } from '@kit.ImageKit';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import { ImageOCRUtil } from '../common/utils/ImageOCRUtil';


@Entry
@Component
struct XComponentPage {
  imageReceiver: image.ImageReceiver | null = null;
  mXComponentController: XComponentController = new XComponentController;
  xComponentSurfaceId: string = '';

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
            let imageSource: image.ImageSource = image.createImageSource(imageArrayBuffer);

            // 转换图片格式为PixelMap，并识别其中的文字
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
          } else {
            console.error('byteBuffer is null');
          }
          nextImage.release();
        })
      })
    })
  }

  aboutToAppear(): void {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let context = getContext(this) as common.UIAbilityContext;

    // requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗
    atManager.requestPermissionsFromUser(context, ["ohos.permission.CAMERA"]).then((data) => {

      let grantStatus: Array<number> = data.authResults;
      // let length: number = grantStatus.length;

      if (grantStatus[0] === 0) {
        // 用户授权，可以继续访问目标操作
        let size: image.Size = {
          width: 1920,
          height: 1080
        }
        let contextGet = getContext(this) as common.UIAbilityContext
        let cameraManager = camera.getCameraManager(contextGet);
        this.imageReceiver = image.createImageReceiver(size, image.ImageFormat.JPEG, 8);
        this.createDualChannelPreview(cameraManager, this.xComponentSurfaceId, this.imageReceiver)
        this.onImageArrival(this.imageReceiver)
      } else {
        //用户拒绝了授权
        console.error('用户拒绝授权');
      }
    }).catch((err: BusinessError) => {
      console.error(`Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
      return false;
    })

  }

  build() {
    Column() {
      // 创建XComponent
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

      Button("开始截帧").onClick(() => {
        console.log("用户点击")

        if (this.imageReceiver == null) {
          console.log("获取帧为空")
        }

        console.log(JSON.stringify(this))
      })
    }
  }
}
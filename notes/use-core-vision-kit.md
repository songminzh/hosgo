# 【拥抱鸿蒙】HarmonyOS NEXT识别实时视频预览中的文字

```ts
async onPageShow() { 
  this.startRecord(); 
  await grantPermission().then(res => { 
console.info(TAG, 权限申请成功 ${JSON.stringify(res)}); 
  if (res) { 
    createDualChannelPreview(this.surfaceId, this.receiver); 
  } 
}) 
} 
 
private startRecord() { 
  videoCompressor.startRecorder(getContext(), cameraWidth, cameraHeight) 
    .then((data) => { 
      if (data.code == CompressorResponseCode.SUCCESS) { 
        Logger.debug(“videoCompressor-- record success”); 
      } else { 
Logger.debug(“videoCompressor code:” + data.code + “–error message:” + data.message); 
} 
    }).catch((err: Error) => { 
Logger.debug(“videoCompressor error message” + err.message); 
}); 
} 
onPageHide() { 
videoCompressor.stopRecorder(); // 测试停止录制 
Logger.debug(“onPageHide-- stopRecorder”); 
releaseCamera() 
} 
通过ImageReceiver获取采集到的buffer数据 
function createImageReceiver(): image.ImageReceiver { 
let receiver: image.ImageReceiver = image.createImageReceiver(cameraWidth, cameraHeight, 4, 8); 
receiver.on(‘imageArrival’, () => { 
receiver.readNextImage((err: BusinessError, nextImage: image.Image) => { 
if (err || nextImage === undefined) { 
Logger.error(“receiveImage -error:” + err + " nextImage:" + nextImage); 
return; 
} 
nextImage.getComponent(image.ComponentType.JPEG, (err: BusinessError, imgComponent: image.Component) => { 
if (err || imgComponent === undefined) { 
Logger.error(“receiveImage–getComponent -error:” + err + " imgComponent:" + imgComponent); 
return; 
} 
if (imgComponent.byteBuffer as ArrayBuffer) { 
let buffer = imgComponent.byteBuffer; 
Logger.debug(“receiveImage–byteBuffer -success:” + " buffer:" + buffer); 
recordedFrameCount++; 
Logger.debug(“receiveImage-- record >>pushOneFrameData with no.” + recordedFrameCount + " frame"); 
nextImage.release() //需要将对应的image释放，确保Surface的BufferQueue正常轮转 
} else { 
Logger.debug(“receiveImage–byteBuffer -error:” + " imgComponent.byteBuffer:" + imgComponent.byteBuffer); 
return; 
} 
}); 
}); 
}); 
return receiver; 
}
```


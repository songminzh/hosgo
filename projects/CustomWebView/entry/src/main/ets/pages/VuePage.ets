/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { webview } from '@kit.ArkWeb';
import { router } from '@kit.ArkUI';
import { CommonConstant as Const } from '../common/Constant';

class LinkClass {
  messageFromHtml(value: string) {
    console.log(value)
    AlertDialog.show({
      message: Const.WEB_ALERT_DIALOG_TEXT_VALUE + value,
      confirm: {
        value: $r('app.string.web_alert_dialog_button_value'),
        action: () => {
        }
      },
      cancel: () => {
      }
    });
  }
}

const TITLE: string = '以上为Vue页面';

@Entry
@Component
struct VuePage {
  webController: webview.WebviewController = new webview.WebviewController();
  @State params: object = router.getParams();
  @State linkObj: LinkClass = new LinkClass();

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Image($r('app.media.background'))
        .width(Const.MAIN_CONSTANT_FULL_HEIGHT)
        .height(Const.MAIN_CONSTANT_IMAGE_HEIGHT)
      Row() {
        Column() {
          Row() {
            Image($rawfile('local/img/ic_public_back.png'))
              .width(Const.WEB_CONSTANT_IMAGE_WIDTH)
              .height(Const.WEB_CONSTANT_IMAGE_HEIGHT)
              .margin({ left: Const.WEB_CONSTANT_IMAGE_MARGIN_LEFT })
              .onClick(() => {
                router.back()
              })
            Text($r('app.string.return_home'))
              .fontSize(Const.WEB_CONSTANT_TOP_TEXT_FONT_SIZE)
              .width(Const.WEB_CONSTANT_TOP_TEXT_WIDTH)
              .height(Const.WEB_CONSTANT_TOP_TEXT_HEIGHT)
              .fontColor($r('app.color.black'))
              .margin({ left: Const.WEB_CONSTANT_TOP_TEXT_MARGIN_LEFT })

          }.height(Const.WEB_CONSTANT_TOP_ROW_HEIGHT)

          Web({ src: this.params['path'], controller: this.webController })
            .zoomAccess(false)
            .width(Const.WEB_CONSTANT_WIDTH)
            .aspectRatio(1)
            .margin({
              left: 0, right: Const.WEB_CONSTANT_MARGIN_RIGHT,
              top: Const.WEB_CONSTANT_MARGIN_TOP
            })
            .backgroundColor(Color.Transparent)
            .javaScriptProxy({
              object: this.linkObj,
              name: 'linkObj',
              methodList: ['messageFromHtml'],
              controller: this.webController
            })
          Column() {
            Text(TITLE)
              .fontSize(Const.WEB_CONSTANT_TEXT_VALUE_FONT_SIZE)
              .textAlign(TextAlign.Center)
              .fontColor($r('app.color.text_value_font_color'))
              .height(Const.WEB_CONSTANT_TEXT_VALUE_HEIGHT)
              .fontWeight(Const.WEB_CONSTANT_TEXT_VALUE_FONT_WEIGHT)
              .margin({ top: Const.WEB_CONSTANT_TEXT_VALUE_MARGIN_TOP })
            Text(this.params['tips'])
              .fontSize(Const.WEB_CONSTANT_TIP_TEXT_VALUE_FONT_SIZE)
              .textAlign(TextAlign.Center)
              .fontColor($r('app.color.text_value_font_color'))
              .width(Const.WEB_CONSTANT_TIP_TEXT_VALUE_WIDTH)
              .height(Const.WEB_CONSTANT_TIP_TEXT_VALUE_HEIGHT)
              .opacity(Const.WEB_CONSTANT_TIP_TEXT_VALUE_OPACITY)
              .margin({ top: Const.WEB_CONSTANT_TIP_TEXT_VALUE_MARGIN_TOP })
          }

          Button($r('app.string.btnValue'))
            .fontSize(Const.WEB_CONSTANT_BUTTON_FONT_SIZE)
            .fontColor($r('app.color.start_window_background'))
            .margin({ top: Const.WEB_CONSTANT_BUTTON_MARGIN_TOP })
            .width(Const.WEB_CONSTANT_BUTTON_WIDTH)
            .height(Const.WEB_CONSTANT_BUTTON_HEIGHT)
            .backgroundColor($r('app.color.blue'))
            .borderRadius(Const.WEB_CONSTANT_BUTTON_BORDER_RADIUS)
            .onClick(() => {
              this.webController.runJavaScript('outWeb()');
            })
        }
        .width(Const.WEB_CONSTANT_FULL_WIDTH)
        .height(Const.WEB_CONSTANT_FULL_HEIGHT)
      }
    }
    .backgroundColor($r('app.color.navy_blue'))
  }
}
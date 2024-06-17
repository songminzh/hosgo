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

import { router } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { promptAction } from '@kit.ArkUI';
import { CommonConstant as Const } from '../common/Constant';

class LinkClass {
  messageFromHtml(value: string) {
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

const TITLE: string = '以上为HTML页面';

@Entry
@Component
struct WebPage {
  webController: webview.WebviewController = new webview.WebviewController();
  @State params: object = router.getParams();
  @State progressVal: number = 0;
  @State isLoading: boolean = true;
  @State intervalLoading: number = -1;
  @State linkObj: LinkClass = new LinkClass();

  aboutToAppear() {
    this.intervalLoading = setInterval(() => {
      this.progressVal = this.progressVal >= Const.WEB_CONSTANT_PROGRESS_MAX ?
      Const.WEB_CONSTANT_PROGRESS_MIN : (this.progressVal + Const.WEB_CONSTANT_PROGRESS_STEP);
    }, Const.WEB_CONSTANT_MILLI_SECONDS);
  }

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
                router.back();
              })
            Text($r('app.string.prompts'))
              .fontSize(Const.WEB_CONSTANT_TOP_TEXT_FONT_SIZE)
              .width(Const.WEB_CONSTANT_TOP_TEXT_WIDTH)
              .height(Const.WEB_CONSTANT_TOP_TEXT_HEIGHT)
              .fontColor($r('app.color.black'))
              .margin({ left: Const.WEB_CONSTANT_TOP_TEXT_MARGIN_LEFT })

          }.height(Const.WEB_CONSTANT_TOP_ROW_HEIGHT)

          // Web component loading H5.
          Web({ src: this.params['path'], controller: this.webController })
            .zoomAccess(false)
            .width(Const.WEB_CONSTANT_WIDTH)
            .aspectRatio(1)
            .margin({
              left: Const.WEB_CONSTANT_MARGIN_LEFT, right: Const.WEB_CONSTANT_MARGIN_RIGHT,
              top: Const.WEB_CONSTANT_MARGIN_TOP
            })
            .onErrorReceive((event) => {
              if (event?.error.getErrorInfo() === 'ERR_INTERNET_DISCONNECTED') {
                promptAction.showToast({
                  message: $r('app.string.internet_err'),
                  duration: Const.WEB_CONSTANT_DURATION
                });
              }
              if (event?.error.getErrorInfo() === 'ERR_CONNECTION_TIMED_OUT') {
                promptAction.showToast({
                  message: $r('app.string.internet_err'),
                  duration: Const.WEB_CONSTANT_DURATION
                });
              }
            })
            .onProgressChange((event) => {
              if (event?.newProgress === Const.WEB_CONSTANT_PROGRESS_MAX) {
                this.isLoading = false;
                clearInterval(this.intervalLoading);
                this.intervalLoading = -1;
              }
            })
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
              this.webController.runJavaScript('startDraw()');
            })
        }
        .width(Const.WEB_CONSTANT_FULL_WIDTH)
        .height(Const.WEB_CONSTANT_FULL_HEIGHT)
      }

      if (this.isLoading) {
        Progress({
          value: Const.WEB_CONSTANT_PROGRESS_MIN,
          total: Const.WEB_CONSTANT_PROGRESS_MAX,
          type: ProgressType.ScaleRing
        })
          .color(Color.Grey)
          .value(this.progressVal)
          .width(Const.WEB_CONSTANT_PROGRESS_WIDTH)
          .style({
            strokeWidth: Const.WEB_CONSTANT_PROGRESS_STROKE_WIDTH,
            scaleCount: Const.WEB_CONSTANT_PROGRESS_SCALE_COUNT,
            scaleWidth: Const.WEB_CONSTANT_PROGRESS_SCALE_WIDTH
          })
          .zIndex(1)
          .position({
            x: Const.WEB_CONSTANT_PROGRESS_POSITION_X,
            y: Const.WEB_CONSTANT_PROGRESS_POSITION_Y
          })
      }
    }
    .backgroundColor($r('app.color.navy_blue'))
  }
}
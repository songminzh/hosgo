import CommonConstants from '../common/CommonConstants';
struct Login extends   {
    constructor() {
    }
    otherLogin(type) {
    }
    CustomBtn(src, index) {
            .width($r('app.float.other_login_image_size'))
            .height($r('app.float.other_login_image_size'))
            .backgroundColor($r('app.color.background'))
            .onClick(() => {
            this.otherLogin(index);
        });
    }
    build() {
            .backgroundColor($r('app.color.background'))
            .width(CommonConstants.FULL_PARENT)
            .height(CommonConstants.FULL_PARENT)
            .padding({
            left: $r('app.float.page_padding_hor'),
            right: $r('app.float.page_padding_hor'),
            bottom: $r('app.float.login_page_padding_bottom')
        });
    }
}
//# sourceMappingURL=Login.js.map
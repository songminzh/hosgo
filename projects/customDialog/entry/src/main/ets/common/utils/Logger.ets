import hilog from '@ohos.hilog';
import { BusinessError } from '@kit.BasicServicesKit'
import { JSON } from '@kit.ArkTS';

const LOGGER_DOMAIN: number = 0x0000;
const LOGGER_TAG: string = 'LYXHarmonyLogUtil';

export class LogUtil {
  private domain: number = LOGGER_DOMAIN;
  private tag: string = LOGGER_TAG;
  private format: string = '%{public}s';
  private showLog: boolean = true; // 是否显示日志

  /**
   * 构造器
   * @param domain 领域
   * @param tag 标签
   * @param showLog 是否显示日志
   */
  constructor(domain: number = LOGGER_DOMAIN, tag: string = LOGGER_TAG, showLog: boolean = true) {
    this.domain = domain;
    this.tag = tag;
    this.showLog = showLog;
  }

  /**
   * 设置领域标识，范围是0x0~0xFFFF。（该方法建议在Ability里调用）
   * @param domain 领域
   */
  setDomain(domain: number = LOGGER_DOMAIN) {
    this.domain = domain;
  }

  /**
   * 设置日志标签（该方法建议在Ability里调用）
   * @param tag 标签
   */
  setTag(tag: string = LOGGER_TAG) {
    this.tag = tag;
  }

  /**
   * 是否打印日志（该方法建议在Ability里调用）
   * @param showLog 是否打印日志
   */
  setShowLog(showLog: boolean = true) {
    this.showLog = showLog;
  }

  /**
   * 打印 DEBUG 级别日志
   */
  debug(...args: string[]): void {
    if (this.showLog) {
      hilog.debug(this.domain, this.tag, this.format.repeat(args.length), args);
    }
  }

  /**
   * 打印 INFO 级别日志
   */
  info(...args: string[]): void {
    if (this.showLog) {
      hilog.info(this.domain, this.tag, this.format.repeat(args.length), args);
    }
  }

  /**
   * 打印 WARN 级别日志
   */
  warn(...args: string[]): void {
    if (this.showLog) {
      hilog.warn(this.domain, this.tag, this.format.repeat(args.length), args);
    }
  }

  /**
   * 打印 ERROR 级别日志
   */
  error(...args: string[]): void {
    if (this.showLog) {
      hilog.error(this.domain, this.tag, this.format.repeat(args.length), args);
    }
  }

  /**
   * 打印 FATAL 级别日志
   */
  fatal(...args: string[]): void {
    if (this.showLog) {
      hilog.fatal(this.domain, this.tag, this.format.repeat(args.length), args);
    }
  }

  /**
   * 打印JSON对象和JSON字符串
   * @param obj
   */
  print(obj: object | string) {
    try {
      if (typeof obj === 'object') {
        let jsonStr = JSON.stringify(obj, null, 2);
        let jsonArr: string[] = jsonStr.split('\n')
        for (let index = 0; index < jsonArr.length; index++) {
          // 分别打印JSON数组的元素到控制台
          console.debug(jsonArr[index]);
        }
      } else {
        let newObj = JSON.parse(obj) // 转成JSON对象
        if (newObj != null) {
          let jsonStr = JSON.stringify(newObj, null, 2);
          let jsonArr: string[] = jsonStr.split('\n')
          for (let index = 0; index < jsonArr.length; index++) {
            // 分别打印JSON数组的元素到控制台
            console.debug(jsonArr[index]);
          }
        }
      }
    } catch (e) {
      // 异常，obj不是JSON对象或字符串
      let err = e as  BusinessError;
      this.error(`LogUtil-print-error, code: ${err.code}, message: ${err.message}`)
    }
  }
}

export default new LogUtil(LOGGER_DOMAIN, LOGGER_TAG, true);
import { common } from '@kit.AbilityKit'
import CommonConstants from '../constants/CommonConstants'
import Logger from './Logger'

export class CommonUtils {
  /**
   * Common alert dialog
   * @param title 标题
   * @param msg 提示信息
   * @param context 需要保存状态的UIAbility所对应的context
   * @param primaryCallback 第一个按钮点击事件的回调
   * @param secondCallback 第二个按钮点击事件的回调
   */
  commonAlertDialog(title: ResourceStr, msg: ResourceStr, context: common.UIAbilityContext, primaryCallback: Function, secondCallback: Function) {
    AlertDialog.show({
      title: title,
      message: msg,
      alignment: DialogAlignment.Bottom,
      offset: {
        dx: 0,
        dy: CommonConstants.DY_OFFSET
      },
      primaryButton: {
        value: $r('app.string.cancel_button'),
        action: () => {
          primaryCallback();
        }
      },
      secondaryButton: {
        value: $r('app.string.definite_button'),
        action: () => {
          context.terminateSelf()
          secondCallback();
        }
      }
    });
  }



  /**
   * Date picker dialog
   * @param dateCallback 确认选中日期回调
   */
  datePickerDialog(dateCallback: Function) {
    DatePickerDialog.show({
      start: new Date(CommonConstants.START_TIME),
      end: new Date(),
      selected: new Date(CommonConstants.SELECT_TIME),
      lunar: false,
      onDateAccept: (value: Date) => {
        let year: number = value.getFullYear();
        let month: number = value.getMonth() + 1;
        let day: number = value.getDate();
        let selectedDate: string = `${year}${CommonConstants.DATE_YEAR}`+`${month}${CommonConstants.DATE_MONTH}`+`${day}${CommonConstants.DATE_DAY}`;
        dateCallback(selectedDate);
      }
    });
  }

  /**
   * Text picker dialog
   * @param items 选项
   * @param textCallback 选中返回
   */
  textPickerDialog(items: Resource, textCallback: Function) {
    if (this.isEmpty(items)) {
      Loggerr(CommonConstants.TAG_COMMON_UTILS, 'item is null').erro
      return;
    }

    TextPickerDialog.show({
      range: items,
      canLoop: false,
      selected: 0,
      onAccept: (result: TextPickerResult) => {
        textCallback(result.value);
      },
      onCancel: () => {
        Logger.info(CommonConstants.TAG_COMMON_UTILS, 'TextPickerDialog canceled')
      }
    });
  }


  /**
   * Get default selected date
   *
   * @param {number} year year
   * @param {number} month month
   * @param {number} day day
   * @returns {string} return selected date
   */

  getSelectedDateValue(year: number, month: number, day: number): string {
    return `${year}${CommonConstants.DATE_YEAR}`+`${month}${CommonConstants.DATE_MONTH}`+`${day}${CommonConstants.DATE_DAY}`;
  }

  /**
   * Check if obj is empty
   *
   * @param {object} obj
   * @return {boolean} true(empty)
   */
  isEmpty(obj: object | string): boolean {
    return obj === undefined || obj === null || obj === '';
  }

  /**
   * Check if array is empty
   * @param arr array
   * @returns {boolean} result
   */
  isEmptyArr(arr: Array<object | string>): boolean {
    return this.isEmpty(arr) || arr.length === 0;
  }

}

export default new CommonUtils();



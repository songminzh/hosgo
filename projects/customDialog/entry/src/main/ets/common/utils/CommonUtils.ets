import { common } from '@kit.AbilityKit'
import CommonConstants from '../constants/CommonConstants'
import Logger from './Logger'

export class CommonUtils {
  /**
   * Alert dialog
   * @param context UIAbilityContext
   */
  alertDialog(context: common.UIAbilityContext) {
    AlertDialog.show({
      message: $r('app.string.alert_dialog_message'),
      alignment: DialogAlignment.Bottom,
      offset: {
        dx: 0,
        dy: CommonConstants.DY_OFFSET
      },
      primaryButton: {
        value: $r('app.string.cancel_button'),
        action: () => {
          Logger.info(CommonConstants.TAG_COMMON_UTILS, 'Callback cancel button is clicked')
        }
      },
      secondaryButton: {
        value: $r('app.string.definite_button'),
        action: () => {
          context.terminateSelf()
          Logger.info(CommonConstants.TAG_COMMON_UTILS, 'Callback define button is clicked')
        }
      }
    });
  }

  /**
   * Common alert dialog
   * @param msg
   * @param context
   * @param primaryCallback
   * @param secondCallback
   */
  commonAlertDialog(msg: ResourceStr, context: common.UIAbilityContext, primaryCallback: Function, secondCallback: Function) {
    AlertDialog.show({
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
   * @param dateCallback
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
   * Text picker dialog
   * @param items
   * @param textCallback
   */
  textPickerDialog(items: Resource, textCallback: Function) {
    if (this.isEmpty(items)) {
      Logger.error(CommonConstants.TAG_COMMON_UTILS, 'item is null')
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
   * Check if obj is empty
   *
   * @param {object} obj
   * @return {boolean} true(empty)
   */
  isEmpty(obj: object | string): boolean {
    return obj === undefined || obj === null || obj === '';
  }

  isEmptyArr(arr: Array<object | string>): boolean {
    return this.isEmpty(arr) || arr.length === 0;
  }

}

export default new CommonUtils();


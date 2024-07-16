import { common } from '@kit.AbilityKit'

export class CommonUtils {
  /**
   * Check if obj is empty
   *
   * @param {object} obj
   * @return {boolean} true(empty)
   */
  static isEmpty(obj: object | string): boolean {
    return obj === undefined || obj === null || obj === '';
  }

  /**
   * Check if array is empty
   * @param arr array
   * @returns {boolean} result
   */
  static isEmptyArr(arr: Array<object | string>): boolean {
    return CommonUtils.isEmpty(arr) || arr.length === 0;
  }

}


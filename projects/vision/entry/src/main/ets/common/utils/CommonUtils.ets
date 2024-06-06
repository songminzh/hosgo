import { common } from '@kit.AbilityKit'

export class CommonUtils {
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



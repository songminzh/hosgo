import { Context } from '@kit.AbilityKit';
import { preferences, ValueType } from '@kit.ArkData';
import { GlobalContext } from '../GlobalContext';
import Logger from '../utils/Logger';
import dataPreferences from '@ohos.data.preferences';

const TAG = '[PreferencesUtil]';
const PREFERENCES_NAME = 'myPreferences';
const DATA_GROUP_IDENTIFIER = '';
const KEY_APP_FONT_SIZE = 'appFontSize';

export class PreferencesUtil {

  /**
   * 首选项实例
   * @param key
   * @param value
   */
  sharedPreference(): dataPreferences.Preferences {
    let options: dataPreferences.Options = {
      name: PREFERENCES_NAME,
      dataGroupId: DATA_GROUP_IDENTIFIER
    };

    return dataPreferences.getPreferencesSync(getContext(), options);
  }

  /**
   * 保存数据到首选项
   * @param key
   * @param value
   */
   saveValue(key: string, value: ValueType) {
     let preference = this.sharedPreference();
     try {
       preference.putSync(key, value);
     } catch (err) {
       Logger.error('Save value by preferences error: ${err}')
     }

     preference.flush();
   }

  /**
   * 获取数据到首选项
   * @param key
   * @param defaultValue 默认返回值
   * @returns 数据
   */
  getValue(key: string, defaultValue: ValueType = '') {
    let resValue: string = '';
    let preference = this.sharedPreference();

    try {
      resValue = preference.getSync(key, defaultValue).toString();
    } catch (err) {
      Logger.error('Get value by preferences error: ${err}')
    }

    return resValue;
  }

  /**
   * 从首选项按key移除数据
   * @param key
   */
  removeValue(key: string) {
    let preference = this.sharedPreference();
    try {
      preference.deleteSync(key);
    } catch (err) {
      Logger.error('Remove value by preferences error: ${err}')
    }

    preference.flush();
  }

}



import { AppDialog } from './AppDialog'

/// 弹窗选项参数
export class DialogOption {
  view?: WrappedBuilder<Object[]>      // 自定义弹框
  buildParams?: Object                 // 自定义弹窗内容参数
  param?: Object                       // 打开时传递的参数
  duration?: number                    // 弹窗自动关闭时间
  onPop?: (data: PopInfo) => void      // 接收上一个弹窗关闭时的参数回调
  onBackPressed?: () => boolean        // 侧滑返回拦截
  style?: DialogStyle = DEFAULT_STYLE  // 弹窗样式
  animation?: TransitionEffect         // 弹窗动画
  instance?: AppDialog                 // 弹窗操作对象
}

/// 弹窗样式
export interface DialogStyle {
  transparent: boolean      // 是否透明
  backgroundColor: string   // 背景颜色
  radius: Length            // 圆角
  align: Alignment          // 对齐方式
}

export const DEFAULT_STYLE: DialogStyle = {
  transparent: false,
  backgroundColor: 'rgba(0,0,0,0.5)',
  radius: 5,
  align: Alignment.Center
}
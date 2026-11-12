/**
 * hilog日志工具
 */
import hilog from '@ohos.hilog'

const DOMAIN: number = 0x0001
const TAG: string = 'CourseSchedule'

export class Logger {
  static debug(msg: string): void {
    hilog.debug(DOMAIN, TAG, msg)
  }

  static info(msg: string): void {
    hilog.info(DOMAIN, TAG, msg)
  }

  static warn(msg: string): void {
    hilog.warn(DOMAIN, TAG, msg)
  }

  static error(msg: string): void {
    hilog.error(DOMAIN, TAG, msg)
  }
}

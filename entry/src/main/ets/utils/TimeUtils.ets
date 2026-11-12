/**
 * 时间工具类 - 节次与时间转换
 */
import { SECTION_TIMES, SECTION_START_TIMES, SECTION_END_TIMES } from './Constants'

export class TimeUtils {

  // 根据节次获取时间段字符串
  static getSectionTime(section: number): string {
    if (section >= 1 && section <= SECTION_TIMES.length) {
      return SECTION_TIMES[section - 1]
    }
    return ''
  }

  // 根据节次获取开始时间（分钟数）
  static getSectionStartTime(section: number): number {
    if (section >= 1 && section <= SECTION_START_TIMES.length) {
      return SECTION_START_TIMES[section - 1]
    }
    return 0
  }

  // 根据节次获取结束时间（分钟数）
  static getSectionEndTime(section: number): number {
    if (section >= 1 && section <= SECTION_END_TIMES.length) {
      return SECTION_END_TIMES[section - 1]
    }
    return 0
  }

  // 分钟数转时间字符串
  static minutesToTimeStr(minutes: number): string {
    const h = Math.floor(minutes / 60)
    const m = minutes % 60
    return `${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}`
  }

  // 获取课程的时间范围描述
  static getCourseTimeRange(startSection: number, endSection: number): string {
    const startTime = TimeUtils.getSectionTime(startSection)
    const endTime = TimeUtils.getSectionTime(endSection)
    if (startTime && endTime) {
      // 提取结束时间部分
      const endPart = endTime.split('-')[1]
      const startPart = startTime.split('-')[0]
      return `${startPart}-${endPart}`
    }
    return ''
  }

  // 获取课程持续节数
  static getDuration(startSection: number, endSection: number): number {
    return endSection - startSection + 1
  }
}

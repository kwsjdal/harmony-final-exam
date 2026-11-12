/**
 * 日期工具类 - 获取星期几、当前节次、判断周次等
 */
import { SECTION_START_TIMES, SECTION_END_TIMES, WEEK_DAYS } from './Constants'

export interface SectionItem {
  startSection: number
}

export class DateUtils {

  // 获取今天是星期几（0=周一, 6=周日）
  static getTodayOfWeek(): number {
    const date = new Date()
    let day = date.getDay() - 1
    if (day < 0) {
      day = 6
    }
    return day
  }

  // 获取星期名称
  static getWeekDayName(dayOfWeek: number): string {
    if (dayOfWeek >= 0 && dayOfWeek < WEEK_DAYS.length) {
      return WEEK_DAYS[dayOfWeek]
    }
    return ''
  }

  // 获取当前时间对应的节次（返回0表示不在任何节次时间内）
  static getCurrentSection(): number {
    const now = new Date()
    const currentMinutes = now.getHours() * 60 + now.getMinutes()
    for (let i = 0; i < SECTION_START_TIMES.length; i++) {
      if (currentMinutes >= SECTION_START_TIMES[i] && currentMinutes <= SECTION_END_TIMES[i]) {
        return i + 1
      }
    }
    return 0
  }

  // 获取当前时间的分钟数
  static getCurrentMinutes(): number {
    const now = new Date()
    return now.getHours() * 60 + now.getMinutes()
  }

  // 获取下一节课的节次
  static getNextSection(todayCourses: SectionItem[]): number | null {
    const current = DateUtils.getCurrentSection()
    for (let i = 0; i < todayCourses.length; i++) {
      if (todayCourses[i].startSection > current) {
        return todayCourses[i].startSection
      }
    }
    return null
  }

  // 判断当前周是否在指定周次范围内
  static isInWeekRange(startWeek: number, endWeek: number): boolean {
    const currentWeek = DateUtils.getCurrentWeek()
    return currentWeek >= startWeek && currentWeek <= endWeek
  }

  // 获取当前是第几周（基于学期开始日期计算）
  static getCurrentWeek(): number {
    const now = new Date()
    const semesterStart = new Date(now.getFullYear(), 5, 1) // 学期从6月1日开始（6月1日=周一）
    const diffMs = now.getTime() - semesterStart.getTime()
    const diffDays = Math.floor(diffMs / (24 * 60 * 60 * 1000))
    const week = Math.floor(diffDays / 7) + 1
    return week > 0 ? week : 1
  }

  // 获取当前日期所在周的周一日期
  static getMondayOfCurrentWeek(): Date {
    const now = new Date()
    const day = now.getDay()
    const diff = day === 0 ? -6 : 1 - day
    const monday = new Date(now.getFullYear(), now.getMonth(), now.getDate() + diff)
    monday.setHours(0, 0, 0, 0)
    return monday
  }

  // 根据周次偏移量获取对应周的周一日期（以当前周为基准，offset=0为本周）
  static getMondayByOffset(offset: number): Date {
    const monday = DateUtils.getMondayOfCurrentWeek()
    return new Date(monday.getTime() + offset * 7 * 24 * 60 * 60 * 1000)
  }

  // 格式化日期
  static formatDate(timestamp: number): string {
    const date = new Date(timestamp)
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    return `${year}-${month}-${day}`
  }

  // 格式化日期时间
  static formatDateTime(timestamp: number): string {
    const date = new Date(timestamp)
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    const hour = String(date.getHours()).padStart(2, '0')
    const minute = String(date.getMinutes()).padStart(2, '0')
    return `${year}-${month}-${day} ${hour}:${minute}`
  }

  // 判断时间戳是否是今天
  static isToday(timestamp: number): boolean {
    const date = new Date(timestamp)
    const today = new Date()
    return date.getFullYear() === today.getFullYear() &&
      date.getMonth() === today.getMonth() &&
      date.getDate() === today.getDate()
  }

  // 判断作业是否即将到期（24小时内）
  static isDeadlineSoon(deadline: number): boolean {
    const now = Date.now()
    const diff = deadline - now
    return diff > 0 && diff <= 24 * 60 * 60 * 1000
  }

  // 判断作业是否已过期
  static isOverdue(deadline: number): boolean {
    return Date.now() > deadline
  }
}

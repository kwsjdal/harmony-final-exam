/**
 * 课程服务 - 提供课程CRUD、冲突检测、今日课程、定时提醒等功能
 */
import { CourseModel } from '../models/CourseModel'
import { StorageService } from './StorageService'
import { ReminderService } from './ReminderService'
import { DateUtils } from '../utils/DateUtils'
import { Logger } from '../utils/Logger'
import { SECTION_START_TIMES } from '../utils/Constants'

export class CourseService {
  private static courses: CourseModel[] = []
  private static listeners: Array<(courses: CourseModel[]) => void> = []

  // 添加课程
  static async addCourse(course: CourseModel): Promise<boolean> {
    // 检查冲突
    if (CourseService.checkConflict(course, CourseService.courses)) {
      Logger.warn('Course time conflict detected')
      return false
    }
    CourseService.courses.push(course)
    await CourseService.saveAndNotify()

    // 为课程创建定时提醒（提前1小时）
    await CourseService.scheduleCourseReminder(course)

    Logger.info('Course added: ' + course.name)
    return true
  }

  // 更新课程
  static async updateCourse(course: CourseModel): Promise<boolean> {
    const index = CourseService.courses.findIndex(c => c.id === course.id)
    if (index === -1) {
      Logger.warn('Course not found: ' + course.id)
      return false
    }
    // 检查冲突（排除自身）
    const otherCourses = CourseService.courses.filter(c => c.id !== course.id)
    if (CourseService.checkConflict(course, otherCourses)) {
      Logger.warn('Course time conflict detected')
      return false
    }

    // 取消旧的提醒
    await ReminderService.cancelCourseReminder(course.id)

    CourseService.courses[index] = course
    await CourseService.saveAndNotify()

    // 重新创建提醒
    await CourseService.scheduleCourseReminder(course)

    Logger.info('Course updated: ' + course.name)
    return true
  }

  // 删除课程
  static async deleteCourse(courseId: string): Promise<void> {
    const index = CourseService.courses.findIndex(c => c.id === courseId)
    if (index !== -1) {
      // 取消该课程的提醒
      await ReminderService.cancelCourseReminder(courseId)

      CourseService.courses.splice(index, 1)
      await CourseService.saveAndNotify()
      Logger.info('Course deleted: ' + courseId)
    }
  }

  /**
   * 为课程安排定时提醒（每周重复）
   * @param course - 课程对象
   */
  static async scheduleCourseReminder(course: CourseModel): Promise<void> {
    // 获取当前周次
    const currentWeek = DateUtils.getCurrentWeek()

    // 遍历课程的所有周次，创建提醒
    for (let week = course.startWeek; week <= course.endWeek; week++) {
      // 计算该周课程的具体日期
      const semesterStart = new Date(new Date().getFullYear(), 5, 1) // 学期从6月1日开始
      const daysOffset = (week - 1) * 7 + course.dayOfWeek
      const courseDate = new Date(semesterStart.getTime() + daysOffset * 24 * 60 * 60 * 1000)

      // 获取课程开始时间的分钟数
      const sectionStartMinutes = SECTION_START_TIMES[course.startSection - 1]
      const courseStartTime = new Date(
        courseDate.getFullYear(),
        courseDate.getMonth(),
        courseDate.getDate(),
        Math.floor(sectionStartMinutes / 60),
        sectionStartMinutes % 60
      ).getTime()

      // 提醒时间 = 课程开始前1小时
      const remindTime = courseStartTime - 60 * 60 * 1000

      // 只为当前周及以后的课程创建提醒
      if (remindTime > Date.now()) {
        await ReminderService.addCourseReminder(course, remindTime)
      }
    }
  }

  // 获取所有课程
  static getAllCourses(): CourseModel[] {
    return [...CourseService.courses]
  }

  // 检测课程时间冲突
  static checkConflict(newCourse: CourseModel, courses: CourseModel[]): boolean {
    for (const course of courses) {
      // 同一天
      if (course.dayOfWeek === newCourse.dayOfWeek) {
        // 周次有重叠
        const weekOverlap = !(newCourse.endWeek < course.startWeek || newCourse.startWeek > course.endWeek)
        // 节次有重叠
        const sectionOverlap = !(newCourse.endSection < course.startSection || newCourse.startSection > course.endSection)
        if (weekOverlap && sectionOverlap) {
          return true
        }
      }
    }
    return false
  }

  // 获取今日课程
  static getTodayCourses(): CourseModel[] {
    const todayOfWeek = DateUtils.getTodayOfWeek()
    const currentWeek = DateUtils.getCurrentWeek()
    return CourseService.courses.filter(course => {
      return course.dayOfWeek === todayOfWeek &&
        currentWeek >= course.startWeek &&
        currentWeek <= course.endWeek
    }).sort((a, b) => a.startSection - b.startSection)
  }

  // 获取当前正在进行的课程
  static getCurrentCourse(): CourseModel | null {
    const todayCourses = CourseService.getTodayCourses()
    const currentSection = DateUtils.getCurrentSection()
    for (const course of todayCourses) {
      if (currentSection >= course.startSection && currentSection <= course.endSection) {
        return course
      }
    }
    return null
  }

  // 获取指定星期几的课程
  static getCoursesByDay(dayOfWeek: number): CourseModel[] {
    return CourseService.courses.filter(course => course.dayOfWeek === dayOfWeek)
      .sort((a, b) => a.startSection - b.startSection)
  }

  // 获取某天的课程（考虑周次）
  static getCoursesByDayAndWeek(dayOfWeek: number, week: number): CourseModel[] {
    return CourseService.courses.filter(course => {
      return course.dayOfWeek === dayOfWeek &&
        week >= course.startWeek &&
        week <= course.endWeek
    }).sort((a, b) => a.startSection - b.startSection)
  }

  // 获取所有课程（按星期和节次排序）
  static getAllCoursesSorted(): CourseModel[] {
    return [...CourseService.courses].sort((a, b) => {
      if (a.dayOfWeek !== b.dayOfWeek) {
        return a.dayOfWeek - b.dayOfWeek
      }
      return a.startSection - b.startSection
    })
  }

  // 加载数据
  static async loadCourses(): Promise<void> {
    CourseService.courses = await StorageService.loadCourses()
    Logger.info('CourseService loaded: ' + CourseService.courses.length)
  }

  // 保存并通知
  private static async saveAndNotify(): Promise<void> {
    await StorageService.saveCourses(CourseService.courses)
    CourseService.notifyListeners()
  }

  // 订阅数据变化
  static subscribe(listener: (courses: CourseModel[]) => void): void {
    CourseService.listeners.push(listener)
  }

  // 取消订阅
  static unsubscribe(listener: (courses: CourseModel[]) => void): void {
    const index = CourseService.listeners.indexOf(listener)
    if (index !== -1) {
      CourseService.listeners.splice(index, 1)
    }
  }

  // 通知监听器
  private static notifyListeners(): void {
    for (const listener of CourseService.listeners) {
      listener([...CourseService.courses])
    }
  }
}

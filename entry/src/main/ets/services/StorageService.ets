/**
 * 存储服务 - 使用Preferences封装课程列表和作业列表的存取
 */
import dataPreferences from '@ohos.data.preferences'
import Context from '@ohos.app.ability.common'
import { CourseModel, CourseJSON } from '../models/CourseModel'
import { HomeworkModel, HomeworkJSON } from '../models/HomeworkModel'
import { PREF_COURSES, PREF_HOMEWORKS } from '../utils/Constants'
import { Logger } from '../utils/Logger'

export class StorageService {
  private static preferences: dataPreferences.Preferences = {} as dataPreferences.Preferences
  private static isInitialized: boolean = false
  private static context: Context | null = null

  // 设置上下文（需要在应用启动时调用）
  static setContext(ctx: Context): void {
    StorageService.context = ctx
  }

  // 初始化Preferences
  static async init(): Promise<void> {
    if (StorageService.isInitialized) {
      return
    }
    if (!StorageService.context) {
      Logger.error('StorageService context not set')
      return
    }
    try {
      StorageService.preferences = await dataPreferences.getPreferences(StorageService.context, 'course_schedule')
      StorageService.isInitialized = true
      Logger.info('StorageService init success')
    } catch (err) {
      Logger.error('StorageService init failed: ' + JSON.stringify(err))
    }
  }

  // 保存课程列表
  static async saveCourses(courses: CourseModel[]): Promise<void> {
    await StorageService.init()
    try {
      const jsonArr: CourseJSON[] = courses.map(course => course.toJSON())
      await StorageService.preferences.put(PREF_COURSES, JSON.stringify(jsonArr))
      await StorageService.preferences.flush()
      Logger.info('Courses saved: ' + courses.length)
    } catch (err) {
      Logger.error('Save courses failed: ' + JSON.stringify(err))
    }
  }

  // 加载课程列表
  static async loadCourses(): Promise<CourseModel[]> {
    await StorageService.init()
    try {
      const jsonStr = await StorageService.preferences.get(PREF_COURSES, '[]') as string
      const jsonArr = JSON.parse(jsonStr) as CourseJSON[]
      const courses = jsonArr.map(json => CourseModel.fromJSON(json))
      Logger.info('Courses loaded: ' + courses.length)
      return courses
    } catch (err) {
      Logger.error('Load courses failed: ' + JSON.stringify(err))
      return []
    }
  }

  // 保存作业列表
  static async saveHomeworks(homeworks: HomeworkModel[]): Promise<void> {
    await StorageService.init()
    try {
      const jsonArr: HomeworkJSON[] = homeworks.map(hw => hw.toJSON())
      await StorageService.preferences.put(PREF_HOMEWORKS, JSON.stringify(jsonArr))
      await StorageService.preferences.flush()
      Logger.info('Homeworks saved: ' + homeworks.length)
    } catch (err) {
      Logger.error('Save homeworks failed: ' + JSON.stringify(err))
    }
  }

  // 加载作业列表
  static async loadHomeworks(): Promise<HomeworkModel[]> {
    await StorageService.init()
    try {
      const jsonStr = await StorageService.preferences.get(PREF_HOMEWORKS, '[]') as string
      const jsonArr = JSON.parse(jsonStr) as HomeworkJSON[]
      const homeworks = jsonArr.map(json => HomeworkModel.fromJSON(json))
      Logger.info('Homeworks loaded: ' + homeworks.length)
      return homeworks
    } catch (err) {
      Logger.error('Load homeworks failed: ' + JSON.stringify(err))
      return []
    }
  }

  // 清除所有数据
  static async clearAll(): Promise<void> {
    await StorageService.init()
    try {
      await StorageService.preferences.delete(PREF_COURSES)
      await StorageService.preferences.delete(PREF_HOMEWORKS)
      await StorageService.preferences.flush()
      Logger.info('All data cleared')
    } catch (err) {
      Logger.error('Clear data failed: ' + JSON.stringify(err))
    }
  }
}

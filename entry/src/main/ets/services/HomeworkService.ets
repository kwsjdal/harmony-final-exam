/**
 * 作业服务 - 提供作业CRUD、到期检查、定时提醒等功能
 */
import { HomeworkModel } from '../models/HomeworkModel'
import { StorageService } from './StorageService'
import { ReminderService } from './ReminderService'
import { DateUtils } from '../utils/DateUtils'
import { Logger } from '../utils/Logger'

export class HomeworkService {
  private static homeworks: HomeworkModel[] = []
  private static listeners: Array<(homeworks: HomeworkModel[]) => void> = []

  // 添加作业
  static async addHomework(homework: HomeworkModel): Promise<void> {
    HomeworkService.homeworks.push(homework)
    await HomeworkService.saveAndNotify()

    // 为作业创建定时提醒（截止前1小时）
    await HomeworkService.scheduleHomeworkReminder(homework)

    Logger.info('Homework added: ' + homework.title)
  }

  // 更新作业
  static async updateHomework(homework: HomeworkModel): Promise<void> {
    const index = HomeworkService.homeworks.findIndex(h => h.id === homework.id)
    if (index !== -1) {
      // 取消旧的提醒
      await ReminderService.cancelHomeworkReminder(homework.id)

      HomeworkService.homeworks[index] = homework
      await HomeworkService.saveAndNotify()

      // 重新创建提醒（仅针对未完成的作业）
      if (!homework.isCompleted) {
        await HomeworkService.scheduleHomeworkReminder(homework)
      }

      Logger.info('Homework updated: ' + homework.title)
    }
  }

  // 删除作业
  static async deleteHomework(homeworkId: string): Promise<void> {
    const index = HomeworkService.homeworks.findIndex(h => h.id === homeworkId)
    if (index !== -1) {
      // 取消该作业的提醒
      await ReminderService.cancelHomeworkReminder(homeworkId)

      HomeworkService.homeworks.splice(index, 1)
      await HomeworkService.saveAndNotify()
      Logger.info('Homework deleted: ' + homeworkId)
    }
  }

  // 删除课程的所有作业
  static async deleteHomeworksByCourse(courseId: string): Promise<void> {
    const originalLength = HomeworkService.homeworks.length
    const deletedHomeworks = HomeworkService.homeworks.filter(h => h.courseId === courseId)

    // 取消所有被删除作业的提醒
    for (const hw of deletedHomeworks) {
      await ReminderService.cancelHomeworkReminder(hw.id)
    }

    HomeworkService.homeworks = HomeworkService.homeworks.filter(h => h.courseId !== courseId)
    if (HomeworkService.homeworks.length !== originalLength) {
      await HomeworkService.saveAndNotify()
      Logger.info('Homeworks deleted for course: ' + courseId)
    }
  }

  /**
   * 为作业安排定时提醒（截止前1小时）
   * @param homework - 作业对象
   */
  static async scheduleHomeworkReminder(homework: HomeworkModel): Promise<void> {
    // 提醒时间 = 截止时间前1小时
    const remindTime = homework.deadline - 60 * 60 * 1000

    // 只在提醒时间在未来时创建提醒
    if (remindTime > Date.now()) {
      await ReminderService.addHomeworkReminder(homework, remindTime)
    }
  }

  // 获取所有作业
  static getAllHomeworks(): HomeworkModel[] {
    return [...HomeworkService.homeworks]
  }

  // 获取未完成的作业
  static getUncompletedHomeworks(): HomeworkModel[] {
    return HomeworkService.homeworks.filter(h => !h.isCompleted)
      .sort((a, b) => a.deadline - b.deadline)
  }

  // 获取已完成的作业
  static getCompletedHomeworks(): HomeworkModel[] {
    return HomeworkService.homeworks.filter(h => h.isCompleted)
      .sort((a, b) => b.createTime - a.createTime)
  }

  // 获取今日到期的作业
  static getTodayHomeworks(): HomeworkModel[] {
    return HomeworkService.homeworks.filter(h => !h.isCompleted && DateUtils.isToday(h.deadline))
      .sort((a, b) => a.deadline - b.deadline)
  }

  // 获取即将到期的作业（24小时内）
  static getSoonDeadlines(): HomeworkModel[] {
    return HomeworkService.homeworks.filter(h => !h.isCompleted && DateUtils.isDeadlineSoon(h.deadline))
      .sort((a, b) => a.deadline - b.deadline)
  }

  // 获取已过期的作业
  static getOverdueHomeworks(): HomeworkModel[] {
    return HomeworkService.homeworks.filter(h => !h.isCompleted && DateUtils.isOverdue(h.deadline))
      .sort((a, b) => b.deadline - a.deadline)
  }

  // 标记作业完成
  static async markCompleted(homeworkId: string): Promise<void> {
    const homework = HomeworkService.homeworks.find(h => h.id === homeworkId)
    if (homework) {
      homework.isCompleted = true
      await HomeworkService.saveAndNotify()
      Logger.info('Homework marked completed: ' + homeworkId)
    }
  }

  // 标记作业未完成
  static async markUncompleted(homeworkId: string): Promise<void> {
    const homework = HomeworkService.homeworks.find(h => h.id === homeworkId)
    if (homework) {
      homework.isCompleted = false
      await HomeworkService.saveAndNotify()
      Logger.info('Homework marked uncompleted: ' + homeworkId)
    }
  }

  // 获取指定课程的作业
  static getHomeworksByCourse(courseId: string): HomeworkModel[] {
    return HomeworkService.homeworks.filter(h => h.courseId === courseId)
      .sort((a, b) => a.deadline - b.deadline)
  }

  // 加载数据
  static async loadHomeworks(): Promise<void> {
    HomeworkService.homeworks = await StorageService.loadHomeworks()
    Logger.info('HomeworkService loaded: ' + HomeworkService.homeworks.length)
  }

  // 保存并通知
  private static async saveAndNotify(): Promise<void> {
    await StorageService.saveHomeworks(HomeworkService.homeworks)
    HomeworkService.notifyListeners()
  }

  // 订阅数据变化
  static subscribe(listener: (homeworks: HomeworkModel[]) => void): void {
    HomeworkService.listeners.push(listener)
  }

  // 取消订阅
  static unsubscribe(listener: (homeworks: HomeworkModel[]) => void): void {
    const index = HomeworkService.listeners.indexOf(listener)
    if (index !== -1) {
      HomeworkService.listeners.splice(index, 1)
    }
  }

  // 通知监听器
  private static notifyListeners(): void {
    for (const listener of HomeworkService.listeners) {
      listener([...HomeworkService.homeworks])
    }
  }
}

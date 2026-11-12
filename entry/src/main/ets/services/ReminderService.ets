/**
 * 定时提醒服务 - 使用 reminderAgentManager 实现课程和作业的定时提醒
 */
import reminderAgentManager from '@ohos.reminderAgentManager'
import { Logger } from '../utils/Logger'
import { NotificationService } from './NotificationService'
import { CourseModel } from '../models/CourseModel'
import { HomeworkModel } from '../models/HomeworkModel'
import { TimeUtils } from '../utils/TimeUtils'

// 提醒类型
export enum ReminderType {
  COURSE = 1,   // 课程提醒
  HOMEWORK = 2  // 作业提醒
}

export class ReminderService {
  // 保存所有活跃的提醒ID
  private static activeReminders: Map<string, number> = new Map()

  /**
   * 初始化提醒服务
   */
  static async init(): Promise<void> {
    Logger.info('ReminderService init')
  }

  /**
   * 为课程创建提前1小时的提醒
   * @param course - 课程对象
   * @param remindTime - 提醒时间（课程开始前1小时的时间戳）
   */
  static async addCourseReminder(course: CourseModel, remindTime: number): Promise<void> {
    if (remindTime <= Date.now()) {
      Logger.info('Course reminder time is in the past, skip: ' + course.name)
      return
    }

    try {
      const reminderRequest: reminderAgentManager.ReminderRequestCalendar = {
        reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR,
        dateTime: {
          year: new Date(remindTime).getFullYear(),
          month: new Date(remindTime).getMonth() + 1,
          day: new Date(remindTime).getDate(),
          hour: new Date(remindTime).getHours(),
          minute: new Date(remindTime).getMinutes()
        },
        repeatMonths: [],
        repeatDays: [],
        title: `【课程提醒】${course.name}`,
        content: `课程将在1小时后开始\n📍 ${course.location || '未知地点'}\n👨‍🏫 ${course.teacher || '未知教师'}\n🕐 ${TimeUtils.getCourseTimeRange(course.startSection, course.endSection)} 第${course.startSection}-${course.endSection}节`,
        actionButton: [
          {
            title: '查看课程',
            type: reminderAgentManager.ActionButtonType.ACTION_BUTTON_TYPE_CLOSE
          }
        ],
        wantAgent: {
          pkgName: 'com.example.courseschedule',
          abilityName: 'EntryAbility'
        },
        ringDuration: 5,
        snoozeTimes: 3,
        timeInterval: 5,
      }

      try {
        const reminderId = await reminderAgentManager.publishReminder(reminderRequest)
        const key = `course_${course.id}`
        ReminderService.activeReminders.set(key, reminderId)
        Logger.info('Course reminder added via system: ' + course.name + ', id: ' + reminderId)
      } catch (systemErr) {
        // 模拟器不支持 reminderAgentManager，降级为本地通知
        Logger.warn('reminderAgentManager unavailable, using local notification for course: ' + course.name)
        const title = `【课程提醒】${course.name}`
        const text = `课程将在1小时后开始\n📍 ${course.location || '未知地点'}\n👨‍🏫 ${course.teacher || '未知教师'}\n🕐 ${TimeUtils.getCourseTimeRange(course.startSection, course.endSection)} 第${course.startSection}-${course.endSection}节`
        await NotificationService.sendCourseReminder(title, text)
      }
    } catch (err) {
      Logger.error('Add course reminder failed: ' + JSON.stringify(err))
    }
  }

  /**
   * 为作业创建到期提醒
   * @param homework - 作业对象
   * @param remindTime - 提醒时间（作业截止前的时间戳）
   */
  static async addHomeworkReminder(homework: HomeworkModel, remindTime: number): Promise<void> {
    if (remindTime <= Date.now()) {
      Logger.info('Homework reminder time is in the past, skip: ' + homework.title)
      return
    }

    try {
      const reminderRequest: reminderAgentManager.ReminderRequestCalendar = {
        reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR,
        dateTime: {
          year: new Date(remindTime).getFullYear(),
          month: new Date(remindTime).getMonth() + 1,
          day: new Date(remindTime).getDate(),
          hour: new Date(remindTime).getHours(),
          minute: new Date(remindTime).getMinutes()
        },
        repeatMonths: [],
        repeatDays: [],
        title: `【作业提醒】${homework.title}`,
        content: `作业截止时间即将到来！\n📚 课程：${homework.courseName}\n⏰ 截止：${TimeUtils.minutesToTimeStr(Math.floor(homework.deadline / 60000) % (24 * 60))}`,
        actionButton: [
          {
            title: '查看作业',
            type: reminderAgentManager.ActionButtonType.ACTION_BUTTON_TYPE_CLOSE
          }
        ],
        wantAgent: {
          pkgName: 'com.example.courseschedule',
          abilityName: 'EntryAbility'
        },
        ringDuration: 5,
        snoozeTimes: 3,
        timeInterval: 5,
      }

      try {
        const reminderId = await reminderAgentManager.publishReminder(reminderRequest)
        const key = `homework_${homework.id}`
        ReminderService.activeReminders.set(key, reminderId)
        Logger.info('Homework reminder added via system: ' + homework.title + ', id: ' + reminderId)
      } catch (systemErr) {
        // 模拟器不支持 reminderAgentManager，降级为本地通知
        Logger.warn('reminderAgentManager unavailable, using local notification for homework: ' + homework.title)
        const title = `【作业提醒】${homework.title}`
        const text = `作业截止时间即将到来！\n📚 课程：${homework.courseName}\n⏰ 截止：${TimeUtils.minutesToTimeStr(Math.floor(homework.deadline / 60000) % (24 * 60))}`
        await NotificationService.sendHomeworkReminder(title, text)
      }
    } catch (err) {
      Logger.error('Add homework reminder failed: ' + JSON.stringify(err))
    }
  }

  /**
   * 取消课程的提醒
   * @param courseId - 课程ID
   */
  static async cancelCourseReminder(courseId: string): Promise<void> {
    const key = `course_${courseId}`
    const reminderId = ReminderService.activeReminders.get(key)

    if (reminderId !== undefined) {
      try {
        await reminderAgentManager.cancelReminder(reminderId)
        ReminderService.activeReminders.delete(key)
        Logger.info('Course reminder cancelled: ' + courseId)
      } catch (err) {
        Logger.error('Cancel course reminder failed: ' + JSON.stringify(err))
      }
    }
  }

  /**
   * 取消作业的提醒
   * @param homeworkId - 作业ID
   */
  static async cancelHomeworkReminder(homeworkId: string): Promise<void> {
    const key = `homework_${homeworkId}`
    const reminderId = ReminderService.activeReminders.get(key)

    if (reminderId !== undefined) {
      try {
        await reminderAgentManager.cancelReminder(reminderId)
        ReminderService.activeReminders.delete(key)
        Logger.info('Homework reminder cancelled: ' + homeworkId)
      } catch (err) {
        Logger.error('Cancel homework reminder failed: ' + JSON.stringify(err))
      }
    }
  }

  /**
   * 取消指定课程的所有周次的提醒
   * @param courseId - 课程ID
   */
  static async cancelAllCourseReminders(courseId: string): Promise<void> {
    await ReminderService.cancelCourseReminder(courseId)
  }

  /**
   * 取消所有提醒
   */
  static async cancelAllReminders(): Promise<void> {
    try {
      await reminderAgentManager.cancelAllReminders()
      ReminderService.activeReminders.clear()
      Logger.info('All reminders cancelled')
    } catch (err) {
      Logger.error('Cancel all reminders failed: ' + JSON.stringify(err))
    }
  }

  /**
   * 获取所有活跃的提醒数量
   */
  static getActiveReminderCount(): number {
    return ReminderService.activeReminders.size
  }
}

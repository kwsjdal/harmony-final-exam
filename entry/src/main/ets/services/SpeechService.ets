/**
 * 语音播报服务 - 课程信息语音播报
 * 使用对话框展示播报内容，作为TTS的降级实现
 */
import { Logger } from '../utils/Logger'
import { CourseModel } from '../models/CourseModel'
import promptAction from '@ohos.promptAction'

// 定义TTS状态枚举
export enum TtsState {
  IDLE = 0,
  PLAYING = 1,
  PAUSED = 2
}

export class SpeechService {
  private static state: TtsState = TtsState.IDLE
  private static currentText: string = ''

  static init(): boolean {
    try {
      Logger.info('SpeechService init')
      SpeechService.state = TtsState.IDLE
      return true
    } catch (err) {
      Logger.error('SpeechService init failed: ' + JSON.stringify(err))
      return false
    }
  }

  static getState(): TtsState {
    return SpeechService.state
  }

  static generateTodayCoursesText(courses: CourseModel[]): string {
    if (courses.length === 0) {
      return '今日暂无课程安排。'
    }

    let text: string = `今日共有${courses.length}节课。`

    for (let i = 0; i < courses.length; i++) {
      const course: CourseModel = courses[i]
      text += `第${i + 1}节，${course.name}，`
      if (course.teacher) {
        text += `教师${course.teacher}，`
      }
      if (course.location) {
        text += `上课地点${course.location}，`
      }
      text += `从第${course.startSection}节到第${course.endSection}节。`
    }

    return text
  }

  static async speak(text: string): Promise<void> {
    try {
      if (SpeechService.state === TtsState.PLAYING) {
        promptAction.showToast({ message: '正在播报中...' })
        return
      }

      SpeechService.currentText = text
      SpeechService.state = TtsState.PLAYING

      // 使用对话框展示播报内容
      promptAction.showDialog({
        title: '语音播报',
        message: text,
        buttons: [{ text: '确定', color: '#1890FF' }]
      }).then(() => {
        SpeechService.state = TtsState.IDLE
      })

      Logger.info('TTS speak: ' + text)
    } catch (err) {
      Logger.error('TTS speak error: ' + JSON.stringify(err))
      SpeechService.state = TtsState.IDLE
    }
  }

  static async speakTodayCourses(courses: CourseModel[]): Promise<void> {
    const text: string = SpeechService.generateTodayCoursesText(courses)
    await SpeechService.speak(text)
  }

  static async stop(): Promise<void> {
    SpeechService.state = TtsState.IDLE
    Logger.info('TTS stopped')
  }

  static release(): void {
    SpeechService.state = TtsState.IDLE
  }
}

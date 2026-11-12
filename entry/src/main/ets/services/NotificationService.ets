/**
 * 通知服务 - 系统通知栏横幅提醒
 */
import notificationManager from '@ohos.notificationManager'
import { Logger } from '../utils/Logger'
import wantAgent from '@ohos.wantAgent'

class WantData {
  bundleName: string = ''
  abilityName: string = ''
}

class WantAgentParams {
  wants: WantData[] = []
  operationType: number = 0
  requestCode: number = 0
  wantAgentFlags: number[] = []
}

class NotifyNormalData {
  title: string = ''
  text: string = ''
}

class NotifyContentData {
  notificationContentType: number = 0
  normal: NotifyNormalData | null = null
}

class NotifyRequestParams {
  id: number = 0
  content: NotifyContentData | null = null
  wantAgent: Object | null = null
  notificationSlotType: number = 0
}

export class NotificationService {
  private static noticeId: number = 1000

  static async init(): Promise<void> {
    Logger.info('NotificationService init')
  }

  static sendCourseReminder(title: string, text: string): void {
    NotificationService.noticeId++
    NotificationService.send(title, text, NotificationService.noticeId)
  }

  static sendHomeworkReminder(title: string, text: string): void {
    NotificationService.noticeId++
    NotificationService.send(title, text, NotificationService.noticeId)
  }

  private static send(title: string, text: string, id: number): void {
    const agentParams = new WantAgentParams()
    const wantData = new WantData()
    wantData.bundleName = 'com.example.courseschedule'
    wantData.abilityName = 'EntryAbility'
    agentParams.wants = [wantData]
    agentParams.operationType = 0
    agentParams.requestCode = id
    agentParams.wantAgentFlags = [0]

    wantAgent.getWantAgent(agentParams, (err: Object, agent: Object) => {
      if (err) {
        Logger.error('WantAgent failed: ' + JSON.stringify(err))
        return
      }

      const normalData = new NotifyNormalData()
      normalData.title = title
      normalData.text = text

      const contentData = new NotifyContentData()
      contentData.notificationContentType = 0
      contentData.normal = normalData

      const notifyReq = new NotifyRequestParams()
      notifyReq.id = id
      notifyReq.content = contentData
      notifyReq.wantAgent = agent
      notifyReq.notificationSlotType = 0

      notificationManager.publish(notifyReq, (pubErr: Object) => {
        if (pubErr) {
          Logger.error('Publish FAILED: ' + JSON.stringify(pubErr))
        } else {
          Logger.info('Publish SUCCESS: ' + title)
        }
      })
    })
  }

  static async cancelAllReminders(): Promise<void> {
    try {
      await notificationManager.cancelAll()
      Logger.info('All notifications cancelled')
    } catch (err) {
      Logger.error('Cancel all failed: ' + JSON.stringify(err))
    }
  }
}

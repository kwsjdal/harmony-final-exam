/**
 * 设置页面 - 应用设置和数据管理中心，包含统计信息和数据操作
 */
import { StorageService } from '../services/StorageService'
import { CourseService } from '../services/CourseService'
import { HomeworkService } from '../services/HomeworkService'
import { NotificationService } from '../services/NotificationService'
import { BottomNavBar } from '../components/BottomNavBar'
import promptAction from '@ohos.promptAction'

@Entry
@Component
struct Settings {
  @State courseCount: number = 0   // 课程数量
  @State homeworkCount: number = 0 // 作业数量

  /**
   * 组件显示前加载统计数据
   */
  aboutToAppear() {
    this.loadStats()
  }

  /**
   * 加载统计数据
   */
  loadStats() {
    this.courseCount = CourseService.getAllCourses().length
    this.homeworkCount = HomeworkService.getAllHomeworks().length
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Text('设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 16 })
      .backgroundColor('#FFFFFF')

      // 统计信息
      Row() {
        Column() {
          Text(this.courseCount.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1890FF')
          Text('课程数')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .layoutWeight(1)

        Column() {
          Text(this.homeworkCount.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#52C41A')
          Text('作业数')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .layoutWeight(1)

        Column() {
          Text(HomeworkService.getOverdueHomeworks().length.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF4D4F')
          Text('逾期数')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ top: 20, bottom: 20 })
      .backgroundColor('#FFFFFF')

      // 设置项
      List() {
        ListItem() {
          this.buildSettingItem('清空课程数据', '删除所有课程', async () => {
            AlertDialog.show({
              title: '确认清空',
              message: '确定要清空所有课程数据吗？此操作不可恢复。',
              primaryButton: {
                value: '取消',
                action: () => {}
              },
              secondaryButton: {
                value: '清空',
                action: async () => {
                  const courses = CourseService.getAllCourses()
                  for (const course of courses) {
                    await CourseService.deleteCourse(course.id)
                    await HomeworkService.deleteHomeworksByCourse(course.id)
                  }
                  this.loadStats()
                  promptAction.showToast({ message: '课程数据已清空' })
                }
              }
            })
          })
        }

        ListItem() {
          this.buildSettingItem('清空作业数据', '删除所有作业', async () => {
            AlertDialog.show({
              title: '确认清空',
              message: '确定要清空所有作业数据吗？此操作不可恢复。',
              primaryButton: {
                value: '取消',
                action: () => {}
              },
              secondaryButton: {
                value: '清空',
                action: async () => {
                  const homeworks = HomeworkService.getAllHomeworks()
                  for (const hw of homeworks) {
                    await HomeworkService.deleteHomework(hw.id)
                  }
                  this.loadStats()
                  promptAction.showToast({ message: '作业数据已清空' })
                }
              }
            })
          })
        }

        ListItem() {
          this.buildSettingItem('重置所有数据', '清空课程和作业', async () => {
            AlertDialog.show({
              title: '确认重置',
              message: '确定要重置所有数据吗？此操作不可恢复。',
              primaryButton: {
                value: '取消',
                action: () => {}
              },
              secondaryButton: {
                value: '重置',
                action: async () => {
                  await StorageService.clearAll()
                  await CourseService.loadCourses()
                  await HomeworkService.loadHomeworks()
                  this.loadStats()
                  promptAction.showToast({ message: '所有数据已重置' })
                }
              }
            })
          })
        }

        ListItem() {
          this.buildSettingItem('关闭所有通知', '取消课程和作业提醒', async () => {
            await NotificationService.cancelAllReminders()
            promptAction.showToast({ message: '所有通知已关闭' })
          })
        }
      }
      .width('100%')
      .padding({ top: 12 })
      .divider({ strokeWidth: 0.5, color: '#EEEEEE' })

      // 关于
      Column() {
        Text('课程表与学习助手')
          .fontSize(14)
          .fontColor('#666666')
        Text('Version 1.0.0')
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 4 })
        Text('基于HarmonyOS Next开发')
          .fontSize(12)
          .fontColor('#BBBBBB')
          .margin({ top: 8 })
      }
      .width('100%')
      .padding({ top: 20, bottom: 20 })
      .justifyContent(FlexAlign.Center)

      BottomNavBar(3)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  /**
   * 构建设置项组件
   * @param title - 主标题
   * @param subtitle - 副标题（说明）
   * @param onClick - 点击回调
   */
  @Builder
  buildSettingItem(title: string, subtitle: string, onClick: () => void) {
    Row() {
      Column() {
        Text(title)
          .fontSize(15)
          .fontColor('#333333')
        Text(subtitle)
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 箭头指示
      Text('→')
        .fontSize(18)
        .fontColor('#CCCCCC')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .backgroundColor('#FFFFFF')
    .onClick(onClick)
  }
}

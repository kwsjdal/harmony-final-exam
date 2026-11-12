/**
 * 首页 - 应用主入口页面，包含今日课程列表和周课表两种视图切换
 */
import { CourseModel } from '../models/CourseModel'
import { CourseService } from '../services/CourseService'
import { HomeworkService } from '../services/HomeworkService'
import { SpeechService } from '../services/SpeechService'
import { ShareService } from '../services/ShareService'
import { NotificationService } from '../services/NotificationService'
import { TodayCourseList } from '../components/TodayCourseList'
import { TimetableGrid } from '../components/TimetableGrid'
import { AddCourseDialog } from '../components/AddCourseDialog'
import { ShareCourseDialog } from '../components/ShareCourseDialog'
import { BottomNavBar } from '../components/BottomNavBar'
import { DateUtils } from '../utils/DateUtils'
import { WEEK_DAYS } from '../utils/Constants'
import promptAction from '@ohos.promptAction'

@Entry
@Component
struct Index {
  // === 页面状态 ===
  @State currentView: number = 0        // 视图模式（0:今日课程, 1:周课表）
  @State courses: CourseModel[] = []    // 所有课程列表
  @State todayCourses: CourseModel[] = [] // 今日课程列表
  @State currentWeek: number = 1        // 当前周次
  @State soonDeadlines: number = 0      // 即将到期的作业数量

  // === 添加/编辑课程弹窗状态 ===
  @State showAddDialog: boolean = false
  @State editCourse: CourseModel | null = null
  @State courseName: string = ''
  @State teacher: string = ''
  @State location: string = ''
  @State dayOfWeek: number = 0
  @State startSection: number = 1
  @State endSection: number = 2
  @State startWeek: number = 1
  @State endWeek: number = 16
  @State selectedColor: string = '#FF6B6B'

  // === 分享弹窗状态 ===
  @State showShareDialog: boolean = false

  // === 应用内横幅通知 ===
  @State showBanner: boolean = false
  @State bannerTitle: string = ''
  @State bannerText: string = ''

  /**
   * 组件显示前初始化数据
   */
  aboutToAppear() {
    this.loadData()
    CourseService.subscribe((courses) => {
      this.courses = courses
      this.todayCourses = CourseService.getTodayCourses()
    })
    HomeworkService.subscribe((homeworks) => {
      this.soonDeadlines = HomeworkService.getSoonDeadlines().length
    })
  }

  aboutToDisappear() {
    CourseService.unsubscribe(() => {})
    HomeworkService.unsubscribe(() => {})
  }

  async loadData() {
    await CourseService.loadCourses()
    await HomeworkService.loadHomeworks()
    this.courses = CourseService.getAllCourses()
    this.todayCourses = CourseService.getTodayCourses()
    this.currentWeek = DateUtils.getCurrentWeek()
    this.soonDeadlines = HomeworkService.getSoonDeadlines().length
  }

  onPageShow() {
    this.todayCourses = CourseService.getTodayCourses()
    this.courses = CourseService.getAllCourses()
    this.soonDeadlines = HomeworkService.getSoonDeadlines().length
  }

  build() {
    Stack() {
      Column() {
        // 顶部标题栏
        Row() {
          Column() {
            Text('今日课程')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1A1A1A')
            Text(DateUtils.formatDate(Date.now()) + ' ' + WEEK_DAYS[DateUtils.getTodayOfWeek()])
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          // 演示提醒按钮
          Button() {
            Text('🔔')
              .fontSize(16)
          }
          .backgroundColor('#FFF7E6')
          .borderRadius(14)
          .width(36)
          .height(28)
          .margin({ left: 8 })
          .onClick(() => {
            this.demoReminder()
          })

          // 语音播报按钮
          Button() {
            Text('🔊')
              .fontSize(16)
          }
          .backgroundColor('rgba(24, 144, 255, 0.08)')
          .borderRadius(14)
          .width(36)
          .height(28)
          .margin({ left: 8 })
          .onClick(() => {
            this.speakTodayCourses()
          })

          // 分享按钮
          Button() {
            Text('📤')
              .fontSize(16)
          }
          .backgroundColor('rgba(24, 144, 255, 0.08)')
          .borderRadius(14)
          .width(36)
          .height(28)
          .margin({ left: 8 })
          .onClick(() => {
            this.showShareDialog = true
          })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 4 })

        // 分段控制器
        Row() {
          Text('今日')
            .fontSize(14)
            .fontWeight(this.currentView === 0 ? FontWeight.Medium : FontWeight.Normal)
            .fontColor(this.currentView === 0 ? '#FFFFFF' : '#666666')
            .backgroundColor(this.currentView === 0 ? '#1890FF' : '#F2F2F2')
            .padding({ left: 22, right: 22, top: 6, bottom: 6 })
            .borderRadius({ topLeft: 16, bottomLeft: 16 })
            .onClick(() => { this.currentView = 0 })
          Text('课表')
            .fontSize(14)
            .fontWeight(this.currentView === 1 ? FontWeight.Medium : FontWeight.Normal)
            .fontColor(this.currentView === 1 ? '#FFFFFF' : '#666666')
            .backgroundColor(this.currentView === 1 ? '#1890FF' : '#F2F2F2')
            .padding({ left: 22, right: 22, top: 6, bottom: 6 })
            .borderRadius({ topRight: 16, bottomRight: 16 })
            .onClick(() => { this.currentView = 1 })
        }
        .width('100%')
        .padding({ left: 20, right: 20, bottom: 8 })

        // 视图内容
        if (this.currentView === 0) {
          TodayCourseList({
            courses: this.todayCourses
          })
        } else {
          // 课表视图
          TimetableGrid({
            courses: this.courses,
            currentWeek: this.currentWeek,
            onWeekChange: (week: number): void => {
              this.currentWeek = week
            }
          })
        }

        BottomNavBar(0)
      }
      .width('100%')
      .height('100%')

      // 应用内横幅通知 - 从顶部滑出模拟系统横幅
      if (this.showBanner) {
        Column() {
          Row() {
            Column() {
              Text(this.bannerTitle)
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text(this.bannerText)
                .fontSize(12)
                .fontColor('rgba(255, 255, 255, 0.85)')
                .margin({ top: 2 })
                .maxLines(3)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor('#333333')
          .borderRadius(12)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.3)', offsetY: 4 })
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 48 })
        .position({ top: 0, left: 0 })
        .zIndex(999)
        .transition({
          type: TransitionType.Insert,
          translate: { y: -200 }
        })
        .onClick(() => {
          this.showBanner = false
        })
      }

      // 添加课程弹窗
      AddCourseDialog({
        isShow: $showAddDialog,
        courseName: $courseName,
        teacher: $teacher,
        location: $location,
        dayOfWeek: $dayOfWeek,
        startSection: $startSection,
        endSection: $endSection,
        startWeek: $startWeek,
        endWeek: $endWeek,
        selectedColor: $selectedColor,
        editCourse: this.editCourse,
        onSave: (course): Promise<void> => this.saveCourse(course)
      })

      // 分享对话框
      ShareCourseDialog({
        isShow: $showShareDialog,
        courses: this.courses,
        currentWeek: this.currentWeek
      })
    }
    .width('100%')
    .height('100%')
  }

  showEditDialog(course: CourseModel) {
    this.editCourse = course
    this.courseName = course.name
    this.teacher = course.teacher
    this.location = course.location
    this.dayOfWeek = course.dayOfWeek
    this.startSection = course.startSection
    this.endSection = course.endSection
    this.startWeek = course.startWeek
    this.endWeek = course.endWeek
    this.selectedColor = course.color
    this.showAddDialog = true
  }

  async saveCourse(course: CourseModel) {
    if (this.editCourse) {
      await CourseService.updateCourse(course)
    } else {
      await CourseService.addCourse(course)
    }
    this.editCourse = null
    this.todayCourses = CourseService.getTodayCourses()
    this.courses = CourseService.getAllCourses()
  }

  /**
   * 显示应用内横幅
   */
  showBannerNotification(title: string, text: string, duration: number): void {
    this.bannerTitle = title
    this.bannerText = text
    this.showBanner = true
    setTimeout(() => {
      this.showBanner = false
    }, duration)
  }

  /**
   * 演示提醒 - 应用内横幅 + 系统通知栏 + Toast语音播报，三通道同时触发
   */
  demoReminder(): void {
    const todayCourses = CourseService.getTodayCourses()
    const homeworks = HomeworkService.getAllHomeworks()

    let courseTitle: string
    let courseText: string
    if (todayCourses.length > 0) {
      const c = todayCourses[0]
      courseTitle = `【上课提醒】${c.name}`
      courseText = `距上课还有1小时\n📍${c.location || '未知地点'}  👨‍🏫${c.teacher || '未知教师'}\n🕐第${c.startSection}-${c.endSection}节`
    } else {
      courseTitle = '【上课提醒】高等数学'
      courseText = '距上课还有1小时\n📍教学楼A201  👨‍🏫张教授\n🕐第1-2节'
    }

    let homeworkTitle: string
    let homeworkText: string
    if (homeworks.length > 0) {
      const h = homeworks[0]
      homeworkTitle = `【作业提醒】${h.title}`
      homeworkText = `距截止还有1小时\n📚${h.courseName}`
    } else {
      homeworkTitle = '【作业提醒】课后习题第三章'
      homeworkText = '距截止还有1小时\n📚高等数学'
    }

    // 立即：应用内横幅 + 系统通知 + Toast 三通道触发
    this.showBannerNotification(courseTitle, courseText, 4000)
    NotificationService.sendCourseReminder(courseTitle, courseText)
    promptAction.showToast({ message: `📗 ${courseTitle}` })

    // 4秒后：作业横幅 + 系统通知
    setTimeout(() => {
      this.showBannerNotification(homeworkTitle, homeworkText, 4000)
      NotificationService.sendHomeworkReminder(homeworkTitle, homeworkText)
      promptAction.showToast({ message: `📝 ${homeworkTitle}` })
    }, 4000)
  }
  async speakTodayCourses(): Promise<void> {
    await SpeechService.init()
    const todayCourses = CourseService.getTodayCourses()

    if (todayCourses.length === 0) {
      promptAction.showToast({ message: '今日无课程' })
      await SpeechService.speak('今日暂无课程安排')
    } else {
      await SpeechService.speakTodayCourses(todayCourses)
      promptAction.showToast({ message: '正在播报今日课程' })
    }
  }
}
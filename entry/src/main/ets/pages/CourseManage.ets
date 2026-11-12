/**
 * 课程管理页面 - 管理课程的增删改查，支持按星期筛选
 */
import { CourseModel } from '../models/CourseModel'
import { CourseService } from '../services/CourseService'
import { HomeworkService } from '../services/HomeworkService'
import { AddCourseDialog } from '../components/AddCourseDialog'
import { BottomNavBar } from '../components/BottomNavBar'
import { WEEK_DAYS, COURSE_COLORS } from '../utils/Constants'
import { DateUtils } from '../utils/DateUtils'
import { TimeUtils } from '../utils/TimeUtils'
import promptAction from '@ohos.promptAction'

@Entry
@Component
struct CourseManage {
  // === 页面状态 ===
  @State courses: CourseModel[] = []
  @State filterDay: number = -1

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

  aboutToAppear() {
    this.loadCourses()
    CourseService.subscribe((courses) => {
      this.courses = courses
    })
  }

  aboutToDisappear() {
    CourseService.unsubscribe(() => {})
  }

  loadCourses() {
    this.courses = CourseService.getAllCoursesSorted()
  }

  getFilteredCourses(): CourseModel[] {
    const list = this.courses || []
    return this.filterDay === -1 ? list : list.filter(c => c.dayOfWeek === this.filterDay)
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航
        Row() {
          Text('课程管理')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')
          Blank()
          Button() {
            Text('+ 添加')
              .fontSize(13)
              .fontColor('#1890FF')
          }
          .backgroundColor('rgba(24, 144, 255, 0.08)')
          .borderRadius(14)
          .height(28)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            this.editCourse = null
            this.resetForm()
            this.showAddDialog = true
          })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 4 })
        .backgroundColor('#FFFFFF')

        // 星期筛选
        Row() {
          Scroll() {
            Row({ space: 8 }) {
              this.buildFilterTag('全部', -1)
              ForEach(WEEK_DAYS, (day: string, index: number) => {
                this.buildFilterTag(day, index)
              })
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .layoutWeight(1)

          // 滚动提示箭头
          Text('›')
            .fontSize(18)
            .fontColor('#CCCCCC')
            .margin({ left: 4 })
        }
        .width('100%')
        .padding({ left: 20, right: 20 })
        .margin({ top: 8, bottom: 4 })

        // 课程数量统计
        Row() {
          Text(`共 ${this.getFilteredCourses().length} 门课程`)
            .fontSize(12)
            .fontColor('#999999')
          Blank()
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 4, bottom: 8 })

        // 课程列表
        this.buildCourseList()

        BottomNavBar(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')

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
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildCourseList() {
    if (this.getFilteredCourses().length === 0) {
      Column() {
        Text('暂无课程')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#999999')
        Text('点击右上角 + 添加课程')
          .fontSize(14)
          .fontColor('#BBBBBB')
          .margin({ top: 10 })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      List() {
        ForEach(this.getFilteredCourses(), (course: CourseModel) => {
          ListItem() {
            this.buildCourseItem(course)
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 12, right: 12, top: 4 })
    }
  }

  @Builder
  buildCourseItem(course: CourseModel) {
    Row() {
      // 左侧课程颜色标识
      Column()
        .width(4)
        .height('100%')
        .backgroundColor(course.color)
        .borderRadius(2)

      // 中间内容区域
      Column() {
        // 第一行：课程名 + 教师
        Row() {
          Text(course.name)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1A1A')
          if (course.teacher) {
            Text(course.teacher)
              .fontSize(13)
              .fontColor('#999999')
              .margin({ left: 8 })
          }
        }

        // 第二行：地点 · 节次 · 周次（紧凑一行）
        Row({ space: 6 }) {
          if (course.location) {
            Text(course.location)
              .fontSize(12)
              .fontColor('#666666')
          }
          Text(WEEK_DAYS[course.dayOfWeek] + ' ' +
            course.startSection + '-' + course.endSection + '节')
            .fontSize(12)
            .fontColor('#999999')
          Text(this.getWeekDisplay(course))
            .fontSize(12)
            .fontColor('#999999')
        }
        .margin({ top: 6 })
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)

      // 右侧操作按钮
      Row({ space: 6 }) {
        Button() {
          Text('编辑')
            .fontSize(12)
            .fontColor('#1890FF')
        }
        .width(48)
        .height(28)
        .backgroundColor('rgba(24, 144, 255, 0.08)')
        .borderRadius(14)
        .onClick(() => {
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
        })

        Button() {
          Text('删除')
            .fontSize(12)
            .fontColor('#FF4D4F')
        }
        .width(48)
        .height(28)
        .backgroundColor('rgba(255, 77, 79, 0.06)')
        .borderRadius(14)
        .onClick(() => {
          this.deleteCourse(course)
        })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
    .margin({ bottom: 8 })
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: 'rgba(0, 0, 0, 0.05)',
      offsetX: 0,
      offsetY: 1
    })
  }

  /**
   * 获取周次显示文本（动态化）
   */
  getWeekDisplay(course: CourseModel): string {
    const currentWeek = DateUtils.getCurrentWeek()
    if (currentWeek >= course.startWeek && currentWeek <= course.endWeek) {
      return `进行中 ${currentWeek - course.startWeek + 1}/${course.endWeek - course.startWeek + 1}周`
    }
    return `${course.startWeek}-${course.endWeek}周`
  }

  resetForm() {
    this.courseName = ''
    this.teacher = ''
    this.location = ''
    this.dayOfWeek = 0
    this.startSection = 1
    this.endSection = 2
    this.startWeek = 1
    this.endWeek = 16
    this.selectedColor = COURSE_COLORS[Math.floor(Math.random() * COURSE_COLORS.length)]
  }

  async saveCourse(course: CourseModel) {
    if (this.editCourse) {
      const success = await CourseService.updateCourse(course)
      if (!success) {
        promptAction.showToast({ message: '课程时间冲突！' })
        return
      }
    } else {
      const success = await CourseService.addCourse(course)
      if (!success) {
        promptAction.showToast({ message: '课程时间冲突！' })
        return
      }
    }
    this.editCourse = null
    this.loadCourses()
  }

  async deleteCourse(course: CourseModel) {
    AlertDialog.show({
      title: '确认删除',
      message: `确定要删除课程"${course.name}"吗？`,
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '删除',
        action: async () => {
          await CourseService.deleteCourse(course.id)
          await HomeworkService.deleteHomeworksByCourse(course.id)
          this.loadCourses()
        }
      }
    })
  }

  @Builder
  buildFilterTag(label: string, day: number) {
    Text(label)
      .fontSize(13)
      .fontColor(this.filterDay === day ? '#FFFFFF' : '#666666')
      .backgroundColor(this.filterDay === day ? '#1890FF' : '#F2F2F2')
      .borderRadius(16)
      .padding({ left: 14, right: 14, top: 6, bottom: 6 })
      .fontWeight(this.filterDay === day ? FontWeight.Medium : FontWeight.Normal)
      .onClick(() => {
        this.filterDay = day
      })
  }
}
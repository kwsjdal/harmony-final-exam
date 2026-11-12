/**
 * 作业管理页面 - 管理作业的增删改查，支持按状态筛选（全部/未完成/已完成/已逾期）
 */
import { HomeworkModel } from '../models/HomeworkModel'
import { CourseModel } from '../models/CourseModel'
import { HomeworkService } from '../services/HomeworkService'
import { CourseService } from '../services/CourseService'
import { HomeworkItem } from '../components/HomeworkItem'
import { AddHomeworkDialog } from '../components/AddHomeworkDialog'
import { BottomNavBar } from '../components/BottomNavBar'
import { DateUtils } from '../utils/DateUtils'
import promptAction from '@ohos.promptAction'

@Entry
@Component
struct HomeworkPage {
  // === 页面状态 ===
  @State uncompletedHomeworks: HomeworkModel[] = [] // 未完成作业列表
  @State completedHomeworks: HomeworkModel[] = []   // 已完成作业列表
  @State courses: CourseModel[] = []                // 课程列表（用于关联作业）
  @State filterType: number = 0                    // 筛选类型（0:全部 1:未完成 2:已完成 3:已逾期）

  // === 添加作业弹窗状态 ===
  @State showAddDialog: boolean = false      // 弹窗显示状态
  @State title: string = ''                  // 作业标题
  @State selectedCourseId: string = ''       // 选中课程ID
  @State selectedCourseName: string = ''     // 选中课程名称
  @State deadline: number = 0               // 截止时间戳

  /**
   * 组件显示前初始化数据
   */
  aboutToAppear() {
    this.loadData()
    // 订阅作业数据变化
    HomeworkService.subscribe(() => {
      this.loadHomeworks()
    })
    // 订阅课程数据变化
    CourseService.subscribe((courses) => {
      this.courses = courses
    })
  }

  /**
   * 组件销毁前取消订阅
   */
  aboutToDisappear() {
    HomeworkService.unsubscribe(() => {})
    CourseService.unsubscribe(() => {})
  }

  /**
   * 加载初始数据
   */
  loadData() {
    this.courses = CourseService.getAllCourses()
    this.loadHomeworks()
  }

  /**
   * 加载作业列表（区分已完成和未完成）
   */
  loadHomeworks() {
    this.uncompletedHomeworks = HomeworkService.getUncompletedHomeworks()
    this.completedHomeworks = HomeworkService.getCompletedHomeworks()
  }

  /**
   * 根据筛选类型获取过滤后的未完成作业列表
   * @returns 过滤后的未完成作业数组
   */
  getFilteredUncompletedHomeworks(): HomeworkModel[] {
    const uncompleted = this.uncompletedHomeworks || []
    if (this.filterType === 1) {
      // 未完成（排除已逾期）
      return uncompleted.filter(h => !DateUtils.isOverdue(h.deadline))
    } else if (this.filterType === 3) {
      // 已逾期
      return uncompleted.filter(h => DateUtils.isOverdue(h.deadline))
    }
    return uncompleted
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航
        Row() {
          Text('作业管理')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
          Blank()
          Button() {
            Text('+ 添加')
              .fontSize(14)
              .fontColor('#FFFFFF')
          }
          .width(80)
          .height(36)
          .backgroundColor('#1890FF')
          .borderRadius(18)
          .onClick(() => {
            this.title = ''
            this.selectedCourseId = this.courses.length > 0 ? this.courses[0].id : ''
            this.selectedCourseName = this.courses.length > 0 ? this.courses[0].name : ''
            this.showAddDialog = true
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 8 })
        .backgroundColor('#FFFFFF')

        // 筛选标签
        Scroll() {
          Row({ space: 10 }) {
            this.buildFilterTag('全部', 0)
            this.buildFilterTag('未完成', 1)
            this.buildFilterTag('已完成', 2)
            this.buildFilterTag('已逾期', 3)
          }
          .padding({ left: 16, right: 16 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .margin({ top: 12, bottom: 8 })

        // 作业列表
        this.buildHomeworkList()

        BottomNavBar(2)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')

      AddHomeworkDialog({
        isShow: $showAddDialog,
        title: $title,
        selectedCourseId: $selectedCourseId,
        selectedCourseName: $selectedCourseName,
        deadline: $deadline,
        courses: this.courses,
        onSave: (homework): Promise<void> => this.saveHomework(homework)
      })
    }
    .width('100%')
    .height('100%')
  }

  getAllHomeworks(): HomeworkModel[] {
    return [...this.uncompletedHomeworks, ...this.completedHomeworks]
  }

  @Builder
  buildHomeworkList() {
    // 全部：显示所有作业
    if (this.filterType === 0) {
      if (this.getAllHomeworks().length === 0) {
        Column() {
          Text('暂无作业')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 80 })
          Text('点击右上角添加作业')
            .fontSize(14)
            .fontColor('#BBBBBB')
            .margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.getAllHomeworks(), (homework: HomeworkModel) => {
            ListItem() {
              HomeworkItem({
                homework: homework,
                onToggleComplete: (hw: HomeworkModel): void => {
                  this.toggleComplete(hw)
                },
                onDelete: (hw: HomeworkModel): void => {
                  this.deleteHomework(hw)
                },
                disableCheckbox: !homework.isCompleted && DateUtils.isOverdue(homework.deadline)
              })
            }
            .margin({ bottom: 10 })
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 12 })
      }
    }
    // 已完成
    else if (this.filterType === 2) {
      if (this.completedHomeworks.length === 0) {
        Column() {
          Text('暂无已完成作业')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 80 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.completedHomeworks, (homework: HomeworkModel) => {
            ListItem() {
              HomeworkItem({
                homework: homework,
                onToggleComplete: (hw: HomeworkModel): void => {
                  this.toggleComplete(hw)
                },
                onDelete: (hw: HomeworkModel): void => {
                  this.deleteHomework(hw)
                }
              })
            }
            .margin({ bottom: 10 })
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 12 })
      }
    }
    // 未完成或已逾期
    else {
      if (this.getFilteredUncompletedHomeworks().length === 0) {
        Column() {
          Text(this.filterType === 1 ? '暂无未完成作业' : '暂无已逾期作业')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 80 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.getFilteredUncompletedHomeworks(), (homework: HomeworkModel) => {
            ListItem() {
              HomeworkItem({
                homework: homework,
                onToggleComplete: (hw: HomeworkModel): void => {
                  this.toggleComplete(hw)
                },
                onDelete: (hw: HomeworkModel): void => {
                  this.deleteHomework(hw)
                },
                disableCheckbox: this.filterType === 3 // 已逾期时禁用复选框
              })
            }
            .margin({ bottom: 10 })
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 12 })
      }
    }
  }

  /**
   * 保存作业（添加）
   * @param homework - 作业对象
   */
  async saveHomework(homework: HomeworkModel) {
    await HomeworkService.addHomework(homework)
    this.loadHomeworks()
    promptAction.showToast({ message: '作业添加成功' })
  }

  /**
   * 切换作业完成状态
   * @param homework - 作业对象
   */
  async toggleComplete(homework: HomeworkModel) {
    if (homework.isCompleted) {
      await HomeworkService.markUncompleted(homework.id)
    } else {
      await HomeworkService.markCompleted(homework.id)
    }
    this.loadHomeworks()
  }

  /**
   * 删除作业（含确认弹窗）
   * @param homework - 要删除的作业对象
   */
  async deleteHomework(homework: HomeworkModel) {
    AlertDialog.show({
      title: '确认删除',
      message: `确定要删除作业"${homework.title}"吗？`,
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '删除',
        action: async () => {
          await HomeworkService.deleteHomework(homework.id)
          this.loadHomeworks()
        }
      }
    })
  }

  /**
   * 构建筛选标签
   * @param label - 标签文字
   * @param type - 筛选类型（0:全部 1:未完成 2:已完成 3:已逾期）
   */
  @Builder
  buildFilterTag(label: string, type: number) {
    Text(label)
      .fontSize(13)
      .fontColor(this.filterType === type ? '#FFFFFF' : (type === 3 ? '#FF4D4F' : '#666666'))
      .backgroundColor(this.filterType === type ? (type === 3 ? '#FF4D4F' : '#1890FF') : '#F5F5F5')
      .borderRadius(20)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .fontWeight(this.filterType === type ? FontWeight.Medium : FontWeight.Normal)
      .onClick(() => {
        this.filterType = type
      })
  }
}

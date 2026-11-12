/**
 * 添加作业弹窗组件 - 用于创建新作业，支持选择课程和截止日期
 */
import { HomeworkModel } from '../models/HomeworkModel'
import { CourseModel } from '../models/CourseModel'
import promptAction from '@ohos.promptAction'

/**
 * 下拉选择选项接口
 */
interface SelectOption {
  value: string // 选项显示值
}

@Component
export struct AddHomeworkDialog {
  @Link isShow: boolean           // 控制弹窗显示/隐藏
  @Link title: string             // 作业标题
  @Link selectedCourseId: string  // 选中课程ID
  @Link selectedCourseName: string // 选中课程名称
  @Link deadline: number          // 截止时间戳
  @Prop courses: CourseModel[] = [] // 课程列表
  onSave?: (homework: HomeworkModel) => void // 保存回调

  @State selectedYear: number = new Date().getFullYear()   // 选中年份
  @State selectedMonth: number = new Date().getMonth()     // 选中月份（0-11）
  @State selectedDay: number = new Date().getDate()        // 选中日期
  @State selectedHour: number = 23                         // 选中小时
  @State selectedMinute: number = 59                       // 选中分钟

  /**
   * 组件显示前初始化日期为当前日期，默认截止时间为一周后
   */
  aboutToAppear() {
    const now = new Date()
    this.selectedYear = now.getFullYear()
    this.selectedMonth = now.getMonth()
    this.selectedDay = now.getDate()
    this.selectedHour = 23
    this.selectedMinute = 59
    this.deadline = now.getTime() + 7 * 24 * 60 * 60 * 1000 // 默认一周后
  }

  /**
   * 获取课程下拉选项列表
   * @returns 课程选项数组
   */
  getCourseOptions(): SelectOption[] {
    const options: SelectOption[] = []
    for (const course of this.courses) {
      const option: SelectOption = { value: course.name }
      options.push(option)
    }
    return options
  }

  build() {
    if (this.isShow) {
      Column() {
        Column() {
          // 标题
          Row() {
            Text('添加作业')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
            Blank()
            Button() {
              Text('×')
                .fontSize(24)
                .fontColor('#999999')
            }
            .width(32)
            .height(32)
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.isShow = false
            })
          }
          .width('100%')
          .padding({ left: 20, right: 8, top: 16, bottom: 12 })

          Divider().color('#EEEEEE')

          Scroll() {
            Column() {
              // 作业标题
              Row() {
                Text('作业标题')
                  .fontSize(14)
                  .fontColor('#333333')
                  .width(70)
                Blank()
                TextInput({ text: this.title, placeholder: '请输入作业标题' })
                  .placeholderColor('#BBBBBB')
                  .fontSize(14)
                  .layoutWeight(1)
                  .onChange((value: string) => {
                    this.title = value
                  })
              }
              .width('100%')
              .padding({ top: 16 })

              // 关联课程
              Row() {
                Text('关联课程')
                  .fontSize(14)
                  .fontColor('#333333')
                  .width(70)
                Blank()
                if (this.courses.length > 0) {
                  Select(this.getCourseOptions())
                    .selected(this.courses.findIndex(c => c.id === this.selectedCourseId))
                    .onSelect((index: number) => {
                      this.selectedCourseId = this.courses[index].id
                      this.selectedCourseName = this.courses[index].name
                    })
                    .layoutWeight(1)
                } else {
                  Text('暂无课程')
                    .fontSize(14)
                    .fontColor('#999999')
                }
              }
              .width('100%')
              .padding({ top: 16 })

              // 截止日期
              Text('截止日期')
                .fontSize(14)
                .fontColor('#333333')
                .width('100%')
                .padding({ top: 16 })

              Row() {
                Text('年')
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ left: 4 })
                TextInput({ text: this.selectedYear.toString() })
                  .type(InputType.Number)
                  .width(70)
                  .textAlign(TextAlign.Center)
                  .onChange((value: string) => {
                    const num = parseInt(value)
                    if (!isNaN(num)) {
                      this.selectedYear = num
                    }
                  })

                Text('月')
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ left: 4 })
                TextInput({ text: (this.selectedMonth + 1).toString() })
                  .type(InputType.Number)
                  .width(50)
                  .textAlign(TextAlign.Center)
                  .onChange((value: string) => {
                    const num = parseInt(value)
                    if (!isNaN(num) && num >= 1 && num <= 12) {
                      this.selectedMonth = num - 1
                    }
                  })

                Text('日')
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ left: 4 })
                TextInput({ text: this.selectedDay.toString() })
                  .type(InputType.Number)
                  .width(50)
                  .textAlign(TextAlign.Center)
                  .onChange((value: string) => {
                    const num = parseInt(value)
                    if (!isNaN(num) && num >= 1 && num <= 31) {
                      this.selectedDay = num
                    }
                  })

                Text('时')
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ left: 12 })
                TextInput({ text: this.selectedHour.toString() })
                  .type(InputType.Number)
                  .width(50)
                  .textAlign(TextAlign.Center)
                  .onChange((value: string) => {
                    const num = parseInt(value)
                    if (!isNaN(num) && num >= 0 && num <= 23) {
                      this.selectedHour = num
                    }
                  })

                Text('分')
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ left: 4 })
                TextInput({ text: this.selectedMinute.toString() })
                  .type(InputType.Number)
                  .width(50)
                  .textAlign(TextAlign.Center)
                  .onChange((value: string) => {
                    const num = parseInt(value)
                    if (!isNaN(num) && num >= 0 && num <= 59) {
                      this.selectedMinute = num
                    }
                  })
              }
              .width('100%')
              .margin({ top: 8 })

              // 快捷日期按钮
              Row() {
                Button('今天')
                  .fontSize(12)
                  .height(28)
                  .onClick(() => {
                    const now = new Date()
                    this.selectedYear = now.getFullYear()
                    this.selectedMonth = now.getMonth()
                    this.selectedDay = now.getDate()
                    this.selectedHour = 23
                    this.selectedMinute = 59
                  })
                Button('明天')
                  .fontSize(12)
                  .height(28)
                  .margin({ left: 8 })
                  .onClick(() => {
                    const tomorrow = new Date()
                    tomorrow.setDate(tomorrow.getDate() + 1)
                    this.selectedYear = tomorrow.getFullYear()
                    this.selectedMonth = tomorrow.getMonth()
                    this.selectedDay = tomorrow.getDate()
                    this.selectedHour = 23
                    this.selectedMinute = 59
                  })
                Button('一周后')
                  .fontSize(12)
                  .height(28)
                  .margin({ left: 8 })
                  .onClick(() => {
                    const nextWeek = new Date()
                    nextWeek.setDate(nextWeek.getDate() + 7)
                    this.selectedYear = nextWeek.getFullYear()
                    this.selectedMonth = nextWeek.getMonth()
                    this.selectedDay = nextWeek.getDate()
                    this.selectedHour = 23
                    this.selectedMinute = 59
                  })
              }
              .width('100%')
              .margin({ top: 12 })
              .justifyContent(FlexAlign.Start)
            }
            .padding({ left: 20, right: 20, bottom: 20 })
          }
          .layoutWeight(1)

          Divider().color('#EEEEEE')

          // 按钮
          Row() {
            Button('取消')
              .fontColor('#666666')
              .backgroundColor('#F5F5F5')
              .width('45%')
              .height(40)
              .onClick(() => {
                this.isShow = false
              })
            Button('保存')
              .fontColor(Color.White)
              .backgroundColor('#1890FF')
              .width('45%')
              .height(40)
              .onClick(() => {
                this.saveHomework()
              })
          }
          .width('100%')
          .padding(20)
          .justifyContent(FlexAlign.SpaceEvenly)
        }
        .width('100%')
        .height('80%')
        .backgroundColor('#FFFFFF')
        .borderRadius({ topLeft: 16, topRight: 16 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('rgba(0, 0, 0, 0.5)')
      .justifyContent(FlexAlign.End)
    }
  }

  /**
   * 保存作业 - 验证输入并创建作业对象
   */
  saveHomework() {
    // 验证作业标题不能为空
    if (!this.title.trim()) {
      promptAction.showToast({ message: '请输入作业标题' })
      return
    }

    // 根据用户选择的日期时间创建截止时间戳
    const deadlineDate = new Date(this.selectedYear, this.selectedMonth, this.selectedDay, this.selectedHour, this.selectedMinute)
    const deadline = deadlineDate.getTime()

    // 创建作业对象
    const homework = new HomeworkModel(
      this.selectedCourseId,
      this.selectedCourseName,
      this.title.trim(),
      deadline
    )

    // 调用保存回调
    if (this.onSave) {
      this.onSave(homework)
    }

    // 重置表单并关闭弹窗
    this.title = ''
    this.isShow = false
  }
}

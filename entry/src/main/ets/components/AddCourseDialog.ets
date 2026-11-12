/**
 * 添加/编辑课程弹窗组件 - 支持创建新课程和编辑已有课程
 */
import { CourseModel } from '../models/CourseModel'
import { COURSE_COLORS, WEEK_DAYS, TOTAL_SECTIONS } from '../utils/Constants'
import promptAction from '@ohos.promptAction'

/**
 * 下拉选择项接口
 */
export interface SelectItem {
  value: string // 选项显示文本
}

@Component
export struct AddCourseDialog {
  @Link isShow: boolean           // 控制弹窗显示/隐藏
  @Link courseName: string        // 课程名称
  @Link teacher: string           // 授课教师
  @Link location: string          // 上课地点
  @Link dayOfWeek: number         // 星期几（0-6）
  @Link startSection: number      // 开始节次
  @Link endSection: number        // 结束节次
  @Link startWeek: number         // 开始周次
  @Link endWeek: number           // 结束周次
  @Link selectedColor: string     // 选中的颜色
  @Prop editCourse: CourseModel | null = null // 编辑模式下的课程对象
  onSave?: (course: CourseModel) => void // 保存回调

  /**
   * 组件显示前初始化表单数据
   * 编辑模式：填充现有课程数据
   * 添加模式：重置表单为默认值
   */
  aboutToAppear() {
    if (this.editCourse) {
      // 编辑模式：加载已有课程数据
      this.courseName = this.editCourse.name
      this.teacher = this.editCourse.teacher
      this.location = this.editCourse.location
      this.dayOfWeek = this.editCourse.dayOfWeek
      this.startSection = this.editCourse.startSection
      this.endSection = this.editCourse.endSection
      this.startWeek = this.editCourse.startWeek
      this.endWeek = this.editCourse.endWeek
      this.selectedColor = this.editCourse.color
    } else {
      // 添加模式：重置表单
      this.resetForm()
    }
  }

  /**
   * 重置表单为默认值
   */
  resetForm() {
    this.courseName = ''
    this.teacher = ''
    this.location = ''
    this.dayOfWeek = 0           // 默认周一
    this.startSection = 1         // 默认第1节开始
    this.endSection = 2           // 默认第2节结束
    this.startWeek = 1            // 默认第1周开始
    this.endWeek = 16             // 默认第16周结束
    this.selectedColor = COURSE_COLORS[Math.floor(Math.random() * COURSE_COLORS.length)] // 随机颜色
  }

  /**
   * 获取节次下拉选项列表（1-12节）
   * @returns 节次选项数组
   */
  getSectionOptions(): SelectItem[] {
    const options: SelectItem[] = []
    for (let i = 1; i <= TOTAL_SECTIONS; i++) {
      const item: SelectItem = { value: '第' + i + '节' }
      options.push(item)
    }
    return options
  }

  /**
   * 获取星期下拉选项列表（周一到周日）
   * @returns 星期选项数组
   */
  getWeekDayOptions(): SelectItem[] {
    const result: SelectItem[] = []
    for (const day of WEEK_DAYS) {
      const item: SelectItem = { value: day }
      result.push(item)
    }
    return result
  }

  build() {
    if (this.isShow) {
      Column() {
        Column() {
          Row() {
            Text(this.editCourse ? '编辑课程' : '添加课程')
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
              this.buildInputItem('课程名称', this.courseName, (value) => this.courseName = value)
              this.buildInputItem('授课教师', this.teacher, (value) => this.teacher = value)
              this.buildInputItem('上课地点', this.location, (value) => this.location = value)

              Row() {
                Text('星期')
                  .fontSize(14)
                  .fontColor('#333333')
                  .width(70)
                Blank()
                Select(this.getWeekDayOptions())
                  .selected(this.dayOfWeek)
                  .onSelect((index: number) => {
                    this.dayOfWeek = index
                  })
                  .layoutWeight(1)
              }
              .width('100%')
              .padding({ top: 12 })

              Row() {
                Text('开始节次')
                  .fontSize(14)
                  .fontColor('#333333')
                  .width(70)
                Blank()
                Select(this.getSectionOptions())
                  .selected(this.startSection - 1)
                  .onSelect((index: number) => {
                    this.startSection = index + 1
                    if (this.endSection < this.startSection) {
                      this.endSection = this.startSection
                    }
                  })
                  .layoutWeight(1)
              }
              .width('100%')
              .padding({ top: 12 })

              Row() {
                Text('结束节次')
                  .fontSize(14)
                  .fontColor('#333333')
                  .width(70)
                Blank()
                Select(this.getSectionOptions())
                  .selected(this.endSection - 1)
                  .onSelect((index: number) => {
                    if (index + 1 >= this.startSection) {
                      this.endSection = index + 1
                    }
                  })
                  .layoutWeight(1)
              }
              .width('100%')
              .padding({ top: 12 })

              Row() {
                Text('起始周')
                  .fontSize(14)
                  .fontColor('#333333')
                  .width(70)
                Blank()
                TextInput({ text: this.startWeek.toString() })
                  .type(InputType.Number)
                  .width(60)
                  .textAlign(TextAlign.Center)
                  .onChange((value: string) => {
                    const num = parseInt(value)
                    if (!isNaN(num) && num > 0) {
                      this.startWeek = num
                    }
                  })
                Text('  至  ')
                  .fontSize(14)
                  .fontColor('#666666')
                TextInput({ text: this.endWeek.toString() })
                  .type(InputType.Number)
                  .width(60)
                  .textAlign(TextAlign.Center)
                  .onChange((value: string) => {
                    const num = parseInt(value)
                    if (!isNaN(num) && num > 0) {
                      this.endWeek = num
                    }
                  })
                Text('  周')
                  .fontSize(14)
                  .fontColor('#666666')
              }
              .width('100%')
              .padding({ top: 12 })

              Text('选择颜色')
                .fontSize(14)
                .fontColor('#333333')
                .width('100%')
                .margin({ top: 16 })
                .padding({ left: 0 })

              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(COURSE_COLORS, (color: string) => {
                  Column() {
                    if (this.selectedColor === color) {
                      Text('✓')
                        .fontSize(16)
                        .fontColor(Color.White)
                    }
                  }
                  .width(36)
                  .height(36)
                  .backgroundColor(color)
                  .borderRadius(18)
                  .border({
                    width: this.selectedColor === color ? 2 : 0,
                    color: '#333333'
                  })
                  .onClick(() => {
                    this.selectedColor = color
                  })
                  .margin(4)
                })
              }
              .width('100%')
              .margin({ top: 8 })
            }
            .padding({ left: 20, right: 20, bottom: 20 })
          }
          .layoutWeight(1)

          Divider().color('#EEEEEE')

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
                this.saveCourse()
              })
          }
          .width('100%')
          .padding(20)
          .justifyContent(FlexAlign.SpaceEvenly)
        }
        .width('100%')
        .height('90%')
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
   * 构建输入项通用组件
   * @param label - 标签文本
   * @param value - 当前值
   * @param onChange - 值变化回调
   */
  @Builder
  buildInputItem(label: string, value: string, onChange: (value: string) => void) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#333333')
        .width(70)
      Blank()
      TextInput({ text: value, placeholder: '请输入' + label })
        .placeholderColor('#BBBBBB')
        .fontSize(14)
        .layoutWeight(1)
        .onChange(onChange)
    }
    .width('100%')
    .padding({ top: 12 })
  }

  /**
   * 保存课程 - 验证输入并创建课程对象
   */
  saveCourse() {
    // 验证课程名称不能为空
    if (!this.courseName.trim()) {
      promptAction.showToast({ message: '请输入课程名称' })
      return
    }
    // 验证节次范围有效性
    if (this.startSection > this.endSection) {
      promptAction.showToast({ message: '开始节次不能大于结束节次' })
      return
    }
    // 验证周次范围有效性
    if (this.startWeek > this.endWeek) {
      promptAction.showToast({ message: '起始周不能大于结束周' })
      return
    }
    // 验证周次数值有效性
    if (this.startWeek <= 0 || this.endWeek <= 0) {
      promptAction.showToast({ message: '周次必须大于0' })
      return
    }

    // 创建课程对象
    const course = new CourseModel(
      this.courseName.trim(),
      this.teacher.trim(),
      this.location.trim(),
      this.dayOfWeek,
      this.startSection,
      this.endSection,
      this.startWeek,
      this.endWeek,
      this.selectedColor
    )

    // 编辑模式：保留原有ID
    if (this.editCourse) {
      course.id = this.editCourse.id
    }

    // 调用保存回调
    if (this.onSave) {
      this.onSave(course)
    }
    // 关闭弹窗
    this.isShow = false
  }
}

/**
 * 周课表栅格组件 - 展示一周课程安排的网格视图
 * 参考样式：薄荷青表头、周次导航、日期显示、网格线、跨节课程
 */
import { CourseModel } from '../models/CourseModel'
import { CourseCard } from './CourseCard'
import { WEEK_DAYS, SECTION_TIMES, TOTAL_SECTIONS, TOTAL_DAYS } from '../utils/Constants'
import { DateUtils } from '../utils/DateUtils'

const CELL_HEIGHT = 50

@Component
export struct TimetableGrid {
  @Prop courses: CourseModel[] = []
  @Prop currentWeek: number = 1
  onWeekChange?: (week: number) => void

  getWeekDateRange(): string {
    const currentWeek = DateUtils.getCurrentWeek()
    const offset = this.currentWeek - currentWeek
    const monday = DateUtils.getMondayByOffset(offset)
    const sunday = new Date(monday.getTime() + 6 * 24 * 60 * 60 * 1000)
    const fmt = (d: Date) => {
      const m = String(d.getMonth() + 1).padStart(2, '0')
      const day = String(d.getDate()).padStart(2, '0')
      return `${m}-${day}`
    }
    return `${fmt(monday)}/${fmt(sunday)}`
  }

  getDayDate(dayOfWeek: number): string {
    const currentWeek = DateUtils.getCurrentWeek()
    const offset = this.currentWeek - currentWeek
    const monday = DateUtils.getMondayByOffset(offset)
    const date = new Date(monday.getTime() + dayOfWeek * 24 * 60 * 60 * 1000)
    return String(date.getDate()).padStart(2, '0')
  }

  @Builder
  buildHeader() {
    Column() {
      // 周次导航栏
      Row() {
        // 左箭头
        Text('<')
          .fontSize(16)
          .fontColor('#666666')
          .width(32)
          .height(32)
          .textAlign(TextAlign.Center)
          .borderRadius(8)
          .backgroundColor('#F0F0F0')
          .onClick(() => {
            if (this.currentWeek > 1 && this.onWeekChange) {
              this.onWeekChange(this.currentWeek - 1)
            }
          })

        // 周次标题
        Text(`第${this.currentWeek}周  ${this.getWeekDateRange()}`)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 右箭头
        Text('>')
          .fontSize(16)
          .fontColor('#666666')
          .width(32)
          .height(32)
          .textAlign(TextAlign.Center)
          .borderRadius(8)
          .backgroundColor('#F0F0F0')
          .onClick(() => {
            if (this.currentWeek < 20 && this.onWeekChange) {
              this.onWeekChange(this.currentWeek + 1)
            }
          })
      }
      .width('100%')
      .height(36)
      .padding({ left: 12, right: 12 })

      // 星期 + 日期标题行
      Row() {
        // 左侧节次占位
        Column() {
          Text('节次')
            .fontSize(10)
            .fontColor('#666666')
          Text('时间')
            .fontSize(8)
            .fontColor('#999999')
            .margin({ top: 1 })
        }
        .width(56)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        // 星期列
        ForEach(WEEK_DAYS, (day: string, index: number) => {
          Column() {
            Text(day)
              .fontSize(11)
              .fontWeight(index === DateUtils.getTodayOfWeek() ? FontWeight.Bold : FontWeight.Medium)
              .fontColor(index === DateUtils.getTodayOfWeek() ? '#1890FF' : '#333333')
            Text(this.getDayDate(index))
              .fontSize(10)
              .fontColor('#999999')
              .margin({ top: 2 })
          }
          .layoutWeight(1)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        })
      }
      .width('100%')
    }
    .backgroundColor('#E0F2F1')
    .padding({ left: 2, right: 2 })
  }

  @Builder
  buildSectionColumn(section: number) {
    Column() {
      Text(section.toString())
        .fontSize(10)
        .fontWeight(FontWeight.Medium)
        .fontColor('#666666')
      Text(SECTION_TIMES[section - 1])
        .fontSize(8)
        .fontColor('#AAAAAA')
        .margin({ top: 1 })
    }
    .width(56)
    .height(CELL_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildDayColumn(dayIndex: number) {
    Stack() {
      // 网格背景线
      ForEach(this.getSectionArray(), (section: number) => {
        Column()
          .width('100%')
          .height(CELL_HEIGHT)
          .border({ width: 0.5, color: '#E0E0E0' })
          .position({ top: (section - 1) * CELL_HEIGHT, left: 0 })
      })

      // 课程卡片 - 绝对定位，跨节占满
      ForEach(this.getDayCourses(dayIndex), (course: CourseModel) => {
        CourseCard({
          course: course,
          isCurrent: this.isCurrent(course, dayIndex),
          useCompact: true
        })
        .width('100%')
        .height(this.getCourseSpan(course) * CELL_HEIGHT - 2)
        .position({
          top: (course.startSection - 1) * CELL_HEIGHT + 1,
          left: 1
        })
        .padding(0)
      })
    }
    .layoutWeight(1)
    .height(TOTAL_SECTIONS * CELL_HEIGHT)
  }

  getDayCourses(dayOfWeek: number): CourseModel[] {
    const result: CourseModel[] = []
    for (const course of this.courses) {
      if (this.currentWeek < course.startWeek || this.currentWeek > course.endWeek) {
        continue
      }
      if (course.dayOfWeek !== dayOfWeek) {
        continue
      }
      result.push(course)
    }
    // 按开始节次排序
    result.sort((a, b) => a.startSection - b.startSection)
    return result
  }

  getCourseSpan(course: CourseModel): number {
    return course.endSection - course.startSection + 1
  }

  isCurrent(course: CourseModel, dayOfWeek: number): boolean {
    if (dayOfWeek !== DateUtils.getTodayOfWeek()) {
      return false
    }
    const currentSection = DateUtils.getCurrentSection()
    return currentSection >= course.startSection && currentSection <= course.endSection
  }

  getSectionArray(): number[] {
    const arr: number[] = []
    for (let i = 1; i <= TOTAL_SECTIONS; i++) {
      arr.push(i)
    }
    return arr
  }

  getDayArray(): number[] {
    const arr: number[] = []
    for (let i = 0; i < TOTAL_DAYS; i++) {
      arr.push(i)
    }
    return arr
  }

  build() {
    Column() {
      this.buildHeader()

      Scroll() {
        Row() {
          // 左侧节次时间列
          Column() {
            ForEach(this.getSectionArray(), (section: number) => {
              this.buildSectionColumn(section)
            })
          }
          .width(56)
          .backgroundColor('#E0F2F1')

          // 右侧课程网格
          ForEach(this.getDayArray(), (dayIndex: number) => {
            this.buildDayColumn(dayIndex)
          })
        }
        .alignItems(VerticalAlign.Top)
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#F5F5F5')
  }
}
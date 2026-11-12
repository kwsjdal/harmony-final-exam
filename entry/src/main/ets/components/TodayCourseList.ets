/**
 * 今日课程列表组件 - 展示当天课程的时间线样式列表，支持冲突检测
 */
import { CourseModel } from '../models/CourseModel'
import { CourseCard } from './CourseCard'
import { TimeUtils } from '../utils/TimeUtils'
import { DateUtils } from '../utils/DateUtils'
import { CourseService } from '../services/CourseService'

@Component
export struct TodayCourseList {
  @Prop courses: CourseModel[] = []

  /**
   * 判断课程是否与今日其他课程存在冲突
   * @param course - 要检测的课程
   * @returns true表示存在冲突，false表示无冲突
   */
  hasConflict(course: CourseModel): boolean {
    for (const other of this.courses) {
      // 跳过自身
      if (other.id === course.id) {
        continue
      }
      // 检查节次是否重叠
      const sectionOverlap = !(course.endSection < other.startSection || course.startSection > other.endSection)
      if (sectionOverlap) {
        return true
      }
    }
    return false
  }

  /**
   * 构建单个课程条目
   */
  @Builder
  buildCourseItem(course: CourseModel, index: number) {
    Row() {
      // 左侧时间指示区域 - 显示完整时间范围和节次范围
      Column() {
        // 完整时间范围（如 14:00-22:30）
        Text(TimeUtils.getCourseTimeRange(course.startSection, course.endSection))
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.hasConflict(course) ? '#FF4D4F' : '#333333')
          .textAlign(TextAlign.Center)
        // 完整节次范围（如 第5-12节）
        Text(`第${course.startSection}-${course.endSection}节`)
          .fontSize(10)
          .fontColor(this.hasConflict(course) ? '#FF4D4F' : '#999999')
          .margin({ top: 2 })
          .textAlign(TextAlign.Center)
      }
      .width(72)
      .alignItems(HorizontalAlign.Center)

      // 时间线连接点
      Column() {
        // 上线段
        Column()
          .width(2)
          .height(index === 0 ? 0 : 8)
          .backgroundColor(this.hasConflict(course) ? '#FF4D4F' : course.color)
        // 圆点
        Stack() {
          Column()
            .width(10)
            .height(10)
            .borderRadius(5)
            .backgroundColor(this.hasConflict(course) ? '#FF4D4F' : course.color)

          // 当前课程 - 脉冲指示
          if (this.isCurrentCourse(course)) {
            Column()
              .width(18)
              .height(18)
              .borderRadius(9)
              .backgroundColor('rgba(255, 215, 0, 0.3)')
          }
        }
        .width(20)
        .height(20)
        .alignContent(Alignment.Center)

        // 下线段（最后一节课不显示）
        Column()
          .width(2)
          .flexGrow(1)
          .backgroundColor(index < this.courses.length - 1 ? (this.hasConflict(course) ? '#FF4D4F' : course.color) : Color.Transparent)
      }
      .width(20)
      .alignItems(HorizontalAlign.Center)

      // 课程卡片
      Stack() {
        CourseCard({
          course: course,
          isCurrent: this.isCurrentCourse(course),
          useCompact: false
        })
        .width('100%')
        .height('100%')

        // 冲突标记 - 红色角标
        if (this.hasConflict(course)) {
          Text('!')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .backgroundColor('#FF4D4F')
            .borderRadius(10)
            .width(20)
            .height(20)
            .textAlign(TextAlign.Center)
            .position({ top: 4, left: 4 })
        }

        // 当前课程标记
        if (this.isCurrentCourse(course)) {
          Text('上课中')
            .fontSize(10)
            .fontColor('#FFD700')
            .backgroundColor('rgba(255, 215, 0, 0.15)')
            .borderRadius(8)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .position({ top: 4, right: 4 })
        }
      }
      .height(80)
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ right: 16 })
  }

  /**
   * 课程时间范围描述
   */
  getCourseTimeRange(course: CourseModel): string {
    return `${course.startSection}-${course.endSection}节`
  }

  isCurrentCourse(course: CourseModel): boolean {
    const currentSection = DateUtils.getCurrentSection()
    return currentSection >= course.startSection && currentSection <= course.endSection
  }

  build() {
    Column() {
      if (this.courses.length === 0) {
        Column() {
          Text('今日无课程')
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
          ForEach(this.courses, (course: CourseModel, index: number) => {
            ListItem() {
              this.buildCourseItem(course, index)
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .divider({ strokeWidth: 0.5, color: '#EEEEEE', startMargin: 88, endMargin: 16 })
        .padding({ top: 8 })
      }
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#FFFFFF')
  }
}
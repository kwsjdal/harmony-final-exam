/**
 * 课程卡片组件 - 支持列表模式（时间轴）和紧凑模式（网格）两种布局
 */
import { CourseModel } from '../models/CourseModel'
import { TimeUtils } from '../utils/TimeUtils'

@Component
export struct CourseCard {
  @Prop course: CourseModel
  @Prop isCurrent: boolean = false
  @Prop useCompact: boolean = false

  build() {
    if (this.useCompact) {
      // 紧凑模式 - 用于周课表网格，扁平无阴影
      Column() {
        Text(this.course.name)
          .fontSize(11)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .lineHeight(14)

        if (this.course.location) {
          Text(this.course.location)
            .fontSize(9)
            .fontColor('rgba(255, 255, 255, 0.85)')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .lineHeight(12)
            .margin({ top: 2 })
        }

        if (this.course.teacher) {
          Text(this.course.teacher)
            .fontSize(8)
            .fontColor('rgba(255, 255, 255, 0.75)')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .lineHeight(11)
            .margin({ top: 1 })
        }
      }
      .width('100%')
      .height('100%')
      .padding({ left: 4, right: 4, top: 3, bottom: 3 })
      .backgroundColor(this.course.color)
      .borderRadius(3)
      .border({
        width: this.isCurrent ? 2 : 0,
        color: this.isCurrent ? '#FFD700' : Color.Transparent
      })
    } else {
      // 列表模式 - 用于今日课程时间轴
      Column() {
        Text(this.course.name)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .lineHeight(22)

        Row({ space: 6 }) {
          if (this.course.teacher) {
            Text(this.course.teacher)
              .fontSize(12)
              .fontColor('rgba(255, 255, 255, 0.85)')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          if (this.course.location) {
            Text(this.course.location)
              .fontSize(11)
              .fontColor('rgba(255, 255, 255, 0.7)')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .margin({ top: 4 })

        Text(TimeUtils.getCourseTimeRange(this.course.startSection, this.course.endSection) +
          ' · ' + this.course.startSection + '-' + this.course.endSection + '节')
          .fontSize(11)
          .fontColor('rgba(255, 255, 255, 0.7)')
          .margin({ top: 2 })
          .maxLines(1)
      }
      .width('100%')
      .height('100%')
      .padding(12)
      .backgroundColor(this.course.color)
      .borderRadius(10)
      .border({
        width: this.isCurrent ? 2 : 0,
        color: this.isCurrent ? '#FFD700' : Color.Transparent
      })
      .shadow({
        radius: 4,
        color: 'rgba(0, 0, 0, 0.12)',
        offsetX: 0,
        offsetY: 2
      })
    }
  }
}
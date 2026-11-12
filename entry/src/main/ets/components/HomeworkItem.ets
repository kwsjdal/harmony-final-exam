/**
 * 作业条目组件 - 展示单个作业信息，支持完成状态切换和删除操作
 */
import { HomeworkModel } from '../models/HomeworkModel'
import { DateUtils } from '../utils/DateUtils'

@Component
export struct HomeworkItem {
  @Prop homework: HomeworkModel                    // 作业数据模型
  onToggleComplete?: (homework: HomeworkModel) => void // 切换完成状态回调
  onItemClick?: (homework: HomeworkModel) => void      // 点击条目回调
  onDelete?: (homework: HomeworkModel) => void         // 删除作业回调
  @Prop disableCheckbox: boolean = false            // 是否禁用复选框（已逾期作业禁用）

  /**
   * 构建状态标签 - 根据作业状态显示不同标签
   * - 已完成：绿色标签
   * - 已逾期：红色标签（未完成且已过截止时间）
   * - 即将到期：橙色标签（未完成且即将到期）
   */
  @Builder
  buildStatusTag() {
    if (this.homework.isCompleted) {
      Text('已完成')
        .fontSize(10)
        .fontColor('#52C41A')
        .backgroundColor('#F6FFED')
        .borderRadius(4)
        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
    } else if (DateUtils.isOverdue(this.homework.deadline)) {
      Text('已逾期')
        .fontSize(10)
        .fontColor('#FF4D4F')
        .backgroundColor('#FFF2F0')
        .borderRadius(4)
        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
    } else if (DateUtils.isDeadlineSoon(this.homework.deadline)) {
      Text('即将到期')
        .fontSize(10)
        .fontColor('#FA8C16')
        .backgroundColor('#FFF7E6')
        .borderRadius(4)
        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
    }
  }

  /**
   * 构建截止日期文本 - 根据日期显示不同样式
   * - 今日截止：红色高亮显示"今日截止"
   * - 已逾期：红色显示日期
   * - 其他：灰色显示日期
   */
  @Builder
  buildDeadlineText() {
    if (DateUtils.isToday(this.homework.deadline)) {
      Text('今日截止')
        .fontSize(12)
        .fontColor('#FF4D4F')
    } else {
      Text(DateUtils.formatDateTime(this.homework.deadline))
        .fontSize(12)
        .fontColor(DateUtils.isOverdue(this.homework.deadline) ? '#FF4D4F' : '#999999')
    }
  }

  build() {
    Row() {
      // 复选框
      Checkbox()
        .select(this.homework.isCompleted)
        .selectedColor('#1890FF')
        .enabled(!this.disableCheckbox)
        .onChange((isSelected: boolean) => {
          if (!this.disableCheckbox && this.onToggleComplete) {
            this.onToggleComplete(this.homework)
          }
        })

      // 内容区域
      Column() {
        Text(this.homework.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.homework.isCompleted ? '#BBBBBB' : '#333333')
          .decoration(this.homework.isCompleted ? { type: TextDecorationType.LineThrough } : null)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Text(this.homework.courseName)
            .fontSize(12)
            .fontColor('#666666')
          Text('  |  ')
            .fontSize(12)
            .fontColor('#DDDDDD')
          this.buildDeadlineText()
        }
        .margin({ top: 6 })
      }
      .layoutWeight(1)
      .margin({ left: 12 })

      // 状态标签
      this.buildStatusTag()

      // 删除按钮
      if (this.onDelete) {
        Button() {
          Text('×')
            .fontSize(18)
            .fontColor('#999999')
        }
        .width(28)
        .height(28)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          if (this.onDelete) {
            this.onDelete(this.homework)
          }
        })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .shadow({
      radius: 4,
      color: 'rgba(0, 0, 0, 0.06)',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      if (this.onItemClick) {
        this.onItemClick(this.homework)
      }
    })
  }
}
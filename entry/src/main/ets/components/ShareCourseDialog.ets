/**
 * 课表分享对话框组件 - 展示课表截图并提供保存/分享功能
 */
import { CourseModel } from '../models/CourseModel'
import { WEEK_DAYS, SECTION_TIMES } from '../utils/Constants'
import { DateUtils } from '../utils/DateUtils'
import { ShareService } from '../services/ShareService'
import { common } from '@kit.AbilityKit'

@Component
export struct ShareCourseDialog {
  @Link isShow: boolean
  @Prop courses: CourseModel[] = []
  @Prop currentWeek: number = 1
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

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
    const m = String(date.getMonth() + 1).padStart(2, '0')
    const d = String(date.getDate()).padStart(2, '0')
    return `${m}-${d}`
  }

  getCoursesForCell(dayOfWeek: number, section: number): CourseModel[] {
    const result: CourseModel[] = []
    for (const course of this.courses) {
      if (course.dayOfWeek === dayOfWeek &&
        section === course.startSection &&
        this.currentWeek >= course.startWeek &&
        this.currentWeek <= course.endWeek) {
        result.push(course)
      }
    }
    return result
  }

  async onSave() {
    await ShareService.saveToGallery('shareGrid', this.context)
  }

  async onShare() {
    await ShareService.shareToSystem('shareGrid', this.context)
  }

  build() {
    if (this.isShow) {
      Column() {
        // 顶部操作栏
        Row() {
          Text('分享课表')
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

        // === 截图目标区域（id: shareGrid）===
        Column() {
          // 周次标题
          Text(`第${this.currentWeek}周 ${this.getWeekDateRange()}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .textAlign(TextAlign.Center)
            .width('100%')
            .padding({ top: 16, bottom: 12 })

          // 表头
          Row() {
            Text('节次')
              .fontSize(11)
              .fontWeight(FontWeight.Medium)
              .fontColor('#666666')
              .width(50)
              .textAlign(TextAlign.Center)

            ForEach(WEEK_DAYS, (day: string, index: number) => {
              Column() {
                Text(day)
                  .fontSize(11)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
                Text(this.getDayDate(index))
                  .fontSize(9)
                  .fontColor('#999999')
                  .margin({ top: 2 })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)
            })
          }
          .width('100%')
          .padding({ left: 8, right: 8, top: 8, bottom: 8 })
          .backgroundColor('#E8F4FC')

          // 课程网格
          Scroll() {
            Column() {
              ForEach([0, 1, 2, 3, 4, 5, 6, 7, 8, 9], (sectionIndex: number) => {
                Row() {
                  Column() {
                    Text((sectionIndex + 1).toString())
                      .fontSize(11)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#666666')
                    Text(SECTION_TIMES[sectionIndex] || '')
                      .fontSize(9)
                      .fontColor('#999999')
                      .margin({ top: 1 })
                  }
                  .width(50)
                  .height(48)
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor('#E8F4FC')

                  ForEach([0, 1, 2, 3, 4, 5, 6], (dayIndex: number) => {
                    Column() {
                      ForEach(this.getCoursesForCell(dayIndex, sectionIndex + 1), (course: CourseModel) => {
                        Text(course.name)
                          .fontSize(10)
                          .fontColor('#FFFFFF')
                          .maxLines(1)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                          .width('100%')
                          .height(46)
                          .backgroundColor(course.color)
                          .borderRadius(4)
                          .padding(2)
                          .textAlign(TextAlign.Center)
                      })
                    }
                    .width('100%')
                    .layoutWeight(1)
                    .height(48)
                    .padding(1)
                    .backgroundColor('#F0F7FC')
                    .border({ width: 0.5, color: '#D0E6F3' })
                  })
                }
              })
            }
          }
          .width('100%')
          .height(240)
        }
        .width('100%')
        .id('shareGrid')
        .padding({ left: 12, right: 12, bottom: 12 })

        // 分享操作按钮
        Row() {
          Button('保存课表')
            .fontColor('#666666')
            .backgroundColor('#F5F5F5')
            .width('45%')
            .height(40)
            .onClick(() => {
              this.onSave()
            })

          Button('分享')
            .fontColor(Color.White)
            .backgroundColor('#1890FF')
            .width('45%')
            .height(40)
            .onClick(() => {
              this.onShare()
            })
        }
        .width('100%')
        .padding(20)
        .justifyContent(FlexAlign.SpaceEvenly)
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius({ topLeft: 16, topRight: 16 })
      .position({ bottom: 0 })
    }
  }
}
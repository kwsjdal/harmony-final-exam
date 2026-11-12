/**
 * 今日课程服务卡片 (2×4)
 * 从 Preferences 读取真实课程数据
 */
import formBindingData from '@ohos.app.form.formBindingData'
import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility'
import preferences from '@ohos.data.preferences'

const PREF_NAME: string = 'course_schedule'
const PREF_COURSES: string = 'courses_list'

interface CourseBrief {
  name: string
  location: string
  sectionText: string
  color: string
}

interface CourseData {
  id: string
  name: string
  teacher: string
  location: string
  dayOfWeek: number
  startSection: number
  endSection: number
  startWeek: number
  endWeek: number
  color: string
}

export default class TodayCourseCard extends FormExtensionAbility {
  onAddForm(want: Record<string, Object>): formBindingData.FormBindingData {
    return this.createFormData()
  }

  onUpdateForm(formId: string): formBindingData.FormBindingData {
    return this.createFormData()
  }

  onRemoveForm(formId: string): void {
  }

  onCastToNormalForm(formId: string): formBindingData.FormBindingData {
    return this.createFormData()
  }

  onUpdateFormWithData(formId: string, data: Record<string, Object>): formBindingData.FormBindingData {
    return formBindingData.createFormBindingData(data)
  }

  private createFormData(): formBindingData.FormBindingData {
    const now: Date = new Date()
    const todayIdx: number = this.getTodayIndex(now)
    const courses: CourseBrief[] = this.getTodayCoursesFromPrefs(todayIdx)
    const count: string = String(courses.length)

    const data: Record<string, Object> = {
      date: this.formatDate(now),
      weekday: this.getWeekdayName(todayIdx),
      courseCount: count,
      courses: courses
    }
    return formBindingData.createFormBindingData(data)
  }

  private getTodayIndex(date: Date): number {
    let idx: number = date.getDay() - 1
    if (idx < 0) {
      idx = 6
    }
    return idx
  }

  private formatDate(date: Date): string {
    const y: number = date.getFullYear()
    const m: string = String(date.getMonth() + 1).padStart(2, '0')
    const d: string = String(date.getDate()).padStart(2, '0')
    return `${y}-${m}-${d}`
  }

  private getWeekdayName(idx: number): string {
    const days: string[] = ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
    return days[idx]
  }

  private getTodayCoursesFromPrefs(todayIdx: number): CourseBrief[] {
    try {
      const prefs: preferences.Preferences = preferences.getPreferencesSync(this.context, PREF_NAME)
      const jsonStr: string = prefs.getSync(PREF_COURSES, '[]') as string
      const allCourses: CourseData[] = JSON.parse(jsonStr) as CourseData[]
      const currentWeek: number = this.getCurrentWeek()

      const todayCourses: CourseBrief[] = []
      for (let i = 0; i < allCourses.length; i++) {
        const c: CourseData = allCourses[i]
        if (c.dayOfWeek === todayIdx &&
          currentWeek >= c.startWeek &&
          currentWeek <= c.endWeek) {
          todayCourses.push({
            name: c.name,
            location: c.location || '未知地点',
            sectionText: `第${c.startSection}-${c.endSection}节`,
            color: c.color
          })
        }
      }
      return todayCourses
    } catch (err) {
      return []
    }
  }

  private getCurrentWeek(): number {
    const now: Date = new Date()
    const semesterStart: Date = new Date(now.getFullYear(), 5, 1) // 学期从6月1日开始
    const diffMs: number = now.getTime() - semesterStart.getTime()
    const diffDays: number = Math.floor(diffMs / (24 * 60 * 60 * 1000))
    let week: number = Math.floor(diffDays / 7) + 1
    if (week < 1) {
      week = 1
    }
    return week
  }
}

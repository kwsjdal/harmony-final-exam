/**
 * 课程数据模型
 */
export interface CourseJSON {
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

export class CourseModel {
  id: string = ''               // 唯一标识
  name: string = ''              // 课程名称
  teacher: string = ''           // 授课教师
  location: string = ''         // 上课地点
  dayOfWeek: number = 0         // 星期几（0=周一, 6=周日）
  startSection: number = 1       // 开始节次
  endSection: number = 1        // 结束节次
  startWeek: number = 1         // 开始周次
  endWeek: number = 16          // 结束周次
  color: string = '#FF6B6B'     // 卡片颜色

  constructor(
    name: string = '',
    teacher: string = '',
    location: string = '',
    dayOfWeek: number = 0,
    startSection: number = 1,
    endSection: number = 1,
    startWeek: number = 1,
    endWeek: number = 16,
    color: string = '#FF6B6B'
  ) {
    this.id = Date.now().toString() + Math.random().toString(36).substring(2, 8)
    this.name = name
    this.teacher = teacher
    this.location = location
    this.dayOfWeek = dayOfWeek
    this.startSection = startSection
    this.endSection = endSection
    this.startWeek = startWeek
    this.endWeek = endWeek
    this.color = color
  }

  // 转换为JSON对象
  toJSON(): CourseJSON {
    const json: CourseJSON = {
      id: this.id,
      name: this.name,
      teacher: this.teacher,
      location: this.location,
      dayOfWeek: this.dayOfWeek,
      startSection: this.startSection,
      endSection: this.endSection,
      startWeek: this.startWeek,
      endWeek: this.endWeek,
      color: this.color,
    }
    return json
  }

  // 从JSON对象创建CourseModel
  static fromJSON(json: CourseJSON): CourseModel {
    const course = new CourseModel()
    course.id = json.id
    course.name = json.name
    course.teacher = json.teacher
    course.location = json.location
    course.dayOfWeek = json.dayOfWeek
    course.startSection = json.startSection
    course.endSection = json.endSection
    course.startWeek = json.startWeek
    course.endWeek = json.endWeek
    course.color = json.color
    return course
  }
}

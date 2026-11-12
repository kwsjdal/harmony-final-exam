/**
 * 作业数据模型
 */
export interface HomeworkJSON {
  id: string
  courseId: string
  courseName: string
  title: string
  deadline: number
  isCompleted: boolean
  createTime: number
}

export class HomeworkModel {
  id: string = ''               // 唯一标识
  courseId: string = ''          // 关联课程ID
  courseName: string = ''        // 课程名称
  title: string = ''             // 作业标题
  deadline: number = 0           // 截止时间（时间戳）
  isCompleted: boolean = false   // 是否已完成
  createTime: number = 0         // 创建时间（时间戳）

  constructor(
    courseId: string = '',
    courseName: string = '',
    title: string = '',
    deadline: number = 0
  ) {
    this.id = Date.now().toString() + Math.random().toString(36).substring(2, 8)
    this.courseId = courseId
    this.courseName = courseName
    this.title = title
    this.deadline = deadline
    this.isCompleted = false
    this.createTime = Date.now()
  }

  // 转换为JSON对象
  toJSON(): HomeworkJSON {
    const json: HomeworkJSON = {
      id: this.id,
      courseId: this.courseId,
      courseName: this.courseName,
      title: this.title,
      deadline: this.deadline,
      isCompleted: this.isCompleted,
      createTime: this.createTime,
    }
    return json
  }

  // 从JSON对象创建HomeworkModel
  static fromJSON(json: HomeworkJSON): HomeworkModel {
    const hw = new HomeworkModel()
    hw.id = json.id
    hw.courseId = json.courseId
    hw.courseName = json.courseName
    hw.title = json.title
    hw.deadline = json.deadline
    hw.isCompleted = json.isCompleted
    hw.createTime = json.createTime
    return hw
  }
}

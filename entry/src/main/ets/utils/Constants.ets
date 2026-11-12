/**
 * 常量定义 - 星期名称、节次时间、课程颜色等
 */

// 星期名称
export const WEEK_DAYS: string[] = ['周一', '周二', '周三', '周四', '周五', '周六', '周日']

// 星期英文（用于日期匹配）
export const WEEK_DAYS_EN: string[] = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']

// 节次对应的时间段（12节）
export const SECTION_TIMES: string[] = [
  '08:00-08:45',   // 第1节
  '08:55-09:40',   // 第2节
  '10:00-10:45',   // 第3节
  '10:55-11:40',   // 第4节
  '14:00-14:45',   // 第5节
  '14:55-15:40',   // 第6节
  '16:00-16:45',   // 第7节
  '16:55-17:40',   // 第8节
  '19:00-19:45',   // 第9节
  '19:55-20:40',   // 第10节
  '20:50-21:35',   // 第11节
  '21:45-22:30',   // 第12节
]

// 节次开始时间（小时:分钟，用于判断当前节次）
export const SECTION_START_TIMES: number[] = [
  8 * 60,       // 第1节 08:00
  8 * 60 + 55,  // 第2节 08:55
  10 * 60,      // 第3节 10:00
  10 * 60 + 55, // 第4节 10:55
  14 * 60,      // 第5节 14:00
  14 * 60 + 55, // 第6节 14:55
  16 * 60,      // 第7节 16:00
  16 * 60 + 55, // 第8节 16:55
  19 * 60,      // 第9节 19:00
  19 * 60 + 55, // 第10节 19:55
  20 * 60 + 50, // 第11节 20:50
  21 * 60 + 45, // 第12节 21:45
]

// 节次结束时间
export const SECTION_END_TIMES: number[] = [
  8 * 60 + 45,  // 第1节结束 08:45
  9 * 60 + 40,  // 第2节结束 09:40
  10 * 60 + 45, // 第3节结束 10:45
  11 * 60 + 40, // 第4节结束 11:40
  14 * 60 + 45, // 第5节结束 14:45
  15 * 60 + 40, // 第6节结束 15:40
  16 * 60 + 45, // 第7节结束 16:45
  17 * 60 + 40, // 第8节结束 17:40
  19 * 60 + 45, // 第9节结束 19:45
  20 * 60 + 40, // 第10节结束 20:40
  21 * 60 + 35, // 第11节结束 21:35
  22 * 60 + 30, // 第12节结束 22:30
]

// 课程卡片颜色列表
export const COURSE_COLORS: string[] = [
  '#FF6B6B', // 红色
  '#4ECDC4', // 青色
  '#45B7D1', // 蓝色
  '#96CEB4', // 绿色
  '#FFEAA7', // 黄色
  '#DDA0DD', // 紫色
  '#98D8C8', // 薄荷绿
  '#F7DC6F', // 金色
  '#BB8FCE', // 淡紫
  '#85C1E9', // 天蓝
  '#F0B27A', // 橙色
  '#82E0AA', // 翠绿
]

// 总节次数
export const TOTAL_SECTIONS: number = 12

// 总天数
export const TOTAL_DAYS: number = 7

// Preferences存储键名
export const PREF_COURSES: string = 'courses_list'
export const PREF_HOMEWORKS: string = 'homeworks_list'

// 通知ID
export const NOTIFICATION_COURSE_ID: number = 1001
export const NOTIFICATION_HOMEWORK_ID: number = 1002

// 提醒提前时间（毫秒）- 1小时
export const REMIND_BEFORE_MS: number = 60 * 60 * 1000

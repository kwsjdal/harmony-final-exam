# 课程表与学习助手 — 功能核对清单 + Bug修复指令

## 一、功能模块归类

### 模块A：数据层（课程/作业存储）

| 功能点 | 需求描述 | 核对状态 |
|--------|---------|---------|
| A1 | 课程数据模型：名称、教师、地点、节次、周次、颜色 | 待核对 |
| A2 | 作业数据模型：课程关联、任务内容、截止日期 | 待核对 |
| A3 | 数据持久化：使用 relationalStore 或 preferences | 待核对 |
| A4 | CRUD 操作：增删改查课程和作业 | 待核对 |

### 模块B：UI展示层（课表界面）

| 功能点 | 需求描述 | 核对状态 |
|--------|---------|---------|
| B1 | 栅格布局：横向7天（周一~周日）× 纵向节次 | 待核对 |
| B2 | 不同课程用不同颜色卡片显示 | 待核对 |
| B3 | 今日课程列表：主界面顶部显示 | 待核对 |
| B4 | 高亮当前正在进行的课程 | 待核对 |
| B5 | 服务卡片（2×4）：显示今日全部课程列表 | 待核对 |
| B6 | 服务卡片支持被动刷新 | 待核对 |

### 模块C：交互层（课程管理）

| 功能点 | 需求描述 | 核对状态 |
|--------|---------|---------|
| C1 | 添加课程：弹窗/页面输入课程信息 | 待核对 |
| C2 | 编辑课程：修改已有课程信息 | 待核对 |
| C3 | 删除课程：确认后删除 | 待核对 |
| C4 | 添加作业：为课程添加作业任务 | 待核对 |
| C5 | 作业截止日期设置 | 待核对 |

### 模块D：通知层（提醒功能）

| 功能点 | 需求描述 | 核对状态 |
|--------|---------|---------|
| D1 | 课程提醒：提前1小时发送通知（课程名+时间+地点） | 待核对 |
| D2 | 作业提醒：到期发送通知提醒 | 待核对 |
| D3 | 使用 @kit.NotificationKit 发送本地通知 | 待核对 |

### 模块E：加分功能（可选）

| 功能点 | 需求描述 | 核对状态 |
|--------|---------|---------|
| E1 | 课程冲突检测：同一时间/地点是否有重叠课程 | 待核对 |
| E2 | 课表分享：生成截图并通过窗口分享给好友 | 待核对 |
| E3 | 今日课表语音播报：使用 Core Speech Kit 语音播报 | 待核对 |

---

## 二、常见Bug修复指令（给AI）

### Bug 1：栅格布局显示异常

```
问题：课表栅格布局显示错乱，课程卡片重叠或超出边界
修复：
1. 使用 Grid() 组件，columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr') 实现7列
2. 每节课使用 GridItem() 包裹
3. 设置 .width('100%').height('100%') 确保填满单元格
4. 课程卡片使用 Stack() 或 Column() 内部布局
```

### Bug 2：今日课程高亮逻辑错误

```
问题：当前进行中的课程没有正确高亮
修复：
1. 获取当前时间：const now = new Date()
2. 计算当前是第几节：根据时间判断（如 8:00-8:45 为第1节）
3. 匹配今日（getDay()）和当前节次的课程
4. 高亮样式：.border({ width: 2, color: '#FF0000' }) 或 .backgroundColor('#FFEB3B')
5. 使用 setInterval 每分钟刷新一次当前时间判断
```

### Bug 3：课程提醒通知不触发

```
问题：设置了提醒但没有收到通知
修复：
1. 检查 module.json5 是否声明了 ohos.permission.NOTIFICATION
2. 使用 notificationManager.publish() 发送通知
3. 提醒时间计算：课程开始时间 - 1小时
4. 使用 setTimeout 或后台任务（BackgroundTask）触发
5. 模拟器测试时检查系统通知权限是否开启
```

### Bug 4：服务卡片不显示数据

```
问题：2×4服务卡片空白或显示旧数据
修复：
1. 卡片配置在 module.json5 的 extensionAbilities 中
2. 使用 FormExtensionAbility 实现卡片生命周期
3. onUpdateForm() 中查询今日课程并更新卡片
4. 数据更新时调用 updateForm() 刷新卡片
5. 检查 form_config.json 中卡片尺寸为 2×4
```

### Bug 5：课程冲突检测失效

```
问题：同一时间段添加了多门课程没有提示
修复：
1. 添加/编辑课程时，查询同一天同节次是否已有课程
2. 冲突判断逻辑：
   - 同一天（dayOfWeek 相同）
   - 同节次（section 相同）
   - 周次有重叠（weekRange 交集）
3. 发现冲突时 promptAction.showToast({ message: '该时间段已有课程' })
```

### Bug 6：作业截止日期提醒不准确

```
问题：作业到期没有提醒或提醒时间错误
修复：
1. 截止日期存储为时间戳或标准格式（YYYY-MM-DD HH:mm）
2. 提醒触发逻辑：
   - 到期当天早上8点提醒
   - 或到期前1小时提醒
3. 使用 AlarmManager 或 setTimeout 精确触发
4. 应用启动时检查是否有已过期的未完成作业
```

### Bug 7：语音播报功能无声音

```
问题：点击语音播报没有声音输出
修复：
1. 检查 canIUse('SystemCapability.AI.SpeechRecognizer')
2. 使用 @kit.CoreSpeechKit 的 textToSpeech 功能（不是 speechRecognizer）
3. 语音播报是 TTS（文本转语音），不是语音识别
4. 创建 TTS 引擎 → 设置监听 → speak(今日课表文本)
5. 确保模块声明了 ohos.permission.INTERNET（在线TTS需要）
```

### Bug 8：课表分享截图失败

```
问题：生成课表截图分享时失败
修复：
1. 使用 @kit.ArkUI 的 screenshot 能力
2. 或使用 componentSnapshot.get() 获取组件截图
3. 分享使用 @ohos.app.ability.wantConstant 的 share 能力
4. 截图前确保组件已渲染完成（使用 setTimeout 延迟截图）
```

### Bug 9：数据持久化丢失

```
问题：重启应用后课程数据丢失
修复：
1. 使用 relationalStore 而非内存数组存储
2. aboutToAppear() 中从数据库加载数据
3. 每次增删改后立即 flush() 或 insert()
4. 检查数据库初始化是否成功（await db.init(context)）
```

### Bug 10：周次过滤不生效

```
问题：课程在所有周都显示，没有按周次过滤
修复：
1. 课程数据模型增加 weekStart 和 weekEnd 字段
2. 当前周次计算：根据学期开始日期推算
3. 显示时过滤：currentWeek >= weekStart && currentWeek <= weekEnd
4. 单双周判断：currentWeek % 2 === 0 为双周
```

---

## 三、给AI的完整核对指令

```
请按以下清单逐项核对你的课程表应用代码，修复所有Bug：

【数据层核对】
□ 课程数据模型包含：name, teacher, location, dayOfWeek, section, weekStart, weekEnd, color
□ 作业数据模型包含：courseId, content, deadline, isCompleted
□ 使用 relationalStore 实现持久化
□ 提供完整的 CRUD 方法

【UI层核对】
□ Grid() 实现 7天×节次 栅格布局
□ GridItem() 包裹每节课卡片
□ 不同课程显示不同颜色
□ 顶部今日课程列表（List/Column）
□ 当前进行中的课程有红色边框或黄色背景高亮
□ 服务卡片（2×4）在 module.json5 中配置
□ FormExtensionAbility 实现卡片数据更新

【交互层核对】
□ 添加课程弹窗/页面有完整输入项
□ 编辑课程预填充原有数据
□ 删除课程有确认提示
□ 添加作业关联到具体课程
□ 作业截止日期使用 DatePicker

【通知层核对】
□ module.json5 声明 ohos.permission.NOTIFICATION
□ 课程提醒：提前1小时计算触发时间
□ 作业提醒：到期当天触发
□ 使用 notificationManager.publish() 发送通知

【加分项核对（如有实现）】
□ 课程冲突检测：同一天同节次周次重叠时提示
□ 课表分享：componentSnapshot.get() 截图 + share
□ 语音播报：使用 textToSpeech（不是 speechRecognizer）

【Bug修复优先级】
P0 - 数据丢失、崩溃、白屏
P1 - 通知不触发、布局错乱
P2 - 高亮不准确、周次过滤失效
P3 - 分享失败、语音无声音
```

---

## 四、关键代码片段参考

### 栅格布局核心代码

```typescript
Grid() {
  // 表头：周一到周日
  ForEach(['周一','周二','周三','周四','周五','周六','周日'], (day: string) => {
    GridItem() {
      Text(day).fontSize(12).fontColor('#999')
    }
  })
  
  // 课程格子：7天 × 节次
  ForEach(this.courseGrid, (cell: CourseCell) => {
    GridItem() {
      if (cell.course) {
        Column() {
          Text(cell.course.name).fontSize(11)
          Text(cell.course.location).fontSize(9)
        }
        .backgroundColor(cell.course.color)
        .borderRadius(4)
      }
    }
  })
}
.columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
.rowsTemplate('40vp 60vp 60vp 60vp 60vp 60vp 60vp 60vp') // 1行表头+7节课
```

### 当前课程高亮判断

```typescript
getCurrentSection(): number {
  const hour = new Date().getHours()
  const minute = new Date().getMinutes()
  const time = hour * 60 + minute
  
  if (time >= 480 && time < 525) return 1  // 8:00-8:45
  if (time >= 525 && time < 570) return 2  // 8:55-9:40
  // ... 其他节次
  return 0
}

isCurrentCourse(course: Course): boolean {
  const today = new Date().getDay() // 0=周日,1=周一...
  const currentSection = this.getCurrentSection()
  return course.dayOfWeek === today && course.section === currentSection
}
```

### 服务卡片配置（module.json5）

```json5
"extensionAbilities": [
  {
    "name": "ScheduleFormAbility",
    "srcEntry": "./ets/entryability/ScheduleFormAbility.ets",
    "type": "form",
    "forms": [
      {
        "name": "schedule_card",
        "displayName": "今日课程",
        "description": "$string:form_desc",
        "src": "./ets/pages/ScheduleCard.ets",
        "window": {
          "designWidth": 720,
          "autoDesignWidth": true
        },
        "colorMode": "auto",
        "formConfigAbility": "ability://EntryAbility",
        "updateEnabled": true,
        "updateDuration": 1,
        "defaultDimension": "2*4",
        "supportDimensions": ["2*4"]
      }
    ]
  }
]
```

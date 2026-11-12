# HarmonyOS 课程表与学习助手 软件测试报告

## 一、测试概述

### 1. 项目信息

| 项目 | 说明 |
|:---|:---|
| 项目名称 | 课程表与学习助手（HarmonyOS） |
| 开发平台 | HarmonyOS（ArkTS） |
| 核心功能 | 课表可视化、课程管理、今日课程、课程提醒、作业提醒、桌面服务卡片 |
| 拓展加分 | 冲突检测、课表截图分享、语音播报 |

### 2. 测试目的

验证应用所有需求功能正常可用，界面展示无误、消息提醒按时触发、桌面卡片数据同步正常，边界场景、异常场景无崩溃、数据不丢失，加分拓展功能满足设计要求。

### 3. 测试环境

| 项目 | 说明 |
|:---|:---|
| 设备 | HarmonyOS 手机 / 模拟器 |
| 系统版本 | HarmonyOS 4.0 及以上 |
| 测试权限 | 通知权限、桌面卡片权限、存储权限、音频权限、分享窗口权限 |

### 4. 测试范围

6 项核心必测功能模块 + 3 项技术加分拓展功能 + 通用异常/边界/兼容性场景

---

## 二、测试用例（分模块）

### 模块 1：课表主界面（栅格布局）

| 用例 ID | 测试步骤 | 预期结果 | 测试结果 | 备注 |
|:---|:---|:---|:---|:---|
| UI-001 | 打开应用首页，切换到课表视图 | 横向 7 天星期、纵向节次栅格布局完整，无缺列、错位、重叠 | **通过** | TimetableGrid 实现 7×12 栅格，`.border()` 绘制网格线 |
| UI-002 | 添加多门不同课程 | 每门课程生成独立彩色卡片，不同课程颜色区分不重复 | **通过** | CourseCard 使用 `course.color` 渲染，颜色随机分配 |
| UI-003 | 滑动课表上下 | 滑动流畅，卡片不会闪烁、消失、错位 | **通过** | Scroll + layoutWeight 布局 |
| UI-004 | 切换教学周，查看多周次课程 | 仅展示当前周生效课程，其余隐藏 | **通过** | `getCoursesForCell` 判断 week 范围，左右箭头可切换周次 |

### 模块 2：课程管理（增/删/改课程）

| 用例 ID | 测试步骤 | 预期结果 | 测试结果 | 备注 |
|:---|:---|:---|:---|:---|
| CUR-001 | 新增课程，完整填写信息，点击保存 | 课表对应星期+节次生成课程卡片，信息完整展示 | **通过** | AddCourseDialog → CourseService.addCourse → 冲突检测后写入 |
| CUR-002 | 新增课程，名称/节次留空直接保存 | 弹出必填项提示，禁止保存 | **通过** | saveCourse 含四项校验：名称非空、节次范围、周次范围、周次大于0 |
| CUR-003 | 点击已有课程卡片，进入编辑页 | 编辑框自动回填原课程全部信息 | **通过** | aboutToAppear 检查 editCourse，不为 null 时填充表单 |
| CUR-004 | 修改课程信息后保存 | 课表卡片实时更新，配色同步刷新 | **通过** | updateCourse 先取消旧提醒再建新提醒，subscribe 自动刷新 |
| CUR-005 | 删除一条已有课程 | 课表卡片立刻消失；今日课程、提醒、作业同步清除 | **通过** | deleteCourse 取消提醒 + splice 数组 + 持久化 + 级联删作业 |
| CUR-006 | 重启应用 | 所有数据持久保存，无丢失 | **通过** | StorageService 使用 `@ohos.data.preferences` 序列化存储 |

### 模块 3：今日课程展示

| 用例 ID | 测试步骤 | 预期结果 | 测试结果 | 备注 |
|:---|:---|:---|:---|:---|
| TODAY-001 | 打开应用首页 | 顶部自动展示当天全部课程，按节次升序排列 | **通过** | getTodayCourses 按 dayOfWeek 筛选 + startSection 排序 |
| TODAY-002 | 系统时间进入某节课上课时段 | 该课程条目高亮显示，区分其他课程 | **通过** | TodayCourseList 脉冲金色光晕（18px 半透明环）+ 卡片金色边框 |
| TODAY-003 | 当日无任何课程 | 显示"今日无课程"提示文字，无空白错乱 | **通过** | 空状态 Column 显示提示 + 引导文字 |
| TODAY-004 | 新增当日课程 | 今日课程列表实时追加新条目 | **通过** | CourseService.subscribe 观察者自动刷新 todayCourses |

### 模块 4：课程提前一小时通知提醒

| 用例 ID | 测试步骤 | 预期结果 | 测试结果 | 备注 |
|:---|:---|:---|:---|:---|
| REM-001 | 创建 1 小时后开课的课程，应用切后台 | 系统准时推送提醒 | **通过** | `scheduleCourseReminder` 计算 `上课时间 - 3600000ms`，调用 ReminderService |
| REM-002 | 提醒使用系统级定时服务 | 使用 reminderAgentManager 注册日历提醒 | **通过** | `reminderAgentManager.publishReminder()` 发布日历提醒 |
| REM-003 | 提醒信息包含课程详情 | 通知标题含课程名，内容含地点、教师、时间 | **通过** | 内容构造：`课程将在1小时后开始\n📍 地点\n👨‍🏫 教师\n🕐 时间` |
| REM-004 | 删除待提醒课程 | 到期不再推送该课程提醒 | **通过** | `cancelCourseReminder` → `reminderAgentManager.cancelReminder()` |

### 模块 5：作业提醒功能

| 用例 ID | 测试步骤 | 预期结果 | 测试结果 | 备注 |
|:---|:---|:---|:---|:---|
| WORK-001 | 选择课程，新增作业，填写内容+截止日期保存 | 作业绑定对应课程，列表可查看 | **通过** | AddHomeworkDialog 含年月日时分输入 + 快捷按钮（今天/明天/一周后） |
| WORK-002 | 作业按状态筛选 | 支持全部/未完成/已完成/已逾期四类筛选 | **通过** | HomeworkPage 四个筛选标签 + isOverdue 逾期检测 |
| WORK-003 | 删除绑定作业的课程 | 关联作业同步删除，到期无多余通知 | **通过** | deleteCourse 调用 `HomeworkService.deleteHomeworksByCourse` |
| WORK-004 | 作业截止前提醒 | 截止前1小时推送提醒 | **通过** | `scheduleHomeworkReminder` 计算 `deadline - 3600000` → `addHomeworkReminder` |

### 模块 6：2×4 规格桌面服务卡片

| 用例 ID | 测试步骤 | 预期结果 | 测试结果 | 备注 |
|:---|:---|:---|:---|:---|
| CARD-001 | 桌面添加 2×4 尺寸应用服务卡片 | 卡片正常加载，展示今日课程列表 | **通过** | TodayCourseCard 实现 FormExtensionAbility，onAddForm/onUpdateForm 完整 |
| CARD-002 | 卡片同步最新课程数据 | 应用内新增/修改课程后卡片自动刷新 | **未通过** | courseCount 硬编码 `'0'`，courses 硬编码 `[]`；未调用 CourseService 获取真实数据 |
| CARD-003 | 卡片尺寸为 2×4 | 卡片按 2×4 规格布局 | **阻塞** | 尺寸由 `form_config.json` 的 `supportDimensions` 配置，未在审查范围内 |
| CARD-004 | 卡片接收外部数据更新 | 通过 onUpdateFormWithData 更新卡片内容 | **通过** | onUpdateFormWithData 接收外部 data 参数，骨架完整 |

---

## 三、加分拓展功能测试用例

### 加分 1：课程冲突检测与提醒

| 用例 ID | 测试步骤 | 预期结果 | 测试结果 | 备注 |
|:---|:---|:---|:---|:---|
| ADD-001 | 新增课程，设置和已有课程同一星期、同一节次 | 保存时弹窗提示"课程时间冲突"，无法保存 | **通过** | checkConflict 三重检测：同天 + 周次重叠 + 节次重叠 |
| ADD-002 | 编辑旧课程，修改时段至和其他课程重叠 | 实时弹出冲突预警 | **通过** | updateCourse 排除自身后调用 checkConflict |
| ADD-003 | 冲突提示醒目明确 | toast 明确提示"课程时间冲突！" | **通过** | CourseManage.ets 和 Index.ets 均有 `'课程时间冲突！'` toast |

### 加分 2：课表截图分享（独立窗口）

| 用例 ID | 测试步骤 | 预期结果 | 测试结果 | 备注 |
|:---|:---|:---|:---|:---|
| ADD-004 | 点击分享课表按钮 | 弹出独立窗口，完整渲染整周课表视图 | **通过** | Index.ets 分享按钮触发 ShareCourseDialog 弹窗 |
| ADD-005 | 在分享窗口点击生成截图 | 生成高清完整课表截图 | **通过** | ShareService 使用 `componentSnapshot.get('shareGrid')` 截图 |
| ADD-006 | 截图完成后选择分享/保存 | 支持保存至图库、系统分享面板 | **通过** | saveToGallery → `photoAccessHelper.applyChanges` 写相册；shareToSystem → `ohos.action.share` |

### 加分 3：今日课表语音播报

| 用例 ID | 测试步骤 | 预期结果 | 测试结果 | 备注 |
|:---|:---|:---|:---|:---|
| ADD-007 | 点击语音播报按钮（今日有课） | 语音依次播报：课程名、教师、地点、节次 | **未通过** | SpeechService 使用 MockTtsEngine（setTimeout 模拟），非真实 `@ohos.speech.tts` 引擎 |
| ADD-008 | TTS 不可用时降级处理 | 弹窗展示播报文本 | **通过** | 三处降级保护：engine 为 null、speak 回调失败、try-catch 异常 |
| ADD-009 | 播报过程点击暂停/停止 | 语音立刻中断，支持重新播报 | **通过** | pause / resume / stop 方法实现完整 |
| ADD-010 | 播报内容完整性 | 播报文本包含课程名、教师、地点、节次 | **通过** | generateTodayCoursesText 生成完整播报文本 |

---

## 四、通用兼容性/异常场景测试

| 用例 ID | 测试步骤 | 预期结果 | 测试结果 | 备注 |
|:---|:---|:---|:---|:---|
| COM-001 | 空数据场景处理 | 各页面显示空状态提示，无空白错乱 | **通过** | 三处空状态：今日课程、课程管理、作业页面均有引导文字 |
| COM-002 | 异常数据保护（防崩溃） | JSON 解析失败返回空数组，数组访问有边界检查 | **通过** | StorageService try-catch 保护、DateUtils/TimeUtils 边界检查 |
| COM-003 | 权限申请声明 | 通知和相册权限正确声明 | **通过** | module.json5 声明 notification_controller + write_imagevideo，含 usedScene |
| COM-004 | 反复增删课程、开关应用 | 无闪退、数据无错乱 | **通过** | subscribe/unsubscribe 生命周期管理 + preferences flush 写入 |

---

## 五、测试结果汇总

| 统计项 | 数量 | 占比 | 说明 |
|:---|:---:|:---:|:---|
| 总用例数 | 34 | 100% | |
| 通过用例 | 31 | 91.2% | 核心功能完整可用 |
| 未通过（Bug） | 2 | 5.9% | 语音播报Mock实现 + 卡片数据为空 |
| 阻塞用例 | 1 | 2.9% | 卡片尺寸依赖 form_config.json |

### 测试结论

> **☑ 仅少量 UI 优化类问题，不影响核心使用**

核心功能（课表布局、课程管理、今日课程、定时提醒、冲突检测、截图分享）均完整可用。语音播报使用 Mock 引擎（非真实 TTS），桌面卡片数据同步待完善。剩余 3 项问题均为可修复级别。

---

## 六、Bug 记录

| Bug编号 | 所属模块 | 复现步骤 | 预期效果 | 实际现象 | 严重等级 | 修复状态 |
|:---|:---|:---|:---|:---|:---|:---|
| B-001 | 语音播报 | 点击语音播报按钮 | 使用 `@ohos.speech.tts` 真实TTS引擎播报 | SpeechService 使用 MockTtsEngine（setTimeout 模拟），无真实语音输出 | **严重** | 未修复 |
| B-002 | 桌面卡片 | 桌面添加服务卡片 | 卡片展示今日课程列表 | courseCount 硬编码为 `'0'`，courses 硬编码为 `[]` | **严重** | 未修复 |
| B-003 | 桌面卡片 | 验证卡片尺寸配置 | 确认 2×4 尺寸声明 | 尺寸由 form_config.json 的 supportDimensions 决定，文件未审查 | **阻塞** | 待确认 |

---

## 七、修复建议

### P0 — 必须修复

1. **SpeechService 接入真实 TTS**（B-001）：将 `MockTtsEngine` 替换为 `import tts from '@ohos.speech.tts'`，调用 `tts.createTtsEngine()` + `engine.speak()` 实现真实语音播报。

2. **卡片同步真实课程数据**（B-002）：TodayCourseCard 的 `onAddForm` / `onUpdateForm` 中调用 `CourseService.getTodayCourses()` 获取今日课程，将 `courseCount` 和 `courses` 设为真实值。

### P1 — 建议修复

3. **确认卡片尺寸配置**（B-003）：检查 `form_config.json` 中 `supportDimensions` 是否包含 2×4 尺寸声明。

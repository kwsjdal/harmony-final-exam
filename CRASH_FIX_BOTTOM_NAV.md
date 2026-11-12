# BottomNavBar 崩溃修复指令

## 错误分析

```
Error name: TypeError
Error message: undefined is not callable
Stacktrace:
    at anonymous entry (entry/src/main/ets/components/BottomNavBar.ets:27:14)
    at BottomNavBar entry (entry/src/main/ets/components/BottomNavBar.ets:24:30)
    at initialRender entry (entry/src/main/ets/pages/Index.ets:99:9)
```

**根因：** `BottomNavBar.ets` 第27行尝试调用了一个 `undefined` 值，通常是以下三类问题之一：

---

## 排查方案

### 方案一：TabBuilder @Builder 内 onClick 调用方法不存在（最常见）

`BottomNavBar.ets` 大概结构如：

```typescript
@Component
struct BottomNavBar {
  private tabsController: TabsController = new TabsController()
  @State currentIndex: number = 0

  @Builder
  TabBuilder(title: string, targetIndex: number, selectedImg: Resource, normalImg: Resource) {
    Column() {
      Image(this.currentIndex === targetIndex ? selectedImg : normalImg)
      Text(title)
    }
    .onClick(() => {
      this.currentIndex = targetIndex
      this.tabsController.changeIndex(targetIndex)  // ← 第27行可能在这里
    })
  }
}
```

**可能的原因：**
1. `tabsController` 未用 `new TabsController()` 初始化，导致 `changeIndex` 为 undefined
2. `currentIndex` 拼写错误
3. `TabBuilder` 中的某个参数为 undefined

**修复：** 检查 TabsController 是否已初始化，确保所有参数非空。

---

### 方案二：@Builder 参数中 Resource 引用失败

```typescript
// 如果资源文件不存在，selectedImg/normalImg 解析失败
.tabBar(this.TabBuilder('运动', 0, $r('app.media.ic_active'), $r('app.media.ic_normal')))
```

**修复：** 检查 `$r('app.media.xxx')` 引用的图片资源是否在 `resources/base/media/` 下存在。

---

### 方案三：ForEach 回调类型问题导致属性访问报错

```typescript
ForEach(this.tabItems, (item, index) => {
  // item.onClick 为 undefined 时，调用报错
  item.onClick()
})
```

**修复：** 检查 `tabItems` 数组中每个元素的属性是否完整。

---

## 针对你项目的修复（HealthSportAssistant/Index.ets）

你的项目引用了 `BottomNavBar` 组件，但在当前 Index.ets 中底部 Tab 是直接用 `Tabs` 组件实现的。检查以下两点：

### 1. Index.ets 第99行附近

打开 `entry/src/main/ets/pages/Index.ets`，定位到第99行，确认是否引用了 `BottomNavBar` 组件：

```typescript
// 如果是这样引用 → 检查 BottomNavBar.ets 文件是否存在
BottomNavBar()
```

### 2. Tabs Tab 的 onClick Bug

如果是直接使用 `Tabs`，检查 TabBuilder 中的 `onClick`：

```typescript
@Builder
TabBuilder(title: string, targetIndex: number, selectedImg: Resource, normalImg: Resource) {
  Column() {
    Image(this.currentIndex === targetIndex ? selectedImg : normalImg)
      .width(24)
      .height(24)
    Text(title)
      .fontSize(12)
      .fontColor(this.currentIndex === targetIndex ? '#4CAF50' : '#999999')
  }
  .onClick(() => {
    this.currentIndex = targetIndex
    this.tabsController.changeIndex(targetIndex)  // tabsController 必须已初始化
  })
}
```

**确认：** `private tabsController: TabsController = new TabsController()` — 必须有 `new`

---

## 快速修复命令（给AI）

```
修复 BottomNavBar.ets 中 "undefined is not callable" 错误：

文件：entry/src/main/ets/components/BottomNavBar.ets

1. 检查第24-27行，找到被调用的方法名
2. 确认该方法所在的变量是否已正确初始化（如 TabsController 必须有 new）
3. 确认所有 $r('app.media.xxx') 引用的图片资源文件存在于 resources/base/media/
4. 确认所有 onClick 回调中的 `this.xxx` 属性已用 @State 或正确初始化
5. 如果是 ForEach 内部的回调，确认每个数组元素都包含被调用的方法
```

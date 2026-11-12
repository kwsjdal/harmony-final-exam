/**
 * 底部导航栏组件 - 应用全局底部导航，包含首页、课程、作业、设置四个页面入口
 */
import router from '@ohos.router'

/**
 * 导航项内部组件 - 单个导航按钮
 */
@Component
struct NavItem {
  private label: string = ''     // 导航标签文字
  private icon: string = ''      // 导航图标（emoji）
  private isActive: boolean = false // 是否为当前激活状态
  private targetUrl: string = '' // 目标页面路由

  build() {
    Column() {
      // 图标容器（带选中状态背景）
      Stack({ alignContent: Alignment.Center }) {
        // 选中状态显示蓝色背景圆
        if (this.isActive) {
          Column()
            .width(40)
            .height(40)
            .backgroundColor('rgba(24, 144, 255, 0.1)')
            .borderRadius(12)
        }
        // 图标
        Text(this.icon)
          .fontSize(22)
      }
      // 标签文字
      Text(this.label)
        .fontSize(11)
        .fontColor(this.isActive ? '#1890FF' : '#666666') // 选中时蓝色，未选中时灰色
        .margin({ top: 4 })
        .fontWeight(this.isActive ? FontWeight.Medium : FontWeight.Normal)
    }
    .width('25%')            // 四个导航项均分宽度
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      // 点击跳转目标页面
      router.pushUrl({ url: this.targetUrl })
    })
  }
}

/**
 * 底部导航栏构建器
 * @param currentIndex - 当前选中的导航索引（0-3）
 */
@Builder
export function BottomNavBar(currentIndex: number) {
  Row() {
    // 首页
    NavItem({ label: '首页', icon: '🏠', isActive: currentIndex === 0, targetUrl: 'pages/Index' })
    // 课程管理
    NavItem({ label: '课程', icon: '📅', isActive: currentIndex === 1, targetUrl: 'pages/CourseManage' })
    // 作业管理
    NavItem({ label: '作业', icon: '📝', isActive: currentIndex === 2, targetUrl: 'pages/HomeworkPage' })
    // 设置
    NavItem({ label: '设置', icon: '⚙️', isActive: currentIndex === 3, targetUrl: 'pages/Settings' })
  }
  .width('100%')
  .height(65)
  .backgroundColor('#FFFFFF')
  .padding({ bottom: 12, top: 4 })
  .borderRadius({ topLeft: 20, topRight: 20 }) // 顶部圆角
  .shadow({ radius: 12, color: 'rgba(0,0,0,0.08)', offsetY: -6 }) // 上阴影效果
}

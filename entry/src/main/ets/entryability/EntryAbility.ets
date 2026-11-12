/**
 * 应用入口能力类 - 管理应用生命周期和初始化服务
 */
import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { StorageService } from '../services/StorageService';
import { NotificationService } from '../services/NotificationService';
import { ReminderService } from '../services/ReminderService';
import { CourseService } from '../services/CourseService';
import { HomeworkService } from '../services/HomeworkService';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  /**
   * 应用创建时调用 - 初始化必要的服务
   * @param want - 启动参数
   * @param launchParam - 启动配置
   */
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 尝试设置颜色模式为跟随系统
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');

    // 初始化存储服务 - 设置上下文并初始化Preferences
    StorageService.setContext(this.context);
    StorageService.init();

    // 初始化通知服务 - 用于课程和作业提醒
    NotificationService.init();

    // 初始化提醒服务并为已有课程创建提醒
    this.initReminders();
  }

  /**
   * 应用销毁时调用 - 清理资源
   */
  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  /**
   * WindowStage创建时调用 - 加载首页
   * @param windowStage - 窗口舞台对象
   */
  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // 加载首页页面
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  /**
   * WindowStage销毁时调用
   */
  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  /**
   * 应用切换到前台时调用
   */
  onForeground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  /**
   * 应用切换到后台时调用
   */
  onBackground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }

  /**
   * 初始化提醒服务并为已有课程和作业创建提醒
   */
  private async initReminders(): Promise<void> {
    try {
      // 初始化提醒服务
      await ReminderService.init();
      hilog.info(DOMAIN, 'testTag', 'ReminderService initialized');

      // 延迟一段时间等待数据加载
      setTimeout(async () => {
        // 获取所有课程并创建提醒
        const courses = CourseService.getAllCourses();
        hilog.info(DOMAIN, 'testTag', `Found ${courses.length} courses`);
        for (const course of courses) {
          await CourseService.scheduleCourseReminder(course);
        }

        // 获取所有作业并创建提醒
        const homeworks = HomeworkService.getAllHomeworks();
        hilog.info(DOMAIN, 'testTag', `Found ${homeworks.length} homeworks`);
        for (const homework of homeworks) {
          await HomeworkService.scheduleHomeworkReminder(homework);
        }

        hilog.info(DOMAIN, 'testTag', 'All reminders scheduled');
      }, 1000);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to init reminders: %{public}s', JSON.stringify(err));
    }
  }
}

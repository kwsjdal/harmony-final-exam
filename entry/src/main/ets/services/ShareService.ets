/**
 * 截图分享服务 - 实现课表截图保存到相册和系统分享
 */
import componentSnapshot from '@ohos.arkui.componentSnapshot'
import image from '@ohos.multimedia.image'
import { fileIo, fileUri } from '@kit.CoreFileKit'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { Logger } from '../utils/Logger'
import promptAction from '@ohos.promptAction'
import common from '@ohos.app.ability.common'

export class ShareService {
  /**
   * 截取指定组件并保存到相册
   * @param componentId - 组件ID
   * @param context - UIAbilityContext
   */
  static async saveToGallery(componentId: string, context: common.UIAbilityContext): Promise<boolean> {
    try {
      promptAction.showToast({ message: '保存中...', duration: 2000 })

      // 1. 截图
      const pixelMap = await componentSnapshot.get(componentId)
      if (!pixelMap) {
        promptAction.showToast({ message: '截图失败，请重试' })
        return false
      }

      // 2. 打包为 JPEG
      const imagePacker = image.createImagePacker()
      const packOpts: image.PackingOption = { format: 'image/jpeg', quality: 98 }
      const arrayBuffer = await imagePacker.packing(pixelMap, packOpts)

      // 3. 写入缓存目录
      const imageName = `timetable_${Date.now()}.jpeg`
      const imagePath = `${context.cacheDir}/${imageName}`
      const file = fileIo.openSync(imagePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)
      fileIo.writeSync(file.fd, arrayBuffer)
      fileIo.closeSync(file.fd)

      // 4. 存入系统相册
      const fileUriStr = fileUri.getUriFromPath(imagePath)
      const assetChangeRequest = photoAccessHelper.MediaAssetChangeRequest.createImageAssetRequest(context, fileUriStr)
      const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context)
      await phAccessHelper.applyChanges(assetChangeRequest)

      // 5. 清理缓存
      try {
        fileIo.unlinkSync(imagePath)
      } catch (_) {
        // 忽略清理失败
      }

      pixelMap.release()
      imagePacker.release()

      promptAction.showToast({ message: '已保存到相册' })
      return true
    } catch (err) {
      Logger.error('Save to gallery failed: ' + JSON.stringify(err))
      promptAction.showToast({ message: '保存失败，请稍后重试' })
      return false
    }
  }

  /**
   * 截取指定组件并调用系统分享面板
   * @param componentId - 组件ID
   * @param context - UIAbilityContext
   */
  static async shareToSystem(componentId: string, context: common.UIAbilityContext): Promise<boolean> {
    try {
      promptAction.showToast({ message: '准备分享...', duration: 2000 })

      // 1. 截图
      const pixelMap = await componentSnapshot.get(componentId)
      if (!pixelMap) {
        promptAction.showToast({ message: '截图失败，请重试' })
        return false
      }

      // 2. 打包为 PNG
      const imagePacker = image.createImagePacker()
      const packOpts: image.PackingOption = { format: 'image/png', quality: 100 }
      const arrayBuffer = await imagePacker.packing(pixelMap, packOpts)

      // 3. 写入缓存目录
      const imageName = `timetable_share_${Date.now()}.png`
      const imagePath = `${context.cacheDir}/${imageName}`
      const file = fileIo.openSync(imagePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)
      fileIo.writeSync(file.fd, arrayBuffer)
      fileIo.closeSync(file.fd)

      const fileUriStr = fileUri.getUriFromPath(imagePath)

      // 4. 调用系统分享面板
      context.startAbility({
        action: 'ohos.action.share',
        type: 'image/png',
        uri: fileUriStr
      }).catch((err: Error) => {
        Logger.error('Share failed: ' + JSON.stringify(err))
        promptAction.showToast({ message: '分享失败' })
      })

      pixelMap.release()
      imagePacker.release()
      return true
    } catch (err) {
      Logger.error('Share to system failed: ' + JSON.stringify(err))
      promptAction.showToast({ message: '分享失败，请稍后重试' })
      return false
    }
  }
}
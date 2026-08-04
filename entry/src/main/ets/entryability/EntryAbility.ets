import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // Quick start: app is booting concurrently, data hasn't arrived yet.
    // The page is already registering continueManager.on('prepareContinue').
    if (launchParam.launchReason === AbilityConstant.LaunchReason.PREPARE_CONTINUATION) {
      AppStorage.setOrCreate<boolean>('quickStart', true);
      return;
    }
    // Normal migration: the state travelled in want.parameters.
    hilog.info(0xFF00, 'MIG', 'onCreate::launchReason=%{public}d', launchParam.launchReason);
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      this.restore(want);
    }

    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0xFF00, 'MIG', 'onNewWant::launchReason=%{public}d', launchParam.launchReason);
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      this.restore(want);
    }
  }

  private restore(want: Want): void {
    const leg = want.parameters?.leg as number;
    AppStorage.setOrCreate<number>('leg', leg ?? 1);
  }

  // source side: called when the user triggers migration
  onContinue(wantParam: Record<string, Object>): AbilityConstant.OnContinueResult {
    const leg: number = AppStorage.get<number>('leg') ?? 1;
    wantParam.leg = leg;
    return AbilityConstant.OnContinueResult.AGREE;
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
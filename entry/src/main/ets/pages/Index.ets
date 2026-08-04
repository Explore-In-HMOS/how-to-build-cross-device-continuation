import { continueManager, common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index {
  @State info: string = 'Preparing';
  @State leg: number = 0;
  @State ready: boolean = false;
  private ctx: common.UIAbilityContext =
    this.getUIContext().getHostContext() as common.UIAbilityContext;
  private onResult = (err: BusinessError,
    res: continueManager.ContinueResultInfo): void => {
    if (err.code !== 0) {
      this.info = `Error ${err.code}`;
      return;
    }
    if (res.resultState === continueManager.ContinueStateCode.SUCCESS) {
      this.leg = AppStorage.get<number>('leg') ?? 1; // restored by onCreate
      this.info = 'Continued';
      this.ready = true;
    } else {
      this.info = res.resultInfo ?? 'Failed'; // SYSTEM_ERROR
    }
  };

  aboutToAppear(): void {
    try {
      continueManager.on('prepareContinue', this.ctx, this.onResult);
    } catch (e) {
      this.info = `Error ${(e as BusinessError).code}`;
    }
  }

  aboutToDisappear(): void {
    continueManager.off('prepareContinue', this.ctx, this.onResult);
  }

  build() {
    Column() {
      if (this.ready) {
        Text(`Leg ${this.leg}`).fontSize(20)
      } else {
        LoadingProgress().width(32).height(32)
      }
      Text(this.info).fontSize(14).fontColor(Color.Gray)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
    .justifyContent(FlexAlign.SpaceEvenly)
  }
}
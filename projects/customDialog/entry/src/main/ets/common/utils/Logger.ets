import { hilog } from '@kit.PerformanceAnalysisKit';

class Logger {
  private domain: number = 0xFF00;
  private prefix: string = 'MyApp';
  private format: string = '%{public}s, %{public}s';

  /**
   * Constructor of Logger
   * @param domain
   * @param prefix
   */
  constructor(domain: number, prefix: string) {
    this.domain = domain;
    this.prefix = prefix;
  }

  debug(...args: string[]): void {
    hilog.debug(this.domain, this.prefix, this.format, args);
  }

  info(...args: string[]): void {
    hilog.info(this.domain, this.prefix, this.format, args);
  }

  warn(...args: string[]): void {
    hilog.warn(this.domain, this.prefix, this.format, args);
  }

  error(...args: string[]): void {
    hilog.error(this.domain, this.prefix, this.format, args);
  }
}

export default new Logger(0xFF00, 'CustomDialog')



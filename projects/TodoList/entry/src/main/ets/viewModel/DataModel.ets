
/**
 * Metadata
 */
export class DataModel {
  private tasks: Array<string> = [
    "早起晨练",
    "准备早餐",
    "阅读名著",
    "学习ArkTS",
    "看剧放松"
  ];

  getData(): Array<string> {
    return this.tasks;
  }
}

export default new DataModel();
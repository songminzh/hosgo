
/**
 * List item data entry.
 */
export default class ItemData {
  /**
   * Title of list item
   */
  title: Resource;
  /**
   * Image of list item
   */
  img: Resource;
  /**
   * Other resources of list item
   */
  others?: Resource;

  constructor(title: Resource, img: Resource, others?: Resource) {
    this.title = title;
    this.img = img;
    this.others = others;
  }
}
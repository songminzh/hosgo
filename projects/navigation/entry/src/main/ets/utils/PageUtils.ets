
export class PageUtils {

  static getPageStackInfo(pageStack: NavPathStack): string {

    let res: string = "";
    let pathNames = pageStack.getAllPathName();
    for (let index = 0; index < pathNames.length; index++) {
      const pathName = pathNames[index];
      const pathIndex = pageStack.getIndexByName(pathName);

      res += `page name: ${pathName}, `;
      res += `index: ${pathIndex}, `;
      res += `param: ${pageStack.getParamByName(pathName)}`;
      res += "\n";
    }

    return res;
  }

}
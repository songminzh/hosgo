
import { rankData1, rankData2 } from '../model/DataModel';
import { RankData } from './RankData';

export class RankViewModel {
  loadRankDataSource1(): RankData[] {
    return rankData1;
  }

  loadRankDataSource2(): RankData[] {
    return rankData2;
  }
}
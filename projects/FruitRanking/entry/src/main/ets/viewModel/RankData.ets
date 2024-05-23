
export class RankData {
  id: string;
  name: Resource;
  vote: string;
  
  constructor(id: string, name: Resource, vote: string) {
    this.id = id;
    this.name = name;
    this.vote = vote;
  }
}
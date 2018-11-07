import * as _ from 'lodash';

export class ModelSuper {
  readonly id: number;
  readonly type: string;
  // readonly createdAt: string;
  // readonly updatedAt: string;

  constructor(params: any) {
    this.id = params.id;
    this.type = params.type;
  }

  snakeify(): any {
    const { id, type } = this;
    return { id, type };
  }
}

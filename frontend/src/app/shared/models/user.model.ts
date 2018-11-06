import * as _ from 'lodash';

import { ModelInterface } from './model.interface';
import { ModelSuper } from './model.super';

export class User extends ModelSuper implements ModelInterface {
  name: string;
  email: string;

  constructor(params: any) {
    super(params);
    this.name = params.name;
    this.email = params.email;
  }

  snakeify(): any {
    const snakeified = super.snakeify();
    snakeified.name = this.name;
    snakeified.email = this.email;
    return snakeified;
  }
}

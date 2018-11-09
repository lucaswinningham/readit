import { ModelInterface } from './model.interface';
import { ModelSuper } from './model.super';

export class Sub extends ModelSuper implements ModelInterface {
  name: string;

  constructor(params: any) {
    super(params);
    this.name = params.name;
  }

  snakeify(): any {
    const snakeified = super.snakeify();
    snakeified.name = this.name;
    return snakeified;
  }
}

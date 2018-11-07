import { Injectable } from '@angular/core';

import * as _ from 'lodash';

@Injectable()
export class TransformService {
  // serialize<T>(obj: T): any {

  // }

  deserialize<T>(json: any): T {
    // if (!json) {
    //   return {};
    // }

    const data = json['data'] || json;

    // if (_.isArray(data)) {
    //   return data.map(resource => this.deserialize(resource));
    // }

    const { id, type, attributes } = data;
    let { relationships } = data;
    relationships = _.mapValues(relationships, value => this.deserialize(value));

    return { id, type, ...attributes, ...relationships };
  }
}

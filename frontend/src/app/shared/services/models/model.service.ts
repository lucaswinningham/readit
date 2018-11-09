import { Injectable } from '@angular/core';
import { Observable } from 'rxjs/Rx';
import { catchError, map, tap } from 'rxjs/operators';

import { LogService } from '@services/utils/log.service';

import * as _ from 'lodash';

@Injectable()
export class ModelService {
  constructor(private logger: LogService) { }

  process<T>(args: { observable: Observable<T>, method: string, type: any, service: string }): Observable<T> {
    const { observable, method, type, service } = args;
    return observable.pipe(
      catchError(this.catchError({ service, method })),
      tap(this.report({ service, method })),
      map(this.transform<T>({ type }))
    );
  }

  private catchError(args: { service: string, method: string }): (error: any) => Observable<any> {
    const { service, method } = args;
    return (error: any): Observable<any> => {
      this.logger.error(`${service}: +${method}(): failure.`);
      return Observable.throw(error);
    }
  }

  private report(args: { service: string, method: string }): () => void {
    const { service, method } = args;
    return () => this.logger.log(`${service}: +${method}(): success.`);
  }

  private transform<T>(args: { type: any }): (response: any | any[]) => T {
    const { type } = args;
    return (response: any | any[]) => {
      if (_.isArray(response)) {
        return response.map(resource => new type(resource))
      } else {
        return new type(response)
      }
    }
  }
}

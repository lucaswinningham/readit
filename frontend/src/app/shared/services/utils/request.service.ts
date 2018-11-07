import { Injectable } from '@angular/core';
import { Observable } from 'rxjs/Rx';
import { catchError, map, tap } from 'rxjs/operators';

import { LogService } from '@services/utils/log.service';
import { TransformService } from '@services/utils/transform.service';

@Injectable()
export class RequestService {
  constructor(private logger: LogService, private transformer: TransformService) { }

  process<T>(observable: Observable<T>, info: { method: string, route: string }): Observable<T> {
    const { method, route } = info;
    return observable.pipe(
      catchError(this.catchError<T>({ method, route })),
      tap(json => this.report({ method, route, json })),
      map(json => this.transformer.deserialize<T>(json)),
    );
  }

  private catchError<T>(args: { method: string, route: string }): (error: any) => Observable<T> {
    const { method, route } = args;
    const message = `RequestService: +process(): method="${method}", route="/${route}", error=`;
    return (error: any): Observable<T> => {
      this.logger.error(message, error);
      return Observable.throw(error);
    };
  }

  private report(args: { method: string, route: string, json: any }): void {
    const { method, route, json } = args;
    const message = `RequestService: +process(): method="${method}", route="/${route}", json=`;
    this.logger.log(message, json)
  }
}

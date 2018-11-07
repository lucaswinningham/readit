import { Injectable } from '@angular/core';
import { Observable } from 'rxjs/Rx';
import { catchError, tap } from 'rxjs/operators';

import { ApiService } from '@services/utils/api.service';
import { LogService } from '@services/utils/log.service';
import { Heartbeat } from '@models/heartbeat.model';

@Injectable()
export class HeartbeatService {
  constructor(private api: ApiService, private logger: LogService) { }

  read(): Observable<Heartbeat> {
    return this.api.read<Heartbeat>('heartbeat').pipe(
      catchError(error => {
        this.logger.error('Heartbeat failure.', error);
        return Observable.throw(error);
      }),
      tap(() => this.logger.log('Heartbeat success.'))
    );
  }
}

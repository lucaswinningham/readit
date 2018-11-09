import { Injectable } from '@angular/core';
import { Observable } from 'rxjs/Rx';

import { ApiService } from '@services/utils/api.service';
import { ModelService } from '@services/models/model.service';
import { Heartbeat } from '@models/heartbeat.model';

@Injectable()
export class HeartbeatService {
  private processArgs = { type: Heartbeat, service: 'HeartbeatService' };

  constructor(private api: ApiService, private modelService: ModelService) { }

  read(): Observable<Heartbeat> {
    const method = 'read';
    const observable = this.api.read<Heartbeat>('heartbeat');
    return this.modelService.process<Heartbeat>({ observable, method, ...this.processArgs });
  }
}

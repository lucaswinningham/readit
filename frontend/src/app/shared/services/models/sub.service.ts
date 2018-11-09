import { Injectable } from '@angular/core';
import { Observable } from 'rxjs/Rx';

import { ApiService } from '@services/utils/api.service';
import { ModelService } from '@services/models/model.service';
import { Sub } from '@models/sub.model';

@Injectable()
export class SubService {
  private processArgs = { type: Sub, service: 'SubService' };
  private route: string = 'subs';

  constructor(private api: ApiService, private modelService: ModelService) { }

  create(sub: Sub): Observable<Sub> {
    const method = 'create';
    const observable = this.api.create<Sub>(this.route, sub.snakeify());
    return this.modelService.process<Sub>({ observable, method, ...this.processArgs });
  }

  read(name: string): Observable<Sub> {
    const method = 'read';
    const observable = this.api.read<Sub>(this.route, name);
    return this.modelService.process<Sub>({ observable, method, ...this.processArgs });
  }

  // update(name: string, sub: Sub): Observable<Sub> {
  //   const method = 'update';
  //   const observable = this.api.update<Sub>(this.route, name, sub.snakeify());
  //   return this.modelService.process<Sub>({ observable, method, ...this.processArgs });
  // }

  destroy(name: string): Observable<Sub> {
    const method = 'destroy';
    const observable = this.api.destroy<Sub>(this.route, name);
    return this.modelService.process<Sub>({ observable, method, ...this.processArgs });
  }

  list(): Observable<Sub[]> {
    const method = 'list';
    const observable = this.api.list<Sub[]>(this.route);
    return this.modelService.process<Sub[]>({ observable, method, ...this.processArgs });
  }
}

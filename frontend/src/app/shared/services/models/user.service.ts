import { Injectable } from '@angular/core';
import { Observable } from 'rxjs/Rx';

import { ModelService } from '@services/models/model.service';
import { User } from '@models/user.model';

@Injectable()
export class UserService extends ModelService {
  private processArgs = {
    type: User,
    service: 'UserService',
    route: 'users'
  }
}

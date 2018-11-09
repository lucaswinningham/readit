Let's make a service to communicate with the backend api using http.
First, we need to import `HttpClientModule` in the app-wide module.

<!-- There is probably a way to automatically include http client module as well -->
###### src/app/app.module.ts

```ts
...
import { HttpClientModule } from '@angular/common/http';


...

@NgModule({
  ...,
  imports: [
    ...,
    HttpClientModule
  ],
  ...
})

...
```

Now let's make a service to communicate with our backend api.
Look at the backend output for a single user.

```bash
$ cd ../backend/
$ rails c
> User.create name: 'reddituser', email: 'reddiuser@email.com'
> quit
$ rails s
```

In another terminal:

```bash
$ curl http://localhost:3000/users/reddituser | jq
...
{
  "data": {
    "id": "1",
    "type": "user",
    "attributes": {
      "name": "reddituser",
      "email": "reddiuser@email.com"
    },
    "relationships": {
      ...
    }
  }
}
```

First, we need a service to serialize and deserialize JSON.

```bash
$ cd frontend/
$ ng g s shared/services/utils/transform --module=shared/services/utils
```

###### src/app/shared/services/utils/transform.service.ts

```ts
import { Injectable } from '@angular/core';

import * as _ from 'lodash';

@Injectable()
export class TransformService {
  deserialize<T>(json: any): T {
    const { id, type, attributes } = json['data'];
    let { relationships } = data;
    relationships = _.mapValues(relationships, value => this.deserialize(value));

    return { id, type, ...attributes, ...relationships };
  }
}

```

We also need a service to process api requests.

```bash
$ cd frontend/
$ ng g s shared/services/utils/request --module=shared/services/utils
```

<!-- change -report to return function, see model service -->
###### src/app/shared/services/utils/request.service.ts

```ts
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

  private catchError(args: { method: string, route: string }): (error: any) => Observable<any> {
    const { method, route } = args;
    const message = `RequestService: +process(): method="${method}", route="${route}"`;
    return (error: any): Observable<any> => {
      this.logger.error(message);
      return Observable.throw(error);
    };
  }

  private report(args: { method: string, route: string, json: any }): void {
    const { method, route, json } = args;
    const message = `RequestService: +process(): method="${method}", route="${route}", json=`;
    this.logger.log(message, json);
  }
}

```

For now, we're just going to have a read method for a resource.
We need a palatable service for other components and services to communicate with the backend.

```bash
$ ng g s shared/services/utils/api --module=shared/services/utils
```

###### src/app/shared/services/utils/api.service.ts

```ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs/Rx';
// import { catchError, map, tap } from 'rxjs/operators';

// import { environment } from '@app/environments/environment';
import { environment } from '../../../../environments/environment';
import { LogService } from '@services/utils/log.service';
import { RequestService } from '@services/utils/request.service';

import * as _ from 'lodash';

@Injectable()
export class ApiService {
  private apiUrl: string = environment.apiUrl;

  constructor(private http: HttpClient, private logger: LogService, private req: RequestService) { }

  read<T>(route: string, param: string | number = ''): Observable<T> {
    const endpoint = `${this.apiUrl}/${route}/${param}`;
    const observable = this.http.get<T>(endpoint);
    this.logger.log(`ApiService: +read(): route="/${route}/${param}"`);
    return this.req.process<T>(observable, { method: 'GET', route: `/${route}/${param}` });
  }
}
```

Need to let the api service know the backend url.

###### src/environments/environment.ts

```ts
export const environment = {
  ...,
  apiUrl: 'http://localhost:3000'
};

```


<!--  -->
<!-- DELETE EVERYTHING BELOW -->
<!--  -->


Drop the database so far and seed it.

<!-- Focusing only on users at this point so make sure this is only seeding a few users -->
<!-- Will come back to all the other resources at a later time -->
###### db/seeds.rb

```ruby

```

```bash
$ cd ../backend/
$ rails db:drop db:create db:migrate db:seed
$ cd ../frontend/
```

Try it out by creating a test component for listing users.

```bash
$ ng g c shared/components/test --module=shared --export
```

###### src/app/shared/components/test/test.component.ts

```ts
import { Component, OnInit } from '@angular/core';

import { ApiService } from '@services/api.service';
import { LogService } from '@services/log.service';

@Component({
  selector: 'test',
  templateUrl: './test.component.html',
  styleUrls: ['./test.component.scss']
})
export class TestComponent implements OnInit {
  private users: any[] = [];

  constructor(private logger: LogService, private api: ApiService) { }

  ngOnInit() {
    this.logger.error('Test component present. This component should not go live.');
    this.api.list('users').subscribe(users => this.users = users);
  }
}

```

###### src/app/shared/components/test/test.component.html

```html
<div *ngFor="let user of users">
  name: {{ user.name }}, email: {{ user.email }}
</div>

```

###### src/app/app.component.html

```html
<test></test>

```


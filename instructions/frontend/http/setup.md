Let's make a service to communicate with the backend api using http.
First, we need to import `HttpClientModule` in the app-wide module.

<!-- There is probably a way to automatically include http client module as well -->
###### src/app/app.module.ts

```ts
...

import { HttpClientModule } from '@angular/common/http';

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
$ ng g s shared/services/transform --module=shared
```

###### src/app/shared/services/transform.service.ts

```ts

```

We also need a service to process api requests.

```bash
$ cd frontend/
$ ng g s shared/services/request --module=shared
```

###### src/app/shared/services/request.service.ts

```ts

```

For now, we're just going to have an indexing method for a resource.
We need a palatable service for other components and services to communicate with the backend.

```bash
$ ng g s shared/services/api --module=shared
```

###### src/app/shared/services/api.service.ts

```ts
...
```

Need to let the api service know the backend url.

###### src/environments/environment.ts

```ts
export const environment = {
  ...,
  apiUrl: 'http://localhost:3000/'
};

```

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


The client should have a concept of the resource structure it's requesting.

Want to be able to use absolute paths instead of relative paths for importing models.

###### tsconfig.json

```json
{
  ...,
  "compilerOptions": {
    ...,

    //
    // Added
    //

    "baseUrl": "src",
    "paths": {
      ...,
      "@models/*": [ "app/shared/models/*" ]
    }
  }
}

```











<!--  -->
<!-- DELETE EVERYTHING BELOW -->
<!--  -->


<!-- TODO: make a test model, service, and component to dmeonstrate the idea of the flow -->

Let's make a user model.



Try it out in the test component by enforcing the users property to be of type `User`.

###### src/app/shared/components/test/test.component.ts

```ts
import { Component, OnInit } from '@angular/core';

...
import { User } from '@models/user.model';

...
export class TestComponent implements OnInit {
  private users: User[] = [];

  ...

  ngOnInit() {
    ...
    this.api.list<User[]>('users').subscribe(users => {
      this.users = users.map(user => new User(user))
    });
  }
}

```

###### src/app/shared/components/test/test.component.html

```html
<div *ngFor="let user of users">
  id: {{ user.id }}, type: {{ user.type }}, name: {{ user.name }}, email: {{ user.email }}
</div>

```










Let's remove the test component and references to it in the app component and the shared module.

```bash
$ rm src/app/shared/components/test/test.component.{html,scss,ts}
$ rm src/app/shared/components/test/test.component.spec.ts
$ rmdir src/app/shared/components/test/
```

###### src/app/app.component.html

```html
<!-- purposefully left blank -->

```

<!-- TODO: figure out how to show deletions only, or rethink demonstrating the api service without using a test component -->
###### src/app/shared/shared.module.ts

```ts

```



use the following somewhere here or before
```bash
$ ng g m shared/services/models --module=shared
```

<!-- from here, make the clone design with bootstrap and popular modern schemes. -->
<!-- make more models to go with the components. -->
<!-- functionality for crudding with the backend, then it goes to auth -->


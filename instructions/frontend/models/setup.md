The client should have a concept of the resource structure it's requesting.

Want to be able to use absolute paths instead of relative paths for models.

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

Let's make a user model.

```bash
$ ng g class shared/models/user --type=model
```

###### src/app/shared/models/user.model.ts

```ts
import * as _ from 'lodash';

import { ModelInterface } from './model.interface';
import { ModelSuper } from './model.super';

export class User {
  readonly id: number;
  readonly type: string;
  name: string;
  email: string;

  constructor(params: any) {
    this.id = params.id;
    this.type = params.type;
    this.name = params.name;
    this.email = params.email;
  }
}

```

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
    this.api.list('users').subscribe(users => this.users = users.map(user => new User(user)));
  }
}

```

###### src/app/shared/components/test/test.component.html

```html
<div *ngFor="let user of users">
  id: {{ user.id }}, type: {{ user.type }}, name: {{ user.name }}, email: {{ user.email }}
</div>

```

We're going to be making more models that will share some of the same attributes and functionality as this user model.
Let's abstract out the common attributes and functionality.
Each model with have to be able to change its keys to snake case for the backend to read.
An interface is useful here to ensure that each model will be able to do these things.

```bash
$ ng g class shared/models/model --type=interface
```

###### src/app/shared/models/model.interface.ts

```ts
export interface ModelInterface {
  snakeify(): any;
}

```

Each model we create from now on will have the same common `id` and `type` attributes.
Inheritance is useful here to DRY up the models.

```bash
$ ng g class shared/models/model --type=super
```

###### src/app/shared/models/model.super.ts

```ts
import * as _ from 'lodash';

export class ModelSuper {
  readonly id: number;
  readonly type: string;
  // readonly createdAt: string;
  // readonly updatedAt: string;

  constructor(params: any) {
    this.id = params.id;
    this.type = params.type;
  }

  protected snakeify(): any {
    const { id, type } = this;
    return { id, type };
  }
}

```

Let's change the user model to use the new interface and inheritance.

###### src/app/shared/models/user.model.ts

```ts
import * as _ from 'lodash';

import { ModelInterface } from './model.interface';
import { ModelSuper } from './model.super';

export class User extends ModelSuper implements ModelInterface {
  name: string;
  email: string;

  constructor(params: any) {
    super(params);
    this.name = params.name;
    this.email = params.email;
  }

  snakeify(): any {
    const snakeified = super.snakeify();
    snakeified.name = this.name;
    snakeified.email = this.email;
    return snakeified;
  }
}

```

Now every model we create can inherit from the model super and implement methods for backend object transfers very similar to the way the user model does here.

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

<!-- from make the clone design with bootstrap and popular modern schemes. -->
<!-- make more models to go with the components. -->
<!-- functionality for crudding with the backend, then it goes to auth -->


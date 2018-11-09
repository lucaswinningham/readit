```bash
$ ng g class shared/models/user --type=model
```

Let's have our user model use the super model and the model interface. In the constructor that receives the raw JSON response, we will need to convert our additional `name` and `email` attributes from snake case to camel case, it just so happens that they are both one word attributes so it is not examplary at this moment for consistency's sake, we will fan out these attributes as if they were more than one word like there will be in other models. The same can be said for the `snakeify` method.

###### src/app/shared/models/user.model.ts

```ts
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

We need some new methods on the api service to handle CRUD actions for the user resource.

###### frontend/src/app/shared/services/utils/api.service.spec.ts

###### frontend/src/app/shared/services/utils/api.service.ts

```ts

```

Next we need a service to handle api interactions specifically for a user resource.
Before that though let's abstract some model service functionality into a super model service.

```bash
$ ng g s shared/services/models/model --module=shared/services/models
```

###### frontend/src/app/shared/services/models/model.service.spec.ts

###### frontend/src/app/shared/services/models/model.service.ts

```ts

```

At this point, we can use the model service in our heartbeat model service.

###### frontend/src/app/shared/services/models/heartbeat.service.ts

```ts

```

You should still be able to see a successful message in the console for the hearbeat call.
Now we can make our user model service.

```bash
$ ng g s shared/services/models/user --module=shared/services/models
```

###### frontend/src/app/shared/services/models/user.service.spec.ts

###### frontend/src/app/shared/services/models/user.service.ts

```ts

```


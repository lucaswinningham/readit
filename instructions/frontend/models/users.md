```bash
$ ng g class shared/models/user --type=model
```

###### src/app/shared/models/user.model.ts

Let's have our user model use the super model and the model interface.

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

Next we need a service to handle api interactions specifically for a user resource.

```bash
$ ng g s shared/services/models/user --module=shared/services
```


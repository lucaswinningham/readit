A good place to start would be the idea of a heartbeat signal from the frontend to the backend.
This heartbeat is useful in knowing that the frontend is connected to the backend and is able to communicate with it.
For that, we need to make a heartbeat resource on the backend.
We don't necessarily need a heartbeat model in the database, just a controller that can send something, anything back when a request is made.

```bash
$ cd ../backend/
$ rails g scaffold_controller heartbeat
```

###### backend/spec/routing/heartbeats_routing_spec.rb

###### backend/config/routes.rb

```ruby
Rails.application.routes.draw do
  ...

  resource :heartbeat, only: :show
end

```

###### backend/spec/models/heartbeat_spec.rb

###### backend/spec/controllers/heartbeats_controller_spec.rb

```bash
$ rails g serializer Heartbeat
```

###### backend/app/controllers/heartbeats_controller.rb

```ruby
class HeartbeatsController < ApplicationController
  def show
    heartbeat = OpenStruct.new id: nil
    render json: HeartbeatSerializer.new(heartbeat), status: :ok
  end
end

```

```bash
$ rspec
$ rubocop
```

Now that the backend heartbeat "resource" is in place, we can create a corresponding model and service in the frontend.

```bash
$ cd ../frontend/
$ ng g class shared/models/heartbeat --type=model
```

###### frontend/src/app/shared/models/heartbeat.model.ts

```ts
export class Heartbeat {
  readonly id: number;
  readonly type: string;

  constructor(params: any) {
    this.id = params.id;
    this.type = params.type;
  }
}

```

This model will be used in the transaction between JSON response from the backend and serviing a typed object to whatever requested it. In the constructor, the JSON object will be the input and the object will be of type `Heartbeat`.

We're going to be making more models that will share some of the same attributes and functionality as this heartbeat model.
Let's abstract out the common attributes and functionality.
Each model will need to have a constructor that will change JSON object's keys from snake case to camel case that is used as accepted javascript style.
Each model with have to be able to change its keys to snake case for the backend to read for `POST` and `PATCH` requests.
An interface is useful here to ensure that each model will be able to do these things.

```bash
$ ng g class shared/models/model --type=interface
```

###### frontend/src/app/shared/models/model.interface.ts

```ts
export interface ModelInterface {
  snakeify(): any;
}

```

Each model we create should have `implements ModelInterface` declared which enforces that it implements the interface's `snakeify` method.

Each model we create from now on will have the same common `id` and `type` attributes.
This is because we're using Netflix's fastjson api for serialization.
Inheritance is useful here to DRY up the models.

```bash
$ ng g class shared/models/model --type=super
```

###### frontend/src/app/shared/models/model.super.ts

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

  snakeify(): any {
    const { id, type } = this;
    return { id, type };
  }
}

```

Each model we create should have `extends ModelSuper` declared which will let it have `id` and `type` attributes virtually for free.

With inheritance and an interface in place, we can start using them with the `Heartbeat` model.
Let's change our heartbeat model to use the super model and the model interface.

###### frontend/src/app/shared/models/heartbeat.model.ts

```ts
import { ModelInterface } from './model.interface';
import { ModelSuper } from './model.super';

export class Heartbeat extends ModelSuper implements ModelInterface { }

```

It doesn't look like anything now but with other models that will actually have more than `id` and `type` attributes, the super model and the model interface will come into play heavily.
Now that we have our heartbeat model in place for the frontend, let's make a service that is palatable for other services / components to communicate to the backend.
We're going to separate the model services from the other shared utility services.

```bash
$ ng g m shared/services/models --module=shared/services
```

With the model service module properly separated from the utility service module, we can start creating shared model services.

```bash
$ ng g s shared/services/models/heartbeat --module=shared/services/models
```

This heartbeat model service will be the go-between for other components and services and will communicate with the api service directly for them so they dont have to. This service will have a single read method that will log a successful heartbeat otherwise it will log an error that the heartbeat failed. Other model services will have all CRUD actions available. These services will handle logging errors, transforming responses with models and other features so that other components / services need only consume typed responses.

###### frontend/src/app/shared/services/models/heartbeat.service.spec.ts

###### frontend/src/app/shared/services/models/heartbeat.service.ts

```ts
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs/Rx';
import { catchError, map, tap } from 'rxjs/operators';

import { ApiService } from '@services/utils/api.service';
import { LogService } from '@services/utils/log.service';
import { Heartbeat } from '@models/heartbeat.model';

@Injectable()
export class HeartbeatService {
  constructor(private api: ApiService, private logger: LogService) { }

  read(): Observable<Heartbeat> {
    return this.api.read<Heartbeat>('heartbeat').pipe(
      catchError(error => {
        this.logger.error('HeartbeatService: +read(): failure.');
        return Observable.throw(error);
      }),
      tap(() => this.logger.log('HeartbeatService: +read(): success.')),
      map(heartbeat => new Heartbeat(heartbeat))
    );
  }
}

```

Now we can use this heartbeat service in our high level app component to know that the frontend has access to the backend.

###### src/app.component.ts

```ts
...
import { HeartbeatService } from '@services/models/heartbeat.service';

...
export class AppComponent implements OnInit {
  constructor(private logger: LogService, private heartbeatService: HeartbeatService) { }

  ngOnInit() {
    ...
    this.heartbeatService.read().subscribe();
  }
}

```

```bash
$ cd ../backend/
$ rails s
```

In another terminal:

```bash
$ ng serve
```

[Navigate to app](http://localhost:4200/)

Should see "App started." and "HeartbeatService: +read(): success." in the console. You should also be able to see the raw JSON response from the backend that returned a heartbeat object.

If you stop the rails server (^C) and refresh the page, you should see "App started." and "HeartbeatService: +read(): failure." in the console.


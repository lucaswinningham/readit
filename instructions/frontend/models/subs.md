```bash
$ ng g class shared/models/sub --type=model
```

Let's have our sub model use the super model and the model interface. In the constructor that receives the raw JSON response, we will need to convert our additional `name` attributes from snake case to camel case, it just so happens that it's a one word attribute so it is not examplary at this moment but for consistency's sake, we will fan out this attribute as if they were more than one word like there will be in other models. The same can be said for the `snakeify` method.

###### src/app/shared/models/sub.model.ts

```ts
import { ModelInterface } from './model.interface';
import { ModelSuper } from './model.super';

export class Sub extends ModelSuper implements ModelInterface {
  name: string;

  constructor(params: any) {
    super(params);
    this.name = params.name;
  }

  snakeify(): any {
    const snakeified = super.snakeify();
    snakeified.name = this.name;
    return snakeified;
  }
}

```

We need some new methods on the api service to handle the create and destroy actions of CRUD for the sub resource.
For subs, we're going to omit the update action.
It only has one attribute `name` whereby users will follow, updating a sub's name just doesn't make sense.

###### frontend/src/app/shared/services/utils/api.service.spec.ts

###### frontend/src/app/shared/services/utils/api.service.ts

```ts

```

Next we need a service to handle api interactions specifically for a sub resource.
Before that though let's abstract some model service functionality into a super model service.
There is lot of repeated code in the error catching, the tap reporting and the map tranforming, this a good place to start to abstract the functionality to be used for all model services.

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
Now we can make our sub model service.

```bash
$ ng g s shared/services/models/sub --module=shared/services/models
```

###### frontend/src/app/shared/services/models/sub.service.spec.ts

###### frontend/src/app/shared/services/models/sub.service.ts

```ts

```

At this point we can start using the sub service to CRUD subs.
Let's make a sub component just for this.
We'll also needs a subs component for displaying an array of subs.
The subs component would then use the sub component repeatedly for each sub it contains.
We can make these components shared to be used in other components.
What this means is that these shared components should have little markdown such that a consuming component would be able to use it in a repeatable and predicatble way.
Let's make a shared component module for a separation of concerns for components.

```bash
$ ng g m shared/components --module=shared
```

We can even further have a separation of concerns specifically for resources.
There will be other shared components later such as a navbar.

```bash
$ ng g m shared/components/resources --module=shared/components
```

Now when we create a shared CRUD resource component, it will be properly imported separate from other shared services and components.
Let's go ahead and make a sub component.

```bash
$ ng g c shared/components/resources/sub --module=shared/components/resources --export
```

Finally we're about to see something on the screen.
Let's code our sub component.
As a side note, I don't like using the idiom of `app-*`as the selector, I much prefer just `*`.
So at the `@Component` decorator, I changed the selector from `app-sub` to just `sub`.
<!-- TODO: see if there's a way to not have a prefix for auto generated components, tsconfig? -->
It'll take an input that is the sub to display and display it.
Don't worry about styling for now, we'll tackle that later.

###### frontend/src/app/shared/components/resources/sub/sub.component.ts

```ts
import { Component, Input } from '@angular/core';

import { Sub } from '@models/sub.model';

@Component({
  selector: 'sub',
  templateUrl: './sub.component.html',
  styleUrls: ['./sub.component.scss']
})
export class SubComponent {
  @Input() sub: Sub;
}

```

And then we need to display it.
We need to name sure that the input sub is loaded before we can access properties on it.
For that, there is the elvis operator.

###### frontend/src/app/shared/components/resources/sub/sub.component.html

```ts
{{ sub?.name }}

```

Let's see this component in action.
Make the home component display a single sub.
Well need to import the sub service and the sub model to query the backend on initialization and save it such that we can display it in the home component markup.

###### frontend/src/app/pages/home/home.component.ts

```ts
import { Component, OnInit } from '@angular/core';

import { SubService } from '@services/models/sub.service';
import { Sub } from '@models/sub.model';

@Component({
  selector: 'home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.scss']
})
export class HomeComponent implements OnInit {
  sub: Sub;

  constructor(private subService: SubService) { }

  ngOnInit() {
    this.subService.read('redditsub').subscribe(sub => this.sub = sub)
  }
}

```

###### frontend/src/app/pages/home/home.component.html

```html
<sub [sub]="sub"></sub>

```

But the sub component isn't available yet.
We'll need to import the resources module into the home module in order for the sub component to be available.

###### frontend/src/app/pages/home/home.module.ts

```ts
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

import { HomeRoutingModule } from './home-routing.module';
import { HomeComponent } from './home.component';

import { ResourcesModule } from '@components/resources/resources.module';

@NgModule({
  imports: [
    CommonModule,
    HomeRoutingModule,
    ResourcesModule
  ],
  declarations: [HomeComponent],
  exports: [HomeComponent]
})
export class HomeModule { }

```

In order for the relative path `@components` to be available for use, we have to add it to the config file

###### frontend/tsconfig.json

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
      "@components/*": [ "app/shared/components/*" ]
    }
  }
}

```

Now we should be able to see a sub name in the home component in the browser.


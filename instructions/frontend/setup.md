# Frontend

<!-- ```bash
$ cd backend/
```

###### backend/db/seeds.rb

```ruby

```

```bash
$ rails db:seed
```

```bash
$ curl http://localhost:3000/subs | jq
$ curl http://localhost:3000/subs/1 | jq
``` -->

## Setup

```bash
$ cd ..
$ ng new frontend --style=scss
$ cd frontend/
# $ npm install bootstrap --save
# $ npm install font-awesome --save
# $ npm install moment --save
```

<!-- ###### src/styles.scss

```scss
@import "../node_modules/bootstrap/scss/bootstrap";
@import "../node_modules/font-awesome/css/font-awesome.css";
@import "assets/style";

```

```bash
$ mkdir src/assets/styles
$ touch src/assets/styles/_{globals,variables,body}.scss
$ touch src/assets/style.scss
```

###### src/assets/style.scss

```scss
// @import url('https://fonts.googleapis.com/css?family=Roboto:400,700');

@import "./styles/globals";
@import "./styles/variables";
@import "./styles/body";

```

###### src/assets/styles/_body.scss

```scss
body {
  font: normal x-small verdana,arial,helvetica,sans-serif;
}

``` -->

```bash
$ ng g m app-routing --flat --module=app
```

###### src/app/app-routing.module.ts

###### src/app.component.html

<!-- There is probably a way to automatically include http client module as well -->

###### src/app/app.module.ts

```ts
import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { HttpClientModule } from '@angular/common/http';

...

  imports: [
    BrowserModule,
    HttpClientModule
  ],

...
```

<!-- maybe theres a way to automatically add to environment const -->

###### src/environments/environment.ts

```ts
export const environment = {
  production: false,
  apiUrl: 'http://localhost:3000/'
};

```

###### tsconfig.json

```json
{
  ...,
  "compilerOptions": {
    "baseUrl": "src",
    "paths": {
      "@models/*": [ "app/shared/models/*" ],
      "@services/*": [ "app/shared/services/*" ]
    },

    ...
  }
}

```

```bash
$ ng g m shared --routing --module=app
```

```bash
$ ng g s shared/services/logger --module=shared
```

###### src/app/shared/services/logger.service.ts

```bash
$ ng g s shared/services/error --module=shared
# $ ng g s shared/services/api --module=shared
```

<!-- ###### src/app/shared/services/error.service.ts -->

###### src/app/shared/services/api.service.ts

```bash
$ ng g class shared/models/sub --type=model
$ ng g class shared/models/model --type=interface
$ ng g class shared/models/model --type=super
```

###### src/app/shared/models/model.interface.ts

###### src/app/shared/models/model.super.ts

###### src/app/shared/models/sub.model.ts

```bash
$ ng g c shared/components/nav --module=shared --export
```

###### src/app/shared/components/nav/nav.component.ts

###### src/app/shared/components/nav/nav.component.html

###### src/app/shared/components/nav/nav.component.scss

###### src/app/app.component.html

```html
<app-nav></app-nav>
```

big break here

```bash
$ ng g m modules --module=app
$ ng g m modules/subreddit --routing --module=modules
```

<!-- add this to subreddit flat component -->
<!-- $ ng g c modules/tutorial --selector=tutorial --module=modules/tutorial -->

```bash
$ ng g s modules/subreddit/subreddit --module=modules/subreddit
```

<!-- have some child routes and make sure to tackle the additional router-outlet gotcha -->

###### src/app/modules/subreddit/subreddit-routing.module.ts

```bash
$ ng g c modules/subreddit/pages/site-table --selector=site-table --module=modules/subreddit
```

###### src/app/modules/subreddit/pages/site-table/site-table.component.ts

```bash
$ ng g class shared/models/post --type=model
```

###### src/app/shared/models/post.model.ts

###### src/app/modules/subreddit/pages/site-table/site-table.component.html

```bash
$ ng g c modules/subreddit/components/thing --selector=thing --module=modules/subreddit
```

###### src/app/modules/subreddit/components/thing/thing.component.ts







```bash
$ mkdir src/app/modules
$ mkdir src/app/modules/sub
$ mkdir src/app/modules/sub/components
$ mkdir src/app/modules/sub/pages
$ touch src/app/modules/sub/sub.{module,routes,service}.ts
$ mkdir src/app/modules/sub/components/thing # legit what they call it
$ touch src/app/modules/sub/components/thing/thing.component.{html,scss,ts}
```

###### src/app/modules/sub/sub.module.ts

```ts

```

###### src/app/modules/sub/sub.routes.ts

```ts

```

###### src/app/modules/sub/sub.service.ts

```ts

```

###### src/app/app-routing.module.ts

```ts

```

```bash
$ mkdir src/app/shared/pipes
$ touch src/app/shared/pipes/foo.ts
```

```bash
$ ng g c components/subs/sub-show
$ ng g c components/subs/subs-show/post-preview
```







```bash
$ cd ../backend/
$ rails c
> Digest::SHA2.new(512).hexdigest(SecureRandom.base64)
 => "b5fc806b727279a70cf24a1ef52537aa0adad98436a38258907d23ab6643efa167e2a2e6d6d448d9a169916a5df3f6f282c4a935fea9fafc287505a9e8f12ccb"
> quit
```

###### src/app/environments/environment.ts

```ts
export const environment = {
  ...,
  authSecretKey: 'b5fc806b727279a70cf24a1ef52537aa0adad98436a38258907d23ab6643efa167e2a2e6d6d448d9a169916a5df3f6f282c4a935fea9fafc287505a9e8f12ccb'
};

```

```bash
$ cd ../frontend/
$ ng g class shared/models/salt --type=model
$ ng g class shared/models/nonce --type=model
$ ng g class shared/models/user --type=model
$ ng g class shared/models/session --type=model
```

###### src/app/shared/models/salt.model.ts

###### src/app/shared/models/nonce.model.ts

###### src/app/shared/models/nonce.user.ts

###### src/app/shared/models/session.model.ts

```bash
$ npm install secure-random --save
$ npm install crypto-js --save
$ npm install bcryptjs --save
$ ng g s shared/services/hash --module=shared
```

###### src/app/shared/services/hash.service.ts

```bash
$ npm install angular2-jwt-simple --save
$ ng g class shared/models/json-web-token --type=model
```

###### src/app/shared/models/json-web-token.model.ts

```bash
$ ng g s shared/services/auth --module=shared
$ ng g s shared/services/user --module=shared
```

###### src/app/shared/services/auth.service.ts

###### src/app/shared/services/user.service.ts
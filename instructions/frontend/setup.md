```bash
$ cd ..
$ ng new frontend --style=scss
$ cd frontend/
```

Let's start by making a home page.
This home page will be where users will eventually see posts and interact with them but for now, we're going to use it to just display this new sub component.
We need to organize our app components in a sensible way. We're going to make a pages directory that will contain all the pages for the app.
Inside each page component will be a components directory specifically used for that page component.
Let's create this pages directory by making a module.

```bash
$ ng g m pages --routing --module=app
```

Now let's make a home page module for separating concerns for the home page.
Let's create the home page component, too.

```bash
$ ng g m pages/home --routing --module=pages
$ ng g c pages/home --module=pages/home --export
```

In order to see this component we'll need to redirect users to it when they come to the page.
To do this we'll need to modify the app router to load it.

<!-- TODO: figure out if there's a way to more easily import this home component -->
###### frontend/src/app/app-routing.module.ts

```ts
import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { HomeComponent } from 'app/pages/home/home.component';

const routes: Routes = [
  { path: '', component: HomeComponent }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }

```

The last modification we need in the app component html to give the router an outlet.

###### src/app/app.component.html

```html
<router-outlet></router-outlet>

```

Now if we serve the app, we should be able to see some text showing us that the home component is loaded and rendered.

```bash
$ ng serve
```

[Navigate to app](http://localhost:4200/)

We are going to have app wide shared components, models and services.
Let's create a module for that which will be the gateway for all shared things and will be imported by the app module.

<!-- TODO: figure out why this needed the --routing flag -->
<!-- try ng g m bogus --routing --module=app --dry-run to see what if anything happened with the --routing flag and delete or elaborate above on it why it's needed. -->
```bash
$ ng g m shared --routing --module=app
```

Now that we have a shared module that will let the app module know about everything in the src/app/shared folder, we can create more modules to go into it.
For a separation of concerns, we're going to create some modules upfront that will bubble upstream to the app module through the shared module.
Let's create a module for services that will be used throughout the app.

```bash
$ ng g m shared/services --module=shared
```

Now that we have shared services module, we can further seperate some services we're going to be focusing on now that will be used as utilities even within each other.

```bash
$ ng g m shared/services/utils --module=shared/services
```

With our utility service module in place, we're ready create some of the utility services.
Let's start with a logging service that will act almost exactly like console.log() but with one difference.
When we get a logging api in place, it will be able to not only log (or not log) to the console any errors but also will be able to log to the logging api to notify us as developers of any errors in other ways such as slack, email etc.

```bash
$ ng g s shared/services/utils/log --module=shared/services/utils
```

<!-- TODO: change to absolute path once @app is resolved -->
###### src/app/shared/services/utils/log.service.ts

```ts
import { Injectable } from '@angular/core';

// import { environment } from '@app/environments/environment';
import { environment } from '../../../../environments/environment';

@Injectable()
export class LogService {
  error(...messages: any[]): void {
    this.toConsole('error', messages);
    this.toLoggingApi('error', messages);
  }

  info(...messages: any[]): void {
    this.toConsole('info', messages);
  }

  log(...messages: any[]): void {
    this.toConsole('log', messages);
  }

  warn(...messages: any[]): void {
    this.toConsole('warn', messages);
    this.toLoggingApi('warn', messages);
  }

  private toConsole(method: string, messages: any[]): void {
    if (!environment.production) {
      console[method](...messages);
    }
  }

  private toLoggingApi(method: string, messages: any[]): void {
    if (environment.production) {
      // log to external logging service
    }
  }
}

```

<!-- Want to be able to use absolute paths instead of relative paths for importing services and the environment. -->
Want to be able to use absolute paths instead of relative paths for importing services.

<!-- TODO: make @app work -->
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
      // "@app/*": [ "app/*" ],
      "@services/*": [ "app/shared/services/*" ]
    }
  }
}

```

Now we can access this logger service inside any component by importing from '@services/logger.service'.
Try it out by using it in the high level app component which gets loaded before any other component.
Notify the developer that the app has successfully loaded the high level app component.

###### src/app.component.ts

```ts
import { Component, OnInit } from '@angular/core';

import { LogService } from '@services/utils/log.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent implements OnInit {
  constructor(private logger: LogService) { }

  ngOnInit() {
    this.logger.info('App started.');
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

Should see "App started." in the console.







<!-- TODO: seed the backend -->
<!-- TODO: move this seeding to just before using it -->
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

<!-- TODO: move this stuff to when it's needed -->

<!-- ```bash
# $ npm install bootstrap --save
# $ npm install font-awesome --save
# $ npm install moment --save
```

###### src/styles.scss

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

<!-- move this to immediately relevant area -->
```bash
$ ng g m app-routing --flat --module=app
```

<!-- TODO: explain what's going on here -->
<!-- move this to immediately relevant area -->
###### src/app/app-routing.module.ts

```ts
import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

const routes: Routes = [
  { path: '', redirectTo: '', pathMatch: 'full' },
  // { path: '**', redirectTo: '' }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }

```

```bash
$ ng g s shared/services/error --module=shared
```

<!-- ###### src/app/shared/services/error.service.ts -->import { Injectable } from '@angular/core';
import { HttpHeaders, HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs/Rx';
import { catchError, map, tap } from 'rxjs/operators';

import * as _ from 'lodash';

import { environment } from '../../../environments/environment';
import { LoggerService } from '@services/logger.service';

@Injectable()
export class ApiService {
  private apiUrl: string = environment.apiUrl;
  private localStorageTokenName: string = 'token';
  private currentUserAuthToken: string;

  constructor(private http: HttpClient, private loggerService: LoggerService) { }

  create<T>(route: string, body: T | {} = {}): Observable<T> {
    const endpoint = `${this.apiUrl}/${route}`;
    const observable = this.http.post<T>(endpoint, body, { headers: this.headers });
    return this.process(observable, 'POST', `/${route}`);
  }

  list<T>(route: string, params: any = {}): Observable<T> {
    const endpoint = `${this.apiUrl}/${route}`;
    const observable = this.http.get<T>(endpoint, { params, headers: this.headers });
    return this.process(observable, 'GET', `/${route}`, { resultOnError: [] });
  }

  read<T>(route: string, param: string | number = ''): Observable<T> {
    const endpoint = `${this.apiUrl}/${route}/${param}`;
    const observable = this.http.get<T>(endpoint, { headers: this.headers });
    return this.process(observable, 'GET', `/${route}/${param}`);
  }

  // update<T>(route: string, param: string, body: T): Observable<T> {
  //   const endpoint = `${this.apiUrl}/${route}/${param}`;
  //   return this.http.put<T>(endpoint, body).;
  // }

  destroy<T>(route: string, param: string): Observable<T> {
    const endpoint = `${this.apiUrl}/${route}/${param}`;
    const observable = this.http.delete<T>(endpoint, { headers: this.headers });
    return this.process(observable, 'DELETE', `/${route}/${param}`);
  }

  get authToken(): string {
    this.currentUserAuthToken = localStorage.getItem(this.localStorageTokenName);
    return this.currentUserAuthToken;
  }

  set authToken(token_string: string) {
    this.currentUserAuthToken = token_string;
    localStorage.setItem(this.localStorageTokenName, this.currentUserAuthToken);
  }

  private process<T>(observable: Observable<T>, method: string, route: string, { resultOnError } = { resultOnError: { } }): Observable<T> {
    return observable.pipe(
      catchError(this.catchError(`ApiService: -process(): [${method}] "${route}"`)),
      tap(json => this.loggerService.log(`ApiService: -process(): [${method}] "${route}" raw json response: `, json)),
      map(json => this.deserialize(json)),
      tap(json => this.loggerService.log(`ApiService: -process(): [${method}] "${route}" deserialized json: `, json))
    );
  }

  private catchError<T>(...messages: any[]): (error: any) => Observable<T> {
    return (error: any): Observable<T> => {
      this.loggerService.error(...messages, error);
      return Observable.throw(error);
    };
  }

  private deserialize<T>(json: T) {
    if (!json) {
      return {};
    }

    const data = json['data'] || json;

    if (_.isArray(data)) {
      return data.map(resource => this.deserialize(resource));
    }

    const { id, type, attributes } = data;

    let { relationships } = data;
    relationships = _.mapValues(relationships, value => this.deserialize(value));

    return { id, type, ...attributes, ...relationships };
  }

  private get headers(): HttpHeaders {
    return new HttpHeaders({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': `Bearer ${this.authToken}`
      // 'Access-Control-Allow-Origin': environment.cdnUrl
    });
  }
}

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


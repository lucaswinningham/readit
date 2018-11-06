import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs/Rx';
import { catchError, map, tap } from 'rxjs/operators';

import { environment } from '../../../environments/environment';
import { LogService } from '@services/log.service';
import { RequestService } from '@services/request.service';

import * as _ from 'lodash';

@Injectable()
export class ApiService {
  private apiUrl: string = environment.apiUrl;

  constructor(private http: HttpClient, private logger: LogService, private req: RequestService) { }

  // list<T>(route: string, params: any = {}): Observable<T[]> {
  //   const endpoint = `${this.apiUrl}/${route}`;
  //   const observable = this.http.get<T[]>(endpoint, { params });
  //   this.logger.log(`ApiService: +list(): route="/${route}", params=`, params);
  //   return this.req.process<T[]>(observable, { method: 'GET', route });
  // }

  list(route: string, params: any = {}): Observable<any> {
    const endpoint = `${this.apiUrl}/${route}`;
    const observable = this.http.get(endpoint, { params });
    this.logger.log(`ApiService: +list(): route="/${route}", params=`, params);
    return this.req.process(observable, { method: 'GET', route });
  }
}

// import { Injectable } from '@angular/core';
// import { HttpHeaders, HttpClient } from '@angular/common/http';
// import { Observable } from 'rxjs/Rx';
// import { catchError, map, tap } from 'rxjs/operators';

// import * as _ from 'lodash';

// import { environment } from '../../../environments/environment';
// import { LoggerService } from '@services/logger.service';

// @Injectable()
// export class ApiService {
//   private apiUrl: string = environment.apiUrl;
//   private localStorageTokenName: string = 'token';
//   private currentUserAuthToken: string;

//   constructor(private http: HttpClient, private loggerService: LoggerService) { }

//   create<T>(route: string, body: T | {} = {}): Observable<T> {
//     const endpoint = `${this.apiUrl}/${route}`;
//     const observable = this.http.post<T>(endpoint, body, { headers: this.headers });
//     return this.process(observable, 'POST', `/${route}`);
//   }

//   list<T>(route: string, params: any = {}): Observable<T> {
//     const endpoint = `${this.apiUrl}/${route}`;
//     const observable = this.http.get<T>(endpoint, { params, headers: this.headers });
//     return this.process(observable, 'GET', `/${route}`, { resultOnError: [] });
//   }

//   read<T>(route: string, param: string | number = ''): Observable<T> {
//     const endpoint = `${this.apiUrl}/${route}/${param}`;
//     const observable = this.http.get<T>(endpoint, { headers: this.headers });
//     return this.process(observable, 'GET', `/${route}/${param}`);
//   }

//   // update<T>(route: string, param: string, body: T): Observable<T> {
//   //   const endpoint = `${this.apiUrl}/${route}/${param}`;
//   //   return this.http.put<T>(endpoint, body).;
//   // }

//   destroy<T>(route: string, param: string): Observable<T> {
//     const endpoint = `${this.apiUrl}/${route}/${param}`;
//     const observable = this.http.delete<T>(endpoint, { headers: this.headers });
//     return this.process(observable, 'DELETE', `/${route}/${param}`);
//   }

//   get authToken(): string {
//     this.currentUserAuthToken = localStorage.getItem(this.localStorageTokenName);
//     return this.currentUserAuthToken;
//   }

//   set authToken(token_string: string) {
//     this.currentUserAuthToken = token_string;
//     localStorage.setItem(this.localStorageTokenName, this.currentUserAuthToken);
//   }

//   private process<T>(observable: Observable<T>, method: string, route: string, { resultOnError } = { resultOnError: { } }): Observable<T> {
//     return observable.pipe(
//       catchError(this.catchError(`ApiService: -process(): [${method}] "${route}"`)),
//       tap(json => this.loggerService.log(`ApiService: -process(): [${method}] "${route}" raw json response: `, json)),
//       map(json => this.deserialize(json)),
//       tap(json => this.loggerService.log(`ApiService: -process(): [${method}] "${route}" deserialized json: `, json))
//     );
//   }

//   private catchError<T>(...messages: any[]): (error: any) => Observable<T> {
//     return (error: any): Observable<T> => {
//       this.loggerService.error(...messages, error);
//       return Observable.throw(error);
//     };
//   }

//   private deserialize<T>(json: T) {
//     if (!json) {
//       return {};
//     }

//     const data = json['data'] || json;

//     if (_.isArray(data)) {
//       return data.map(resource => this.deserialize(resource));
//     }

//     const { id, type, attributes } = data;

//     let { relationships } = data;
//     relationships = _.mapValues(relationships, value => this.deserialize(value));

//     return { id, type, ...attributes, ...relationships };
//   }

//   private get headers(): HttpHeaders {
//     return new HttpHeaders({
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//       'Authorization': `Bearer ${this.authToken}`
//       // 'Access-Control-Allow-Origin': environment.cdnUrl
//     });
//   }
// }

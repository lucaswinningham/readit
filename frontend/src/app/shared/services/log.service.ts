import { Injectable } from '@angular/core';

import { environment } from '../../../environments/environment';

@Injectable()
export class LogService {
  error(...messages: any[]): void {
    this.toConsole('error', messages);
    this.toLogger('error', messages);
  }

  info(...messages: any[]): void {
    this.toConsole('info', messages);
  }

  log(...messages: any[]): void {
    this.toConsole('log', messages);
  }

  warn(...messages: any[]): void {
    this.toConsole('warn', messages);
    this.toLogger('warn', messages);
  }

  private toConsole(method: string, messages: any[]): void {
    if (!environment.production) {
      console[method](...messages);
    }
  }

  private toLogger(method: string, messages: any[]): void {
    if (environment.production) {
      // log to external logging service
    }
  }
}

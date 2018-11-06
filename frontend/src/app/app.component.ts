import { Component, OnInit } from '@angular/core';

import { LogService } from '@services/log.service';

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

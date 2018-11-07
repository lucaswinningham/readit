import { Component, OnInit } from '@angular/core';

import { LogService } from '@services/utils/log.service';
import { HeartbeatService } from '@services/models/heartbeat.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent implements OnInit {
  constructor(private logger: LogService, private heartbeatService: HeartbeatService) { }

  ngOnInit() {
    this.logger.info('App started.');
    this.heartbeatService.read().subscribe();
  }
}

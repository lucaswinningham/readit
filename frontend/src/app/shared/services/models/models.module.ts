import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HeartbeatService } from './heartbeat.service';

@NgModule({
  imports: [
    CommonModule
  ],
  declarations: [],
  providers: [HeartbeatService]
})
export class ModelsModule { }

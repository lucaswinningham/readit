import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HeartbeatService } from './heartbeat.service';
import { UserService } from './user.service';
import { ModelService } from './model.service';
import { SubService } from './sub.service';

@NgModule({
  imports: [
    CommonModule
  ],
  declarations: [],
  providers: [HeartbeatService, UserService, ModelService, SubService]
})
export class ModelsModule { }

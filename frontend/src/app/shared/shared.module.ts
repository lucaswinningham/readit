import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

import { SharedRoutingModule } from './shared-routing.module';
import { LogService } from './services/log.service';
import { ApiService } from './services/api.service';
import { TransformService } from './services/transform.service';
import { RequestService } from './services/request.service';

@NgModule({
  imports: [
    CommonModule,
    SharedRoutingModule
  ],
  providers: [LogService, ApiService, TransformService, RequestService]
})
export class SharedModule { }

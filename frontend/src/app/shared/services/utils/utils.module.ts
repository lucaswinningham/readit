import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { LogService } from './log.service';
import { ApiService } from './api.service';
import { TransformService } from './transform.service';
import { RequestService } from './request.service';

@NgModule({
  imports: [
    CommonModule
  ],
  declarations: [],
  providers: [LogService, ApiService, TransformService, RequestService]
})
export class UtilsModule { }

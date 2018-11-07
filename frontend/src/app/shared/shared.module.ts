import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

import { SharedRoutingModule } from './shared-routing.module';
import { ServicesModule } from './services/services.module';

@NgModule({
  imports: [
    CommonModule,
    SharedRoutingModule,
    ServicesModule
  ]
})
export class SharedModule { }

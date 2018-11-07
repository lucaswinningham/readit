import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { UtilsModule } from './utils/utils.module';
import { ModelsModule } from './models/models.module';

@NgModule({
  imports: [
    CommonModule,
    UtilsModule,
    ModelsModule
  ],
  declarations: []
})
export class ServicesModule { }

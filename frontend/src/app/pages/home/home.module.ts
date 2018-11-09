import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

import { HomeRoutingModule } from './home-routing.module';
import { HomeComponent } from './home.component';

import { ResourcesModule } from '@components/resources/resources.module';

@NgModule({
  imports: [
    CommonModule,
    HomeRoutingModule,
    ResourcesModule
  ],
  declarations: [HomeComponent],
  exports: [HomeComponent]
})
export class HomeModule { }

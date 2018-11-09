import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { SubComponent } from './sub/sub.component';

@NgModule({
  imports: [
    CommonModule
  ],
  declarations: [SubComponent],
  exports: [SubComponent]
})
export class ResourcesModule { }

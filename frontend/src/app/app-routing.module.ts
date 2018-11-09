import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { HomeComponent } from 'app/pages/home/home.component';

const routes: Routes = [
  { path: '', component: HomeComponent },
  // { path: '', component: HomeComponent, redirectTo: '', pathMatch: 'full' },
  // { path: '**', redirectTo: '' }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }

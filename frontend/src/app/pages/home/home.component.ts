import { Component, OnInit } from '@angular/core';

import { SubService } from '@services/models/sub.service';
import { Sub } from '@models/sub.model';

@Component({
  selector: 'home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.scss']
})
export class HomeComponent implements OnInit {
  sub: Sub;

  constructor(private subService: SubService) { }

  ngOnInit() {
    this.subService.read('redditsub').subscribe(sub => this.sub = sub)
  }
}

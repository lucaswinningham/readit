import { Component, Input } from '@angular/core';

import { Sub } from '@models/sub.model';

@Component({
  selector: 'sub',
  templateUrl: './sub.component.html',
  styleUrls: ['./sub.component.scss']
})
export class SubComponent {
  @Input() sub: Sub;
}

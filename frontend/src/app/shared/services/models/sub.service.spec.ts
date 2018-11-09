import { TestBed, inject } from '@angular/core/testing';

import { SubService } from './sub.service';

describe('SubService', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [SubService]
    });
  });

  it('should be created', inject([SubService], (service: SubService) => {
    expect(service).toBeTruthy();
  }));
});

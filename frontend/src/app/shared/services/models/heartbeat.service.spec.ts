import { TestBed, inject } from '@angular/core/testing';

import { HeartbeatService } from './heartbeat.service';

describe('HeartbeatService', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [HeartbeatService]
    });
  });

  it('should be created', inject([HeartbeatService], (service: HeartbeatService) => {
    expect(service).toBeTruthy();
  }));
});

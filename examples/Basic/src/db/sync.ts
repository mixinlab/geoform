import {synchronize} from '@nozbe/watermelondb/sync';

import {SYNC_API_URL} from '../lib/constants';
import wdb from './db';

export const mySync = async () => {
  await synchronize({
    database: wdb,
    pullChanges: async ({lastPulledAt}) => {
      const response = await fetch(`${SYNC_API_URL}?last_pulled_at=${lastPulledAt}`);
      if (!response.ok) {
        throw new Error(await response.text());
      }

      const {changes, timestamp} = await response.json();
      return {changes, timestamp};
    },
    pushChanges: async ({changes, lastPulledAt}) => {
      const response = await fetch(`${SYNC_API_URL}?last_pulled_at=${lastPulledAt}`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({changes}),
      });
      if (!response.ok) {
        throw new Error(await response.text());
      }
    },
    migrationsEnabledAtVersion: 1,
  });
};

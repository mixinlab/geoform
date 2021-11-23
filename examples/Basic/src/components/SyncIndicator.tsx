import React, {useEffect, useState} from 'react';
import {Box, Text} from 'native-base';

import {mySync} from '../db/sync';
import PointController from '../modules/points/PointController';

const SyncIndicator = () => {
  const [syncState, setSyncState] = useState<string>('Syncing data...');

  useEffect(() => {
    mySync()
      .then(() => setSyncState(''))
      .catch(err => {
        console.info('sync err', JSON.stringify(err, null, 2));
        setSyncState('Sync failed!');
      });

    PointController.getAll().then(a => console.log('all points', JSON.stringify(a, null, 2)));
  }, []);

  if (!syncState) {
    return null;
  }

  return (
    <Box alignItems="center" backgroundColor="#FB8C00" paddingY={1} width="100%">
      <Text color="#FFFFFF">{syncState}</Text>
    </Box>
  );
};

export default SyncIndicator;

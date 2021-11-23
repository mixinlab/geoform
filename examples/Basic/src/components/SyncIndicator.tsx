import React from 'react';
import {Box, Text} from 'native-base';

import {IColors} from 'native-base/lib/typescript/theme/base/colors';

export type SyncState = 'syncing' | 'success' | 'failure' | 'idle';

const syncStateColor: {[key in SyncState]: IColors} = {
  syncing: 'orange.300',
  success: 'green.400',
  failure: 'red.500',
  idle: 'gray.300',
};

type SyncIndicatorProps = {
  syncState: SyncState;
};

const SyncIndicator = ({syncState}: SyncIndicatorProps) => {
  return (
    <Box
      alignItems="center"
      backgroundColor={syncStateColor[syncState]}
      py={1}
      width="100%"
      opacity={syncState === 'idle' ? 0 : 1}>
      <Text color="white">{syncState}</Text>
    </Box>
  );
};

export default SyncIndicator;

import React from 'react';
import {Box, Text, Pressable} from 'native-base';

import {PickMode} from '../lib/types';

type MyMarkerProps = {
  mode: PickMode;
  selected?: boolean;
  onPress?: () => void;
};

const MyMarker = ({mode, selected = false, onPress}: MyMarkerProps) => {
  switch (mode) {
    case PickMode.CurrentPosition:
      return (
        <Box rounded="sm" bgColor="gray.900" px={2} py={2} w={10}>
          <Text bold textAlign="center" color="green.400">
            CP
          </Text>
        </Box>
      );
    case PickMode.ManualPick:
      return (
        // <TouchableOpacity >
        // <Box style={{padding: 20, backgroundColor: 'red'}}>
        //   <Text>XXX</Text>
        // </Box>
        <Box rounded="sm" bgColor="gray.900" px={4} py={4} w={16}>
          <Text bold textAlign="center" color="red.500" fontSize="lg">
            MP
          </Text>
        </Box>
        // </TouchableOpacity>
      );
    case PickMode.StaticPick:
      return (
        <Pressable
          onPress={() => {
            console.info('onPress');
            onPress && onPress();
          }}>
          <Box rounded="full" bgColor={selected ? 'red.400' : 'green.300'} w={6} h={6} />
        </Pressable>
      );
  }
};

export default MyMarker;

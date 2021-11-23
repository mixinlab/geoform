import React from 'react';
import MapboxGL from '@react-native-mapbox-gl/maps';
import {Box, Text} from 'native-base';

type BubbleProps = {
  location?: MapboxGL.Location;
};

export const BubbleCard = ({location}: BubbleProps) => {
  return (
    <Box bgColor="white" rounded="lg" px={6} py={3}>
      <Text>Latitude: {location?.coords.latitude}</Text>
      <Text>Longitude: {location?.coords.longitude}</Text>
      <Text>Accuracy: {location?.coords.accuracy?.toFixed(3)}</Text>
    </Box>
  );
};

import React, {useEffect, useState} from 'react';
import {
  NativeBaseProvider,
  Box,
  Center,
  Text,
  Button,
  HStack,
} from 'native-base';
import {SafeAreaView} from 'react-native-safe-area-context';
import MapboxGL from '@react-native-mapbox-gl/maps';
import Geolocation from 'react-native-geolocation-service';
import {PermissionsAndroid} from 'react-native';

MapboxGL.setAccessToken(
  'pk.eyJ1IjoiYnJlZ3kiLCJhIjoiY2txd2lucmk1MDBxazJvbzcyeDZyMXBubyJ9.VdiuEyhmzBgJORxU-AUqMw',
);

MapboxGL.offlineManager
  .createPack(
    {
      name: 'LimaPeruPack',
      styleURL: 'mapbox://styles/mapbox/dark-v10',
      minZoom: 14,
      maxZoom: 20,
      bounds: [
        [-77.135009765625, -12.030254580529714],
        [-76.89537048339844, -12.235339045075248],
      ],
    },
    (offlineRegion, status) => console.log(offlineRegion, status),
    (offlineRegion, err) => console.log(offlineRegion, err),
  )
  .then(() => {
    console.log('offline maps saved');
  })
  .catch(err => {
    console.log(err);
  });

enum PickMode {
  CurrentPosition,
  ManualPick,
}

const Marker = ({mode}: {mode: PickMode}) => {
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
        <Box rounded="sm" bgColor="gray.900" px={4} py={4} w={16}>
          <Text bold textAlign="center" color="red.500" fontSize="lg">
            MP
          </Text>
        </Box>
      );
  }
};

export default function App() {
  const mapInstance = React.createRef<MapboxGL.MapView>();

  const [currentPosition, setCurrentPosition] = useState<number[]>([0.0, 0.0]);
  const [pickMode, setPickMode] = useState<PickMode>(PickMode.CurrentPosition);

  const togglePickMode = () => {
    console.info('toggle pick mode', pickMode);
    if (pickMode === PickMode.CurrentPosition) {
      setPickMode(PickMode.ManualPick);
    } else if (pickMode === PickMode.ManualPick) {
      setPickMode(PickMode.CurrentPosition);
    }
  };

  useEffect(() => {
    PermissionsAndroid.request(
      PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
    )
      .then(status => {
        console.log(status);
        Geolocation.watchPosition(
          position => {
            console.log(position);
            setCurrentPosition([
              position.coords.longitude,
              position.coords.latitude,
            ]);
            // console.log(mapInstance.current);
          },
          error => {
            console.log(error.code, error.message);
          },
          {enableHighAccuracy: true},
        );
      })
      .catch(e => console.log(e));
  }, []);

  return (
    <NativeBaseProvider>
      <SafeAreaView>
        <Center my={6}>
          <Box my={4}>
            <Text fontSize={28}>Hello world</Text>
            <Text textAlign={'center'} color={'gray.400'}>
              This is NativeBase
            </Text>
          </Box>
          <Box width={'100%'} height={'80%'} my={4}>
            <MapboxGL.MapView
              ref={mapInstance}
              style={{flex: 1}}
              styleURL={MapboxGL.StyleURL.Dark}>
              <MapboxGL.MarkerView
                id={'a'}
                coordinate={currentPosition}
                draggable={pickMode === PickMode.ManualPick}>
                <Marker mode={pickMode} />
              </MapboxGL.MarkerView>
              {/* <MapboxGL.UserLocation /> */}
            </MapboxGL.MapView>
          </Box>
          <HStack space={4}>
            <Button onPress={togglePickMode}>Change Mode</Button>
            <Button>Send Form</Button>
          </HStack>
        </Center>
        {/* <StatusBar style="auto" /> */}
      </SafeAreaView>
    </NativeBaseProvider>
  );
}

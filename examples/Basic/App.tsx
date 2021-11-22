import React, {createRef, useEffect, useState} from 'react';
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
import {PermissionsAndroid, View} from 'react-native';

MapboxGL.setAccessToken(
  'pk.eyJ1IjoiYnJlZ3kiLCJhIjoiY2txd2lucmk1MDBxazJvbzcyeDZyMXBubyJ9.VdiuEyhmzBgJORxU-AUqMw',
);

MapboxGL.offlineManager
  .createPack(
    {
      name: 'LimaPeruPack',
      styleURL: 'mapbox://styles/mapbox/dark-v10',
      minZoom: 16,
      maxZoom: 18,
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
  StaticPick,
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
        // <TouchableOpacity >
        <View style={{padding: 20, backgroundColor: 'red'}}>
          <Text>XXX</Text>
        </View>
        // <Box rounded="sm" bgColor="gray.900" px={4} py={4} w={16}>
        //   <Text bold textAlign="center" color="red.500" fontSize="lg">
        //     MP
        //   </Text>
        // </Box>
        // </TouchableOpacity>
      );
    case PickMode.StaticPick:
      return <Box rounded="full" bgColor="darkBlue.300" w={6} h={6} />;
  }
};

type StaticPick = {
  id: string;
  latitude: number;
  longitude: number;
};

const generateStaticPicks = (
  totalPicks: number,
  origin: number[] = [-12.05, -77.05],
  radius: number = 0.1,
): StaticPick[] => {
  const staticPicks: StaticPick[] = [];
  for (let i = 0; i < totalPicks; i++) {
    staticPicks.push({
      id: `static_pick_${i}`,
      latitude: origin[1] + i * radius,
      longitude: origin[0] + i * radius,
    });
  }
  return staticPicks;
};

export default function App() {
  const mapInstance = createRef<MapboxGL.MapView>();
  const markerInstance = createRef<MapboxGL.MarkerView>();

  const [currentPosition, setCurrentPosition] = useState<number[]>([0.0, 0.0]);
  const [userLocation, setUserLocation] = useState<MapboxGL.Location>();
  const [pickMode, setPickMode] = useState<PickMode>(PickMode.CurrentPosition);
  const [staticPicks, setStaticPicks] = useState<StaticPick[]>([]);

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
            const p = [position.coords.longitude, position.coords.latitude];
            setCurrentPosition(p);
            setStaticPicks(generateStaticPicks(1000, p, 0.001));
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

  // MapboxGL.

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
              // eslint-disable-next-line react-native/no-inline-styles
              style={{flex: 1}}
              styleURL={MapboxGL.StyleURL.Dark}>
              <MapboxGL.UserLocation
                visible={true}
                onUpdate={location => setUserLocation(location)}
              />
              <MapboxGL.Camera
                zoomLevel={16}
                followUserMode={'normal'}
                followUserLocation
              />
              <MapboxGL.MarkerView
                id={'a'}
                ref={markerInstance}
                coordinate={currentPosition}
                onDrag={() => console.log(markerInstance.current)}
                draggable={pickMode === PickMode.ManualPick}>
                <Marker mode={pickMode} />
              </MapboxGL.MarkerView>
              {staticPicks.map(pick => (
                <MapboxGL.MarkerView
                  id={pick.id}
                  coordinate={[pick.longitude, pick.latitude]}>
                  <Marker mode={PickMode.StaticPick} />
                </MapboxGL.MarkerView>
              ))}
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

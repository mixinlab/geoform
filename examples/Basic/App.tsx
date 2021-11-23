import React, {createRef, useEffect, useState} from 'react';
import {
  NativeBaseProvider,
  Box,
  Center,
  Text,
  Button,
  HStack,
  Pressable,
} from 'native-base';
import {SafeAreaView} from 'react-native-safe-area-context';
import MapboxGL from '@react-native-mapbox-gl/maps';
import Geolocation from 'react-native-geolocation-service';
import {PermissionsAndroid, View} from 'react-native';
import {allArequipa} from './geocore';
import {BubbleCard} from './Bubble';

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

type MarkerProps = {mode: PickMode; selected?: boolean; onPress?: () => void};

const Marker = ({mode, selected = false, onPress}: MarkerProps) => {
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
          <Box
            rounded="full"
            bgColor={selected ? 'red.400' : 'green.300'}
            w={6}
            h={6}
          />
        </Pressable>
      );
  }
};

type StaticPick = {
  id: string;
  latitude: number;
  longitude: number;
};

export default function App() {
  const mapInstance = createRef<MapboxGL.MapView>();
  const markerInstance = createRef<MapboxGL.MarkerView>();

  const [currentPosition, setCurrentPosition] = useState<number[]>([0.0, 0.0]);
  const [userLocation, setUserLocation] = useState<MapboxGL.Location>();
  const [pickMode, setPickMode] = useState<PickMode>(PickMode.CurrentPosition);
  const [staticPicks, setStaticPicks] = useState<StaticPick[]>([]);
  const [cameraCenter, setCameraCenter] = useState<number[]>([-12.05, -77.05]);

  const [selectedPick, setSelectedPick] = useState<string | null>(null);

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
            setCameraCenter(p);
            // setStaticPicks(generateStaticPicks(100, p, 0.001));
            // console.log(mapInstance.current);
          },
          error => {
            console.log(error.code, error.message);
          },
          {
            enableHighAccuracy: true,
            accuracy: {
              android: 'high',
            },
          },
        );
      })
      .catch(e => console.log(e));
  }, []);

  useEffect(() => {
    allArequipa(100)
      .then(data => {
        console.log(`fetched ${data.length} points`);
        const points = data.map(d => ({
          id: d.id,
          latitude: d.lat,
          longitude: d.lng,
        }));
        // setStaticPicks(generateStaticPicks(1000, p, 0.001));

        const centralPoint = points[Math.floor(points.length / 2)];

        setStaticPicks(points);
        setCameraCenter([centralPoint.longitude, centralPoint.latitude]);

        // markerInstance.current.
        //   data
        //     .slice(100)
        //     .map(d => ({id: d.id, latitude: d.lat, longitude: d.lng})),
        // );
      })
      .catch(e => console.log(e));
  }, []);

  const savePointCallback = () => {
    return null;
  };

  return (
    <NativeBaseProvider>
      <SafeAreaView>
        <Center my={6}>
          <Box my={2}>
            <Text fontSize={28}>GeoForm Tech Demo</Text>
          </Box>
          <BubbleCard location={userLocation} />
          <Box width={'100%'} height={'70%'} my={4}>
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
                zoomLevel={15}
                followUserMode={'normal'}
                followUserLocation
                centerCoordinate={cameraCenter}
              />
              {/* <MapboxGL.MarkerView
                id={'a'}
                ref={markerInstance}
                coordinate={currentPosition}
                onDrag={() => console.log(markerInstance.current)}
                draggable={pickMode === PickMode.ManualPick}>
                <Marker mode={pickMode} />
              </MapboxGL.MarkerView> */}
              {/* {staticPicks.map(pick => (
                <MapboxGL.PointAnnotation
                  id={pick.id}
                  key={pick.id}
                  coordinate={[pick.longitude, pick.latitude]}>
                  <Marker
                    mode={PickMode.StaticPick}
                    selected={selectedPick === pick.id}
                    onPress={() => setSelectedPick(pick.id)}
                  />
                </MapboxGL.PointAnnotation>
              ))} */}
            </MapboxGL.MapView>
          </Box>
          <HStack space={4}>
            <Button onPress={togglePickMode}>Change Mode</Button>
            <Button onPress={savePointCallback}>Save Point</Button>
          </HStack>
        </Center>
        {/* <StatusBar style="auto" /> */}
      </SafeAreaView>
    </NativeBaseProvider>
  );
}

import MapboxGL from '@react-native-mapbox-gl/maps';
import {Box, Center, Text, Button, HStack, CheckIcon, useToast} from 'native-base';
import React, {useEffect, useState} from 'react';
import {PermissionsAndroid} from 'react-native';
import Geolocation from 'react-native-geolocation-service';

import BubbleCard from '../../components/BubbleCard';
import MyMap from '../../components/MyMap';
import SyncIndicator, {SyncState} from '../../components/SyncIndicator';
import {syncWithRemote} from '../../db/sync';
import {allArequipa} from '../../lib/geocore';
import {setupOfflineMaps} from '../../lib/mapbox';
// import {PickMode} from '../../lib/types';
import PointController from '../points/PointController';

setupOfflineMaps();

type StaticPick = {
  id: string;
  latitude: number;
  longitude: number;
};

const HomeController = () => {
  const [currentPosition, setCurrentPosition] = useState<number[]>([0.0, 0.0]);
  const [userLocation, setUserLocation] = useState<MapboxGL.Location>();
  // const [pickMode, setPickMode] = useState<PickMode>(PickMode.CurrentPosition);
  const [staticPicks, setStaticPicks] = useState<StaticPick[]>([]);
  const [cameraCenter, setCameraCenter] = useState<number[]>([-12.05, -77.05]);

  // const togglePickMode = useCallback(() => {
  //   console.info(`toggle pick mode ${pickMode}`);
  //   if (pickMode === PickMode.CurrentPosition) {
  //     setPickMode(PickMode.ManualPick);
  //   } else if (pickMode === PickMode.ManualPick) {
  //     setPickMode(PickMode.CurrentPosition);
  //   }
  // }, [pickMode]);

  const toast = useToast();

  const [syncState, setSyncState] = useState<SyncState>('syncing');

  const processSync = () => {
    syncWithRemote()
      .then(() => setSyncState('success'))
      .catch(err => {
        console.info('sync err', JSON.stringify(err, null, 2));
        setSyncState('failure');
      })
      .finally(() => setTimeout(() => setSyncState('idle'), 2000));

    // PointController.getAll().then(a => console.log('all points', JSON.stringify(a, null, 2)));
  };

  useEffect(() => {
    processSync();
  }, []);

  useEffect(() => {
    PermissionsAndroid.request(PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION)
      .then(status => {
        console.log(status);
        Geolocation.watchPosition(
          position => {
            console.log(position);
            const p = [position.coords.longitude, position.coords.latitude];
            setCurrentPosition(p);
            setCameraCenter(p);
          },
          error => console.log(error.code, error.message),
          {
            enableHighAccuracy: true,
            accuracy: {android: 'high'},
          },
        );
      })
      .catch(err => console.log(err));
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

        const centralPoint = points[Math.floor(points.length / 2)];

        setStaticPicks(points);
        setCameraCenter([centralPoint.longitude, centralPoint.latitude]);

        // markerInstance.current.
        //   data
        //     .slice(100)
        //     .map(d => ({id: d.id, latitude: d.lat, longitude: d.lng})),
        // );
      })
      .catch(err => console.log(err));
  }, []);

  const savePointCallback = async () => {
    const newPoint = await PointController.create({
      accuracy: userLocation?.coords.accuracy || 0,
      altitude: userLocation?.coords.altitude || 0,
      latitude: userLocation?.coords.latitude || 0,
      longitude: userLocation?.coords.longitude || 0,
    });

    const allPoints = await PointController.getAll();
    console.log(newPoint, allPoints);

    toast.show({
      status: 'success',
      title: 'Nuevo punto registrado',
    });

    processSync();
  };

  return (
    <Center my={6}>
      <SyncIndicator syncState={syncState} />
      <Box my={1}>
        <Text fontSize={28}>GeoForm Tech Demo</Text>
      </Box>
      <BubbleCard location={userLocation} />
      <MyMap cameraCenter={cameraCenter} setUserLocation={setUserLocation} />

      <HStack space={4}>
        {/* <Button onPress={togglePickMode}>Change Mode</Button> */}
        <Button onPress={savePointCallback} leftIcon={<CheckIcon size="5" color="gray.100" />}>
          Save Point
        </Button>
      </HStack>
    </Center>
  );
};

export default HomeController;

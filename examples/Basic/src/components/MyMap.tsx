import MapboxGL from '@react-native-mapbox-gl/maps';
import {Box} from 'native-base';
import React, {createRef, Dispatch, SetStateAction} from 'react';

type MyMapProps = {
  userLocation?: MapboxGL.Location;
  setUserLocation?: Dispatch<SetStateAction<MapboxGL.Location | undefined>>;

  cameraCenter?: number[];
  setCameraCenter?: Dispatch<SetStateAction<number[]>>;
};

const MyMap = ({setUserLocation, cameraCenter}: MyMapProps) => {
  const mapInstance = createRef<MapboxGL.MapView>();

  return (
    <Box width={'100%'} height={'70%'} my={4}>
      <MapboxGL.MapView
        ref={mapInstance}
        // eslint-disable-next-line react-native/no-inline-styles
        style={{flex: 1}}
        styleURL={MapboxGL.StyleURL.Dark}>
        <MapboxGL.UserLocation visible={true} onUpdate={location => setUserLocation?.(location)} />
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
  );
};

export default MyMap;

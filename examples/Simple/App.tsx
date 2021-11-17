import { StatusBar } from "expo-status-bar";
import React, { useEffect, useState } from "react";
import { NativeBaseProvider, Box, Center, Text } from "native-base";
import { SafeAreaView } from "react-native-safe-area-context";
// import MapboxGL from "@react-native-mapbox-gl/maps";
import * as Location from "expo-location";

// MapboxGL.StyleURL
// MapboxGL.setAccessToken(
//   "sk.eyJ1IjoiYnJlZ3kiLCJhIjoiY2t3MzVoMmhyMXl2azMxbXF5NHNna25hMCJ9.3Q2TzAxgf9FiFOZYNUnT_w"
// );

export default function App() {
  const [location, setLocation] = useState<Location.LocationObject | null>(
    null
  );
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      let { status } = await Location.requestForegroundPermissionsAsync();
      if (status !== "granted") {
        setErrorMsg("Permission to access location was denied");
        return;
      }

      let location = await Location.getCurrentPositionAsync({});
      setLocation(location);

      const stop = await Location.watchPositionAsync(
        {
          accuracy: Location.Accuracy.Highest,
          distanceInterval: 1000,
        },
        (loc: Location.LocationObject) => {
          setLocation(loc);
        }
      );
      // console.log(stop);
      return () => {
        console.log("effect out");
        stop.remove();
      };
    })();
  }, []);

  let text = "Waiting..";
  if (errorMsg) {
    text = errorMsg;
  } else if (location) {
    text = JSON.stringify(location);
  }

  return (
    <NativeBaseProvider>
      <SafeAreaView>
        <Center mt={8}>
          <Box textAlign={"center"}>
            <Text fontSize={28}>Hello world</Text>
            <Text color={"gray.400"}>This is NativeBase</Text>
          </Box>
          <Box>
            <Text>{text}</Text>
            {/* <MapboxGL.MapView
              style={{ flex: 1 }}
              styleURL={MapboxGL.StyleURL.Light}
            /> */}
          </Box>
        </Center>
        <StatusBar style="auto" />
      </SafeAreaView>
    </NativeBaseProvider>
  );
}

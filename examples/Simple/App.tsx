import { StatusBar } from "expo-status-bar";
import React from "react";
import { NativeBaseProvider, Box, Center, Text } from "native-base";
import { SafeAreaView } from "react-native-safe-area-context";

export default function App() {
  return (
    <NativeBaseProvider>
      <SafeAreaView>
        <Center mt={8}>
          <Box textAlign={"center"}>
            <Text fontSize={28}>Hello world</Text>
            <Text color={"gray.400"}>This is NativeBase</Text>
          </Box>
        </Center>
        <StatusBar style="auto" />
      </SafeAreaView>
    </NativeBaseProvider>
  );
}

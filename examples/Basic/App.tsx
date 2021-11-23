import React from 'react';
import {NativeBaseProvider} from 'native-base';
import {SafeAreaView} from 'react-native-safe-area-context';

import HomeController from './src/modules/home/HomeController';

export default function App() {
  return (
    <NativeBaseProvider>
      <SafeAreaView>
        <HomeController />
      </SafeAreaView>
    </NativeBaseProvider>
  );
}

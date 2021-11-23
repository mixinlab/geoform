import MapboxGL from '@react-native-mapbox-gl/maps';

const LIMA_PERU_OFFLINE_PACK = 'LimaPeruPack';
const MAPBOX_ACCESS_TOKEN =
  'pk.eyJ1IjoiYnJlZ3kiLCJhIjoiY2txd2lucmk1MDBxazJvbzcyeDZyMXBubyJ9.VdiuEyhmzBgJORxU-AUqMw';

MapboxGL.setAccessToken(MAPBOX_ACCESS_TOKEN);

export const setupOfflineMaps = async () => {
  try {
    const offlinePack = await MapboxGL.offlineManager.getPack(LIMA_PERU_OFFLINE_PACK);
    if (offlinePack) {
      console.info(`Offline maps [${LIMA_PERU_OFFLINE_PACK}] already saved`);
      return;
    }

    await MapboxGL.offlineManager.createPack(
      {
        name: LIMA_PERU_OFFLINE_PACK,
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
    );
    console.info(`Offline maps [${LIMA_PERU_OFFLINE_PACK}] saved`);
  } catch (err) {
    console.log(err);
  }
};

export type GeoPoint = {
  id: string;
  unicode: string;
  lat: number;
  lng: number;
  geom: string;
};

export const allArequipa = async (totalPoints: number): Promise<GeoPoint[]> => {
  const res = await fetch(
    `https://geocore.innovalab.minsky.cc/api/v1/group/ee73a646-0066-4f4a-8ee9-358e77ebba7f?limit=${totalPoints}`,
  );

  const data = await res.json();

  return data as GeoPoint[];
};

import {wdb} from '../../db';
import PointModel from '../../db/models/Point';
import {TableName} from '../../db/types';

type CreatePayload = {
  accuracy: number;
  altitude: number;
  latitude: number;
  longitude: number;

  course?: number;
  heading?: number;
  speed?: number;
};

class PointController {
  static async getAllRaw() {
    return wdb.get<PointModel>(TableName.POINTS).query().fetch();
  }

  static async getAll() {
    const allPoints = await this.getAllRaw();
    return allPoints.map(p => p._raw);
  }

  static async create(payload: CreatePayload) {
    const newPoint = await wdb.write(async () => {
      return wdb.get<PointModel>(TableName.POINTS).create(p => {
        p.accuracy = payload.accuracy;
        p.altitude = payload.altitude;
        p.latitude = payload.latitude;
        p.longitude = payload.longitude;

        p.course = payload.course;
        p.heading = payload.heading;
        p.speed = payload.speed;
      });
    });
    return newPoint;
  }

  static async resetDB() {
    const result = await wdb.write(async () => {
      return wdb.unsafeResetDatabase();
    });
    return result;
  }
}

export default PointController;

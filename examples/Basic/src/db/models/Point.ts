import {Model} from '@nozbe/watermelondb';
import {date, field} from '@nozbe/watermelondb/decorators';

import {TableName} from '../types';
// import Form from './Form';

class Point extends Model {
  static table = TableName.POINTS;

  @field('accuracy') accuracy!: number;
  @field('altitude') altitude!: number;
  @field('latitude') latitude!: number;
  @field('longitude') longitude!: number;
  @field('course') course?: number;
  @field('heading') heading?: number;
  @field('speed') speed?: number;
  @date('created_at') createdAt!: number;
  @date('updated_at') updatedAt!: number;

  // @relation('forms', 'form_id') form!: Form;
}

export default Point;

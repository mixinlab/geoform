import {Model} from '@nozbe/watermelondb';
import {date, relation, text} from '@nozbe/watermelondb/decorators';

import {TableName} from '../types';
import Point from './Point';

class Form extends Model {
  static table = TableName.FORMS;

  @text('body') body!: string;
  @date('created_at') createdAt!: number;
  @date('updated_at') updatedAt!: number;

  @relation('points', 'point_id') point!: Point;
}

export default Form;

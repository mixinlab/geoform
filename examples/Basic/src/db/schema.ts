import {appSchema, tableSchema} from '@nozbe/watermelondb';

const schema = appSchema({
  version: 1,
  tables: [
    // We'll add tableSchemas here later
    tableSchema({
      name: 'points',
      columns: [
        {name: 'accuracy', type: 'number'},
        {name: 'altitude', type: 'number'},
        {name: 'latitude', type: 'number'},
        {name: 'longitude', type: 'number'},
        {name: 'course', type: 'number', isOptional: true},
        {name: 'heading', type: 'number', isOptional: true},
        {name: 'speed', type: 'number', isOptional: true},
        // {name: 'form_id', type: 'string', isIndexed: true},
        {name: 'created_at', type: 'number'},
        {name: 'updated_at', type: 'number'},
      ],
    }),
    tableSchema({
      name: 'forms',
      columns: [
        {name: 'body', type: 'string'},
        {name: 'point_id', type: 'string', isIndexed: true},
        {name: 'created_at', type: 'number'},
        {name: 'updated_at', type: 'number'},
      ],
    }),
  ],
});

export default schema;

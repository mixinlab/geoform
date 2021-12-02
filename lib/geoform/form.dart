// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:geolocator/geolocator.dart';

// enum FormState {
//   draft,
//   submitted,
//   archived,
// }

// abstract class GeoForm {
//   FormState _state = FormState.draft;
//   late Map<String, String> _errors;
//   late Position _position;

//   FormState get state => _state;
//   Position get position => _position;
// }

// // **************************************************************************

// class RabiesProjectForm extends GeoForm {
//   late String name;

//   String date = DateTime.now().toString();

//   String? description;
//   String? imageURL;
// }

// class GeoFormField<T> {
//   late T value;
// }

// // **************************************************************************

// // typedef S ItemCreator<S>();

// typedef ItemCreator<S> = S Function();

// class GeoFormWidget<T extends GeoForm> extends StatelessWidget {
//   late T data;
//   ItemCreator<T> creator;

//   GeoFormWidget({
//     required Widget Function(BuildContext context, T data) builder,
//     Key? key,
//   }) {
//     data = creator();
//   }

//   GeoFormWidget.withFormBuilder({
//     required GlobalKey formKey,
//     required Widget Function(BuildContext context, T data) builder,
//   }) : this(builder: builder);

//   GeoFormField? operator [](String field) {
//     data.
//   }

  

//   // register() {}

//   @override
//   Widget build(BuildContext context) {
//     throw UnimplementedError();
//   }
// }

// class GeoFormMap extends StatelessWidget {
//   const GeoFormMap({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.red,
//       child: Column(
//         children: <Widget>[
//           const Text('Map'),
//           GeoFormWidget<RabiesProjectForm>(
            
//             builder: (BuildContext context, RabiesProjectForm data) {
//               return Column(
//                 children: [
//                   Text(data.state.toString()),
//                   Text(data.position.toString()),
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: Column(
//                       children: [
//                         const Text('Name'),
//                         TextField(
//                           onChanged: (value) {
//                             data.name = value;
//                           },
//                           decoration: const InputDecoration(
//                             hintText: 'Name',
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

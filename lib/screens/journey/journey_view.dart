import 'package:flutter/material.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:hopsta_demo/shared/ui_helpers.dart';
import 'package:hopsta_demo/widgets/custom_button.dart';
import 'package:latlong2/latlong.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:stacked/stacked.dart';

import 'journey_viewmodel.dart';

import 'package:flutter_map/flutter_map.dart';

class JourneyView extends StatelessWidget {
  const JourneyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<JourneyViewModel>.reactive(
      viewModelBuilder: () => JourneyViewModel(),
      onModelReady: (model) => model.handleStartup(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: Text('Journey'),
        ),
        body: (model.isBusy || !model.initialised)
            ? Center(
                child: Container(
                  width: thirdScreenWidth(context),
                  height: thirdScreenWidth(context),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              )
            : Stack(children: [
                FlutterMap(
                  mapController: model.mapController,
                  options: MapOptions(
                    center: LatLng(model.currentLocation!.latitude,
                        model.currentLocation!.longitude),
                    zoom: 15,
                  ),
                  /* layers: [
            TileLayerOptions(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: 'com.example.app',
            ),
          ], */
                  nonRotatedChildren: [
                    AttributionWidget.defaultWidget(
                      source: 'OpenStreetMap contributors',
                      onSourceTapped: null,
                    ),
                  ],
                  children: [
                    TileLayerWidget(
                      options: TileLayerOptions(
                        urlTemplate:
                            'https://tile.thunderforest.com/transport/{z}/{x}/{y}.png?apikey=74e5be6f52954c1b9b12dc7cc9ff034c',
                        maxZoom: 19,
                      ),
                    ),
                    LocationMarkerLayerWidget()
                  ],
                ),
                ...getJourneyStage(model, context)
              ]),
      ),
    );
  }

  getJourneyStage(JourneyViewModel model, BuildContext context) {
    switch (model.journeyStage) {
      case 1:
        return [
          Positioned(
              bottom: 0,
              child: Container(
                width: screenWidth(context),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Closest Station'),
                      Text(
                        '${model.closestStation['station'].name}',
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      verticalSpaceMedium,
                      Center(
                        child: CustomButton('Begin your journey', context,
                            onPressed: () => model.beginJourney(),
                            isBusy: model.busy('startButton')),
                      ),
                    ],
                  ),
                ),
              ))
        ];
      case 2:
        return [
          Positioned(
              bottom: 0,
              child: Container(
                width: screenWidth(context),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Starting station'),
                      Text(
                        '${model.closestStation['station'].name}',
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      verticalSpaceMedium,
                      Center(
                          child: QrImage(
                        data: '12347765',
                        size: twoThirdsScreenWidth(context),
                      )),
                      verticalSpaceSmall,
                      Text(
                          'Please scan the pass above at the ticket barrier or show to the guard on your train.'),
                      verticalSpaceMedium,
                      Center(
                        child: CustomButton('Pass Scanned', context,
                            onPressed: () => model.passScanned(),
                            isBusy: model.busy('scannedButton')),
                      ),
                    ],
                  ),
                ),
              ))
        ];
      case 3:
        return [
          Positioned(
              bottom: 0,
              child: Container(
                width: screenWidth(context),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current station'),
                      Text(
                        '${model.closestStation['station'].name}',
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      verticalSpaceMedium,
                      Center(
                        child: CustomButton('Complete Journey', context,
                            onPressed: () => model.completeJourney(),
                            isBusy: model.busy('completeButton')),
                      ),
                    ],
                  ),
                ),
              ))
        ];
      case 4:
        return [
          Positioned(
              bottom: 0,
              child: Container(
                width: screenWidth(context),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Destination station'),
                      Text(
                        '${model.closestStation['station'].name}',
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      verticalSpaceMedium,
                      Center(
                          child: QrImage(
                        data: '54321654',
                        size: twoThirdsScreenWidth(context),
                      )),
                      verticalSpaceSmall,
                      Text(
                          'Please scan the pass above at the ticket barrier or show to a member of staff.'),
                      verticalSpaceMedium,
                      Center(
                        child: CustomButton('Pass Scanned', context,
                            onPressed: () => model.completePassScanned(),
                            isBusy: model.busy('completeScannedButton')),
                      ),
                    ],
                  ),
                ),
              ))
        ];
      default:
        return [];
    }
  }
}

import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:hopsta_demo/shared/ui_helpers.dart';
import 'package:hopsta_demo/widgets/custom_button.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart' as Lottie;
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
                  layers: [
                    PolylineLayerOptions(
                      polylineCulling: false,
                      polylines: [
                        Polyline(
                          strokeWidth: 5.0,
                          points: model.locationService.positions,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    MarkerLayerOptions(
                        markers: model.locationService.positions
                            .map((e) => Marker(
                                point: e,
                                builder: (context) => Container(
                                      width: 10.0,
                                      height: 10.0,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    )))
                            .toList()),
                  ],
                  children: [
                    TileLayerWidget(
                      options: TileLayerOptions(
                        urlTemplate:
                            'https://tile.thunderforest.com/transport/{z}/{x}/{y}.png?apikey=74e5be6f52954c1b9b12dc7cc9ff034c',
                        maxZoom: 19,
                      ),
                    ),
                    LocationMarkerLayerWidget(
                      plugin: const LocationMarkerPlugin(
                        centerOnLocationUpdate: CenterOnLocationUpdate.always,
                        turnOnHeadingUpdate: TurnOnHeadingUpdate.never,
                      ),
                    )
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
      case 5:
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
                      children: [
                        Center(
                          child: Text(
                            'Finding best ticket options...',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Lottie.Lottie.asset('assets/animations/searching.json'),
                      ],
                    )),
              ))
        ];
      case 6:
        const Color primaryColor = Color.fromARGB(255, 203, 208, 243);
        const Color secondaryColor = Color.fromARGB(255, 78, 110, 179);
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
                      children: [
                        Text(
                          'Choose ticket option:',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        verticalSpaceMedium,
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: GestureDetector(
                            onTap: () => model.ticketPicked(),
                            child: CouponCard(
                              height: 150,
                              backgroundColor: primaryColor,
                              curveAxis: Axis.vertical,
                              firstChild: Container(
                                decoration: const BoxDecoration(
                                  color: secondaryColor,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Text(
                                              '£15.50',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Divider(
                                        color: Colors.white54, height: 0),
                                    const Expanded(
                                      child: Center(
                                        child: Text(
                                          'SINGLE',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              secondChild: Container(
                                width: double.maxFinite,
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'From',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      'MAIDSTONE EAST',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: secondaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'To',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      'BARMING',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: secondaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      'Valid 22 Aug 2022 only',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        verticalSpaceSmall,
                        GestureDetector(
                          onTap: () => model.ticketPicked(),
                          child: Container(
                            padding: EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(5)),
                            child: Column(
                              children: [
                                Text('BEST VALUE',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                verticalSpaceTiny,
                                CouponCard(
                                  height: 150,
                                  backgroundColor: primaryColor,
                                  curveAxis: Axis.vertical,
                                  firstChild: Container(
                                    decoration: const BoxDecoration(
                                      color: secondaryColor,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: const [
                                                Text(
                                                  '£17.70',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const Divider(
                                            color: Colors.white54, height: 0),
                                        const Expanded(
                                          child: Center(
                                            child: Text(
                                              'OFF-PEAK RETURN',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  secondChild: Container(
                                    width: double.maxFinite,
                                    padding: const EdgeInsets.all(18),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'From',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        Text(
                                          'MAIDSTONE STATIONS',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: secondaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'To',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        Text(
                                          'BARMING',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: secondaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Spacer(),
                                        Text(
                                          'Valid 22 Aug 2022 only',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black45,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )),
              ))
        ];
      case 7:
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
                      children: [
                        Center(
                          child: Text(
                            'Processing payment...',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Lottie.Lottie.asset('assets/animations/payment.json',
                            repeat: false),
                      ],
                    )),
              ))
        ];
      default:
        return [];
    }
  }
}

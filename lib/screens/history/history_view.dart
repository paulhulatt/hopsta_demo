import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hopsta_demo/shared/ui_helpers.dart';
import 'package:latlong2/latlong.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';

import 'history_viewmodel.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HistoryViewModel>.reactive(
        viewModelBuilder: () => HistoryViewModel(),
        onModelReady: ((model) => model.handleStartup()),
        builder: (context, model, child) => Scaffold(
              appBar: AppBar(
                title: Text('Journey History'),
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
                  : SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: ListView.builder(
                            itemCount: model.journeys.length,
                            itemBuilder: (context, pos) {
                              return Card(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: thirdScreenWidth(context),
                                      height: 100,
                                      child: FlutterMap(
                                        options: MapOptions(
                                          allowPanning: false,
                                          interactiveFlags:
                                              InteractiveFlag.none,
                                          center: model.computeCentre(
                                              model.journeys[pos].positions!),
                                          //zoom: 11,
                                          bounds: model.getLatLngBounds(
                                              model.journeys[pos].positions!),
                                        ),
                                        /* layers: [
                                              TileLayerOptions(
                                                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                                                userAgentPackageName: 'com.example.app',
                                              ),
                                            ], */
                                        layers: [
                                          PolylineLayerOptions(
                                            polylineCulling: false,
                                            polylines: [
                                              model.journeys[pos].polyline!,
                                            ],
                                          ),
                                          MarkerLayerOptions(
                                              markers: model
                                                  .journeys[pos].positions!
                                                  .where((element) =>
                                                      model
                                                              .journeys[pos]
                                                              .positions!
                                                              .first ==
                                                          element ||
                                                      model
                                                              .journeys[pos]
                                                              .positions!
                                                              .last ==
                                                          element)
                                                  .map((e) => Marker(
                                                      point: e,
                                                      builder: (context) =>
                                                          Icon(
                                                            Icons.circle,
                                                            size: 15,
                                                            color: Colors.red,
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
                                          )
                                        ],
                                      ),
                                    ),
                                    horizontalSpaceSmall,
                                    Expanded(
                                      child: SizedBox(
                                        height: 80,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  '${model.journeys[pos].startStation} to ${model.journeys[pos].endStation}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(DateFormat(
                                                      'kk:mm on dd MMM yyyy')
                                                  .format(model
                                                      .journeys[pos].started!))
                                            ]),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }),
                      ),
                    ),
            ));
  }
}

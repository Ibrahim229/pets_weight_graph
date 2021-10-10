import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pets_weight_graph/constants/colors.dart';
import 'package:pets_weight_graph/data/network/apis/weight_api.dart';
import 'package:pets_weight_graph/models/weightItem.dart';
import 'package:pets_weight_graph/ui/chart_painter.dart';
import 'package:pets_weight_graph/widgets/custom_messages.dart';

class WeightGraph extends StatefulWidget {
  @override
  State<WeightGraph> createState() => _WeightGraphState();
}

class _WeightGraphState extends State<WeightGraph> {
  double? _min, _max;
  List<double>? _y;
  List<String>? _x;
  final WeightApi weightApi = WeightApi();
  bool loading = false;
  List<Weight> _list = [];

  double scale = 1;
  double xOffset = 0;
  ScaleUpdateDetails? lastScaleUpdateDetails;

  @override
  void initState() {
    super.initState();
    _getWeights();
  }

  void _getWeights() {
    loading = true;
    setState(() {});

    weightApi.getWeights().then((value) {
      _list = value;
      loading = false;
      _getMinMax();
    }).catchError((e) {
      loading = false;
      showErrorMessage(context, e);
      setState(() {});
    });
  }

  void _addNewWeight(int weight, DateTime date) {
    loading = true;
    setState(() {});
    weightApi.addWeight(weight, date).then((value) {
      _getWeights();
    }).catchError((e) {
      loading = false;
      showErrorMessage(context, e.message);
      setState(() {});
    });
  }

  _getMinMax() {
    var min = double.maxFinite;
    var max = -double.maxFinite;
    _list.forEach((w) {
      min = min > w.weight! ? w.weight! : min;
      max = max < w.weight! ? w.weight! : max;
    });

    setState(() {
      _min = min;
      _max = max;
      _y = _list.map((w) => w.weight ?? 0.0).toList();
      _x = _list.map((w) => DateFormat("MM:dd").format(w.date!)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 22,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Weight Graph",
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: "lato",
                  fontWeight: FontWeight.w700,
                  height: 1.375),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onScaleStart: (details) {
                lastScaleUpdateDetails = null;
              },
              onScaleUpdate: (details) {
                setState(() {
                  var last = lastScaleUpdateDetails ?? details;

                  scale *= details.scale / last.scale;
                  scale = scale.clamp(1, 10);

                  const margin = ChartPainter.margin;
                  var width = MediaQuery.of(context).size.width - margin;

                  var lastX = last.focalPoint.dx - margin;
                  var x = details.focalPoint.dx - margin;

                  xOffset += (x - lastX * details.scale / last.scale) / scale;
                  xOffset = xOffset.clamp(-width * (scale - 1) / scale, 0);

                  lastScaleUpdateDetails = details;
                });
              },
              child: CustomPaint(
                child: Container(),
                painter: ChartPainter(_x ?? [], _y ?? [], _min ?? 0.0,
                    _max ?? 0.0, scale, xOffset),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 16, 16),
                child: OutlinedButton.icon(
                  label: const Text(
                    "Weight",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.buttonTextColor),
                  ),
                  icon: Icon(
                    Icons.add,
                    color: AppColors.buttonTextColor,
                  ),
                  onPressed: _showWeightAndDatePicker,
                  style: OutlinedButton.styleFrom(
                      side: BorderSide.none,
                      backgroundColor:
                          AppColors.buttonTextColor.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.5))),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showWeightAndDatePicker() {
    showModalBottomSheet(
        context: context, builder: (cxt) => _weightAndDatePicker());
  }

  Widget _weightAndDatePicker() {
    int selectedWeight = 0;
    DateTime selectedData = DateTime.now();
    return Container(
      height: 500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
              height: 210,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "Pick Date",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: "lato",
                          fontWeight: FontWeight.w700,
                          height: 1.375),
                    ),
                  ),
                  Expanded(
                    child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: selectedData,
                        maximumDate: DateTime.now(),
                        onDateTimeChanged: (val) {
                          selectedData = val;
                        }),
                  ),
                ],
              )),
          Divider(),
          SizedBox(
              height: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "Weight",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: "lato",
                          fontWeight: FontWeight.w700,
                          height: 1.375),
                    ),
                  ),
                  Expanded(
                      child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CupertinoPicker(
                            scrollController:
                                new FixedExtentScrollController(initialItem: 0),
                            itemExtent: 32.0,
                            onSelectedItemChanged: (int index) {
                              selectedWeight = index;
                            },
                            children:
                                new List<Widget>.generate(17, (int index) {
                              return new Center(
                                child: new Text(index.toString()),
                              );
                            })),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                            itemExtent: 32.0,
                            onSelectedItemChanged: (int index) {},
                            children: [
                              Text(
                                "Kg",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: "lato",
                                    fontWeight: FontWeight.w700,
                                    height: 1.375),
                              )
                            ]),
                      ),
                    ],
                  )),
                ],
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: OutlinedButton.icon(
              label: const Text(
                "Add weight",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.buttonTextColor),
              ),
              icon: Icon(
                Icons.add,
                color: AppColors.buttonTextColor,
              ),
              onPressed: () => _addNewWeight(selectedWeight, selectedData),
              style: OutlinedButton.styleFrom(
                  side: BorderSide.none,
                  backgroundColor: AppColors.buttonTextColor.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.5))),
            ),
          )
        ],
      ),
    );
  }
}

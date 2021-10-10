import 'package:pets_weight_graph/data/network/dio_client.dart';
import 'package:pets_weight_graph/models/weightItem.dart';

class WeightApi {
  // dio instance
  final DioClient _dioClient = DioClient();
  final String baseUri = "http://localhost:3000/weights";

  // injecting dio instance
  WeightApi();

  Future<List<Weight>> getWeights() async {
    try {
      final res = await _dioClient.get(baseUri);
      return List<Weight>.from(res["weights"].map((x) => Weight.fromMap(x)));
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  Future<bool> addWeight(int weight, DateTime date) async {
    var data = {"weight": weight, "date": date.toIso8601String()};
    bool success = false;
    try {
      final res = await _dioClient.post(baseUri, data: data);
      success = true;
      return success;
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }
}

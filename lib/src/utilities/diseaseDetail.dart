import 'package:virice/src/utilities/StringResource.dart';

class DiseaseDetail {
  final int diseaseName;
  DiseaseDetail(this.diseaseName);
  String getName() {
    switch (this.diseaseName) {
      case 0:
        return StringResource.brownSpot;
      case 1:
        return StringResource.healthy;
      case 2:
        return StringResource.hispa;
      case 3:
        return StringResource.leafBlast;
      default:
        return StringResource.unknown;
    }
  }

  String getReason() {
    switch (this.diseaseName) {
      case 0:
        return StringResource.brownSpotReason;
      case 1:
        return StringResource.healthyReason;
      case 2:
        return StringResource.hispaReason;
      case 3:
        return StringResource.leafBlastReason;
      default:
        return StringResource.unknown;
    }
  }

  String getSolution() {
    switch (this.diseaseName) {
      case 0:
        return StringResource.brownSpotSolution;
      case 1:
        return StringResource.healthySolution;
      case 2:
        return StringResource.hispaSolution;
      case 3:
        return StringResource.leafBlastSolution;
      default:
        return StringResource.unknown;
    }
  }
}
